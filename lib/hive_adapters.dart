import 'package:hive/hive.dart';
import 'product.dart';

// Adapter scritti a mano (niente build_runner/code-generation): ogni
// oggetto viene serializzato come mappa {campo: valore}, cosi' l'ordine
// dei campi non conta e aggiungerne di nuovi in futuro non rompe i dati
// gia' salvati.

class ProductVariantAdapter extends TypeAdapter<ProductVariant> {
  @override
  final int typeId = 1;

  @override
  ProductVariant read(BinaryReader reader) {
    final map = reader.readMap();
    return ProductVariant(
      storage: map['storage'] as String,
      color: map['color'] as String,
      code: map['code'] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ProductVariant obj) {
    writer.writeMap({
      'storage': obj.storage,
      'color': obj.color,
      'code': obj.code,
    });
  }
}

class PcVariantAdapter extends TypeAdapter<PcVariant> {
  @override
  final int typeId = 2;

  @override
  PcVariant read(BinaryReader reader) {
    final map = reader.readMap();
    return PcVariant(
      code: map['code'] as String,
      cpu: map['cpu'] as String?,
      ram: map['ram'] as String?,
      storage: map['storage'] as String?,
      gpu: map['gpu'] as String?,
      screen: map['screen'] as String?,
      color: map['color'] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PcVariant obj) {
    writer.writeMap({
      'code': obj.code,
      'cpu': obj.cpu,
      'ram': obj.ram,
      'storage': obj.storage,
      'gpu': obj.gpu,
      'screen': obj.screen,
      'color': obj.color,
    });
  }
}

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final map = reader.readMap();
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String,
      category: map['category'] as String,
      imagePath: map['imagePath'] as String,
      variants: (map['variants'] as List).cast<ProductVariant>(),
      pcVariants: (map['pcVariants'] as List?)?.cast<PcVariant>() ?? const [],
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer.writeMap({
      'id': obj.id,
      'name': obj.name,
      'brand': obj.brand,
      'category': obj.category,
      'imagePath': obj.imagePath,
      'variants': obj.variants,
      'pcVariants': obj.pcVariants,
    });
  }
}
