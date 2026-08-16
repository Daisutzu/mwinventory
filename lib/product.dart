class ProductVariant {
  final String storage;
  final String color;
  final String code; // Codice PIM univoco per questa combinazione

  ProductVariant({
    required this.storage,
    required this.color,
    required this.code,
  });
}

// Una configurazione hardware venduta per un modello PC (niente colore:
// ogni codice PIM e' una combinazione specifica di CPU/RAM/storage/GPU).
class PcVariant {
  final String? cpu;
  final String? ram;
  final String? storage;
  final String? gpu;
  final String? screen;
  final String? color;
  final String code;

  PcVariant({
    this.cpu,
    this.ram,
    this.storage,
    this.gpu,
    this.screen,
    this.color,
    required this.code,
  });
}

class Product {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String imagePath;
  final List<ProductVariant> variants;
  final List<PcVariant> pcVariants;

  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.imagePath,
    required this.variants,
    this.pcVariants = const [],
  });

  // Estrae le memorie uniche disponibili per il prodotto
  List<String> get availableStorages =>
      variants.map((v) => v.storage).toSet().toList();

  // Estrae i colori disponibili per una specifica memoria
  List<String> getColorsForStorage(String storage) {
    return variants
        .where((v) => v.storage == storage)
        .map((v) => v.color)
        .toSet()
        .toList();
  }

  // Trova il codice PIM per la combinazione selezionata
  String getCode(String storage, String color) {
    final variant = variants.firstWhere(
      (v) => v.storage == storage && v.color == color,
      orElse: () => ProductVariant(storage: '', color: '', code: '00000'),
    );
    return variant.code;
  }
}
