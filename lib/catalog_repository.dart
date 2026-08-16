import 'package:hive_flutter/hive_flutter.dart';
import 'hive_adapters.dart';
import 'product.dart';

// Livello dati: incapsula il box Hive dei prodotti. Una volta aperto, le
// letture sono sincrone (Hive tiene tutto in memoria), quindi il resto
// dell'app puo' continuare a leggere `sampleProducts` come prima, senza
// diventare async.
class CatalogRepository {
  static const _boxName = 'products';
  Box<Product>? _box;

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
    if (_box!.isEmpty) {
      for (final product in seedIfEmpty) {
        await _box!.put(product.id, product);
      }
    }
  }

  List<Product> getAll() => _box!.values.toList();

  Future<void> upsert(Product product) => _box!.put(product.id, product);

  Future<void> delete(String id) => _box!.delete(id);

  bool exists(String id) => _box!.containsKey(id);
}

final catalogRepository = CatalogRepository();
