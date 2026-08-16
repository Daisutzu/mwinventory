import 'catalog_repository.dart';
import 'console_catalog.dart';
import 'pc_catalog.dart';
import 'pc_fissi_catalog.dart';
import 'product.dart';
import 'tablet_catalog.dart';
import 'telefonia_catalog.dart';
import 'tv_catalog.dart';

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

      // --- TABLET ---
      ...tabletCatalog,

      // --- PC ---
      ...pcCatalog,

      // --- PC FISSI ---
      ...pcFissiCatalog,

      // --- CONSOLE ---
      ...consoleCatalog,

      // --- TV ---
      ...tvCatalog,
    ];
