import 'catalog_repository.dart';
import 'pc_catalog.dart';
import 'product.dart';
import 'telefonia_catalog.dart';

// Catalogo effettivo usato dall'app: legge dal database Hive locale, che
// viene popolato una sola volta (al primo avvio) con [initialSeedProducts].
// Da qui in poi la fonte di verita' e' il database, modificabile dalla
// schermata di gestione senza toccare il codice.
List<Product> get sampleProducts => catalogRepository.getAll();

// Catalogo di partenza (importato dai codici PIM forniti): usato solo per
// popolare il database la primissima volta che l'app viene avviata.
List<Product> get initialSeedProducts => [
      // --- TELEFONIA (catalogo importato dai codici PIM) ---
      ...telefoniaCatalog,

      // --- PC ---
      ...pcCatalog,

      // --- TV ---
      Product(
        id: '13',
        name: 'OLED 55" C3',
        brand: 'LG',
        category: 'TV',
        imagePath: 'assets/products/lgoled55.png',
        variants: [],
      ),
      Product(
        id: '14',
        name: 'QLED 65" Q60',
        brand: 'Samsung',
        category: 'TV',
        imagePath: 'assets/products/samsungqled65.png',
        variants: [],
      ),
    ];
