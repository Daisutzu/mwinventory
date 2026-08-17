import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'catalog_cloud_sync.dart';
import 'hive_adapters.dart';
import 'product.dart';

// Livello dati: incapsula il box Hive dei prodotti. Una volta aperto, le
// letture sono sincrone (Hive tiene tutto in memoria), quindi il resto
// dell'app puo' continuare a leggere `sampleProducts` come prima, senza
// diventare async.
//
// La sincronizzazione cloud (Firestore) e' un livello aggiuntivo sopra
// Hive, non una sostituzione: il catalogo locale resta la fonte di verita'
// per l'app (funziona offline), Firestore serve solo a propagare agli
// altri dispositivi le modifiche fatte dalla schermata di gestione. Se il
// dispositivo e' offline o Firestore non e' raggiungibile, l'app continua
// a funzionare solo in locale (tutti gli errori di rete sono ignorati).
class CatalogRepository {
  static const _boxName = 'products';
  static const _metaBoxName = 'catalog_meta';
  static const _seedSignatureKey = 'seedSignature';
  static const _cloudCollection = 'products';

  Box<Product>? _box;
  Box? _metaBox;
  bool _cloudEnabled = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _cloudSub;
  StreamSubscription<User?>? _authSub;

  // Stato della sincronizzazione, per mostrare in UI se le modifiche stanno
  // davvero raggiungendo Firestore (es. nella gestione catalogo) invece di
  // restare solo sul dispositivo senza che nessuno se ne accorga: gli
  // errori di rete non vengono piu' solo ignorati in silenzio, aggiornano
  // anche questo stato.
  final ValueNotifier<bool> cloudSynced = ValueNotifier<bool>(false);

  Future<void> init(List<Product> seedIfEmpty) async {
    await Hive.initFlutter();
    await _openAndSeed(seedIfEmpty);
    _cloudEnabled = true;
    // Le regole di Firestore richiedono un utente autenticato: la sync
    // parte/si ferma insieme all'accesso (schermata password), non solo
    // all'avvio dell'app.
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _pullFromCloud();
        _listenToCloud();
      } else {
        _cloudSub?.cancel();
        cloudSynced.value = false;
      }
    });
  }

  // Usato solo dai test: Hive.initFlutter() si appoggia a path_provider
  // (platform channel), non disponibile nell'ambiente di `flutter test`.
  // Hive.init(path) e' la versione "core" che lavora con una cartella
  // qualsiasi, quindi basta puntarla a una temp dir. Niente Firestore nei
  // test: richiederebbe una vera app Firebase inizializzata.
  Future<void> initForTest(String path, List<Product> seedIfEmpty) async {
    Hive.init(path);
    await _openAndSeed(seedIfEmpty);
  }

  CollectionReference<Map<String, dynamic>> get _cloudRef =>
      FirebaseFirestore.instance.collection(_cloudCollection);

  Future<void> _pullFromCloud() async {
    try {
      final snapshot = await _cloudRef.get();
      for (final doc in snapshot.docs) {
        await _box!.put(doc.id, productFromCloudMap(doc.data()));
      }
      cloudSynced.value = true;
    } catch (e) {
      cloudSynced.value = false;
      debugPrint('Sync catalogo: pull iniziale non riuscito ($e)');
    }
  }

  // Ascolta i cambiamenti fatti da altri dispositivi mentre l'app e'
  // aperta, cosi' non serve riavviarla per vederli.
  void _listenToCloud() {
    _cloudSub = _cloudRef.snapshots().listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.removed) {
          _box!.delete(change.doc.id);
        } else {
          final data = change.doc.data();
          if (data != null) {
            _box!.put(change.doc.id, productFromCloudMap(data));
          }
        }
      }
      cloudSynced.value = true;
    }, onError: (Object e) {
      cloudSynced.value = false;
      debugPrint('Sync catalogo: ascolto Firestore interrotto ($e)');
    });
  }

  void _pushToCloud(Product product) {
    _cloudRef.doc(product.id).set(productToCloudMap(product)).then((_) {
      cloudSynced.value = true;
    }).catchError((e) {
      cloudSynced.value = false;
      debugPrint('Sync catalogo: invio a Firestore non riuscito ($e)');
    });
  }

  void _deleteFromCloud(String id) {
    _cloudRef.doc(id).delete().then((_) {
      cloudSynced.value = true;
    }).catchError((e) {
      cloudSynced.value = false;
      debugPrint('Sync catalogo: eliminazione su Firestore non riuscita ($e)');
    });
  }

  Future<void> _openAndSeed(List<Product> seedIfEmpty) async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ProductVariantAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PcVariantAdapter());
    }
    _box = await Hive.openBox<Product>(_boxName);
    _metaBox = await Hive.openBox(_metaBoxName);

    if (_box!.isEmpty) {
      for (final product in seedIfEmpty) {
        await _box!.put(product.id, product);
      }
      await _metaBox!.put(_seedSignatureKey, _seedSignature(seedIfEmpty));
      return;
    }

    // Il box non e' vuoto: e' un dispositivo che aveva gia' installato
    // l'app. Se il catalogo di partenza nel codice e' cambiato da allora
    // (nuovi prodotti, EAN aggiunti, correzioni), aggiorniamo solo le
    // schede che vengono dal seed (stesso id), senza toccare prodotti
    // aggiunti a mano dallo staff tramite la schermata di gestione.
    final signature = _seedSignature(seedIfEmpty);
    if (_metaBox!.get(_seedSignatureKey) != signature) {
      for (final product in seedIfEmpty) {
        await _box!.put(product.id, product);
      }
      await _metaBox!.put(_seedSignatureKey, signature);
    }
  }

  // Stringa che cambia se cambia qualunque campo rilevante del catalogo di
  // partenza (non solo quali id sono presenti): usata per capire se un
  // dispositivo con dati gia' salvati ha bisogno di un riallineamento.
  String _seedSignature(List<Product> products) {
    final buffer = StringBuffer();
    for (final p in products) {
      buffer
        ..write(p.id)
        ..write('|')
        ..write(p.name)
        ..write('|')
        ..write(p.brand)
        ..write('|')
        ..write(p.category)
        ..write('|')
        ..write(p.imagePath);
      for (final v in p.variants) {
        buffer
          ..write('~')
          ..write(v.storage)
          ..write(',')
          ..write(v.color)
          ..write(',')
          ..write(v.code)
          ..write(',')
          ..write(v.ean);
      }
      for (final v in p.pcVariants) {
        buffer
          ..write('~')
          ..write(v.cpu)
          ..write(',')
          ..write(v.ram)
          ..write(',')
          ..write(v.storage)
          ..write(',')
          ..write(v.gpu)
          ..write(',')
          ..write(v.screen)
          ..write(',')
          ..write(v.color)
          ..write(',')
          ..write(v.code)
          ..write(',')
          ..write(v.ean);
      }
      buffer.write(';');
    }
    return buffer.length.toString() + buffer.toString().hashCode.toString();
  }

  List<Product> getAll() => _box!.values.toList();

  Future<void> upsert(Product product) {
    final future = _box!.put(product.id, product);
    if (_cloudEnabled) _pushToCloud(product);
    return future;
  }

  Future<void> delete(String id) {
    final future = _box!.delete(id);
    if (_cloudEnabled) _deleteFromCloud(id);
    return future;
  }

  bool exists(String id) => _box!.containsKey(id);

  void dispose() {
    _cloudSub?.cancel();
    _authSub?.cancel();
  }
}

final catalogRepository = CatalogRepository();
