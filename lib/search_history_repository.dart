import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Tiene traccia degli ultimi prodotti aperti (via ricerca o navigazione),
// cosi' in cima alla schermata di ricerca lo staff ritrova subito i
// modelli con cui ha appena lavorato, invece di doverli ricercare da capo.
// Tiene anche un conteggio delle aperture, locale e aggregato su Firestore,
// per la classifica "prodotti piu' cercati" (vedi most_viewed_screen.dart).
class SearchHistoryRepository {
  static const _boxName = 'recent_history';
  static const _key = 'productIds';
  static const _countsKey = 'viewCounts';
  static const _maxItems = 12;
  static const _viewsCollection = 'productViewCounts';

  Box? _box;
  bool _cloudEnabled = false;
  StreamSubscription<User?>? _authSub;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  // Da chiamare solo nell'app vera (mai nei test, come catalogRepository):
  // abilita l'invio dei conteggi di apertura a Firestore, cosi' la
  // classifica riflette tutti i dispositivi del negozio e non solo questo.
  void enableCloudAggregation() {
    _cloudEnabled = true;
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      _cloudEnabled = user != null;
    });
  }

  CollectionReference<Map<String, dynamic>> get _viewsRef =>
      FirebaseFirestore.instance.collection(_viewsCollection);

  List<String> getRecentIds() {
    final raw = _box?.get(_key);
    if (raw == null) return [];
    return List<String>.from(raw as List);
  }

  // Quante volte ogni prodotto e' stato aperto su questo dispositivo (dato
  // solo locale): usato come riserva quando l'aggregato cloud non e'
  // disponibile (offline, o app senza sync abilitata come nei test).
  // A differenza di getRecentIds() qui il conteggio non si azzera ne' si
  // riordina, cresce e basta finche' l'app resta installata.
  Map<String, int> getViewCounts() {
    final raw = _box?.get(_countsKey);
    if (raw == null) return {};
    return Map<String, int>.from(raw as Map);
  }

  // Legge i conteggi aggregati da tutti i dispositivi. Ritorna null se non
  // disponibile (cloud non abilitato, non autenticato, errore di rete): il
  // chiamante ricade sui conteggi locali in quel caso.
  Future<Map<String, int>?> fetchAggregatedViewCounts() async {
    if (!_cloudEnabled) return null;
    try {
      final snapshot = await _viewsRef.get();
      final counts = <String, int>{};
      for (final doc in snapshot.docs) {
        final raw = doc.data()['count'];
        if (raw is num) counts[doc.id] = raw.toInt();
      }
      return counts;
    } catch (_) {
      return null;
    }
  }

  // Niente await: come il resto del repository, il box tiene i dati in
  // memoria in modo sincrono, il Future segue solo il flush su disco.
  void recordView(String productId) {
    final ids = getRecentIds();
    ids.remove(productId);
    ids.insert(0, productId);
    if (ids.length > _maxItems) {
      ids.removeRange(_maxItems, ids.length);
    }
    _box!.put(_key, ids);

    final counts = getViewCounts();
    counts[productId] = (counts[productId] ?? 0) + 1;
    _box!.put(_countsKey, counts);

    if (_cloudEnabled) {
      // FieldValue.increment somma direttamente sul server: piu'
      // dispositivi possono incrementare lo stesso prodotto insieme senza
      // che uno "perda" l'aggiornamento dell'altro (niente letto-modifica-
      // scritto lato client).
      _viewsRef.doc(productId).set(
        {'count': FieldValue.increment(1)},
        SetOptions(merge: true),
      ).catchError((_) {});
    }
  }

  void dispose() {
    _authSub?.cancel();
  }
}

final searchHistoryRepository = SearchHistoryRepository();
