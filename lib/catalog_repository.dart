import 'package:hive_flutter/hive_flutter.dart';
import 'hive_adapters.dart';
import 'product.dart';

// Livello dati: incapsula il box Hive dei prodotti. Una volta aperto, le
// letture sono sincrone (Hive tiene tutto in memoria), quindi il resto
// dell'app puo' continuare a leggere `sampleProducts` come prima, senza
// diventare async.
class CatalogRepository {
  static const _boxName = 'products';
  static const _metaBoxName = 'catalog_meta';
  static const _seedSignatureKey = 'seedSignature';
  Box<Product>? _box;
  Box? _metaBox;

  Future<void> init(List<Product> seedIfEmpty) async {
    await Hive.initFlutter();
    await _openAndSeed(seedIfEmpty);
  }

  // Usato solo dai test: Hive.initFlutter() si appoggia a path_provider
  // (platform channel), non disponibile nell'ambiente di `flutter test`.
  // Hive.init(path) e' la versione "core" che lavora con una cartella
  // qualsiasi, quindi basta puntarla a una temp dir.
  Future<void> initForTest(String path, List<Product> seedIfEmpty) async {
    Hive.init(path);
    await _openAndSeed(seedIfEmpty);
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

  Future<void> upsert(Product product) => _box!.put(product.id, product);

  Future<void> delete(String id) => _box!.delete(id);

  bool exists(String id) => _box!.containsKey(id);
}

final catalogRepository = CatalogRepository();
