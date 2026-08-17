import 'product.dart';

// Conversione tra Product e la mappa salvata su Firestore. Tenuta separata
// dal modello dati (product.dart) cosi' il resto dell'app non dipende da
// Firestore, e da hive_adapters.dart perche' i due formati sono pensati
// per scopi diversi (Firestore vuole solo Map/List/tipi primitivi).

Map<String, dynamic> productToCloudMap(Product p) => {
      'id': p.id,
      'name': p.name,
      'brand': p.brand,
      'category': p.category,
      'imagePath': p.imagePath,
      'variants': p.variants
          .map((v) => {
                'storage': v.storage,
                'color': v.color,
                'code': v.code,
                'ean': v.ean,
              })
          .toList(),
      'pcVariants': p.pcVariants
          .map((v) => {
                'cpu': v.cpu,
                'ram': v.ram,
                'storage': v.storage,
                'gpu': v.gpu,
                'screen': v.screen,
                'color': v.color,
                'code': v.code,
                'ean': v.ean,
              })
          .toList(),
    };

Product productFromCloudMap(Map<String, dynamic> map) {
  final variants = (map['variants'] as List? ?? []).map((raw) {
    final v = Map<String, dynamic>.from(raw as Map);
    return ProductVariant(
      storage: v['storage'] as String,
      color: v['color'] as String,
      code: v['code'] as String,
      ean: v['ean'] as String?,
    );
  }).toList();

  final pcVariants = (map['pcVariants'] as List? ?? []).map((raw) {
    final v = Map<String, dynamic>.from(raw as Map);
    return PcVariant(
      cpu: v['cpu'] as String?,
      ram: v['ram'] as String?,
      storage: v['storage'] as String?,
      gpu: v['gpu'] as String?,
      screen: v['screen'] as String?,
      color: v['color'] as String?,
      code: v['code'] as String,
      ean: v['ean'] as String?,
    );
  }).toList();

  return Product(
    id: map['id'] as String,
    name: map['name'] as String,
    brand: map['brand'] as String,
    category: map['category'] as String,
    imagePath: map['imagePath'] as String,
    variants: variants,
    pcVariants: pcVariants,
  );
}
