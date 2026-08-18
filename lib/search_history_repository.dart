import 'package:hive_flutter/hive_flutter.dart';

// Tiene traccia degli ultimi prodotti aperti (via ricerca o navigazione),
// cosi' in cima alla schermata di ricerca lo staff ritrova subito i
// modelli con cui ha appena lavorato, invece di doverli ricercare da capo.
class SearchHistoryRepository {
  static const _boxName = 'recent_history';
  static const _key = 'productIds';
  static const _countsKey = 'viewCounts';
  static const _maxItems = 12;

  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  List<String> getRecentIds() {
    final raw = _box?.get(_key);
    if (raw == null) return [];
    return List<String>.from(raw as List);
  }

  // Quante volte ogni prodotto e' stato aperto su questo dispositivo (dato
  // solo locale, non sincronizzato: e' un contatore d'uso, non catalogo).
  // A differenza di getRecentIds() qui il conteggio non si azzera ne' si
  // riordina, cresce e basta finche' l'app resta installata.
  Map<String, int> getViewCounts() {
    final raw = _box?.get(_countsKey);
    if (raw == null) return {};
    return Map<String, int>.from(raw as Map);
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
  }
}

final searchHistoryRepository = SearchHistoryRepository();
