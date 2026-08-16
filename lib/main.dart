import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin/catalog_admin_screen.dart';
import 'app_colors.dart';
import 'catalog.dart';
import 'catalog_repository.dart';
import 'product_detail_screen.dart';
import 'theme_controller.dart';
import 'widgets/mw_app_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await catalogRepository.init(initialSeedProducts);
  runApp(const MWInventoryApp());
}

ThemeData _buildTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: kBrandRed,
    brightness: brightness,
  );
  final baseTextTheme = brightness == Brightness.dark
      ? ThemeData(brightness: Brightness.dark).textTheme
      : ThemeData(brightness: Brightness.light).textTheme;

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: brightness == Brightness.dark
        ? const Color(0xFF121317)
        : const Color(0xFFF4F5F7),
    splashFactory: InkRipple.splashFactory,
    textTheme: GoogleFonts.poppinsTextTheme(baseTextTheme),
    useMaterial3: true,
  );
}

class MWInventoryApp extends StatelessWidget {
  const MWInventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'MW Inventory',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          home: const CategoriesScreen(),
        );
      },
    );
  }
}

// 1. SCHERMATA CATEGORIE (HOMEPAGE)
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'name': 'Telefonia', 'icon': Icons.smartphone_rounded},
    {'name': 'PC', 'icon': Icons.laptop_rounded},
    {'name': 'TV', 'icon': Icons.connected_tv_rounded},
    {'name': 'Gaming', 'icon': Icons.sports_esports_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: MwAppBar(
        title: 'MW INVENTORY',
        actions: [
          IconButton(
            tooltip: 'Gestisci catalogo',
            icon: const Icon(Icons.inventory_2_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CatalogAdminScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: scheme.brightness == Brightness.dark ? 0.3 : 0.05,
                    ),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BrandsScreen(categoryName: category['name']),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFEC2436), kBrandRed],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x40E2001A),
                              blurRadius: 14,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          category['icon'],
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        category['name'],
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Mappa dei marchi abilitati esclusivamente per la categoria Telefonia
const List<String> telefoniaBrands = [
  'Apple',
  'Samsung',
  'Xiaomi',
  'Oppo',
  'Realme',
  'ZTE',
  'Honor',
  'Motorola',
  'Google',
];

// Mappa dei loghi locali
const Map<String, String> brandLogos = {
  'Apple': 'assets/brands/apple.png',
  'Samsung': 'assets/brands/samsung.png',
  'Xiaomi': 'assets/brands/xiaomi.png',
  'Oppo': 'assets/brands/oppo.png',
  'Realme': 'assets/brands/realme.png',
  'ZTE': 'assets/brands/zte.png',
  'Honor': 'assets/brands/honor.png',
  'Motorola': 'assets/brands/motorola.png',
  'Google': 'assets/brands/google.png',
  'HP': 'assets/brands/hp.png',
  'LG': 'assets/brands/lg.png',
  'Lenovo': 'assets/brands/lenovo.png',
  'Acer': 'assets/brands/acer.png',
  'Asus': 'assets/brands/asus.png',
  'MSI': 'assets/brands/msi.png',
  'Microsoft': 'assets/brands/microsoft.png',
};

// 2. SCHERMATA BRAND PER CATEGORIA (LOGHI LOCALI)
class BrandsScreen extends StatelessWidget {
  final String categoryName;

  const BrandsScreen({super.key, required this.categoryName});

  Widget _buildBrandLogo(BuildContext context, String brand) {
    final logoPath = brandLogos[brand];
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: logoPath != null
            ? Image.asset(
                logoPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackBadge(brand),
              )
            : _buildFallbackBadge(brand),
      ),
    );
  }

  Widget _buildFallbackBadge(String brand) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kBrandRed, Color(0xFF990011)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        brand.length > 3
            ? brand.substring(0, 3).toUpperCase()
            : brand.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Prodotti della categoria corrente
    final filteredProducts =
        sampleProducts.where((p) => p.category == categoryName).toList();

    // Se siamo in Telefonia usa SOLO la lista specifica richiesta, altrimenti estrai i brand presenti
    final List<String> brands = categoryName == 'Telefonia'
        ? telefoniaBrands
        : filteredProducts.map((p) => p.brand).toSet().toList();

    return Scaffold(
      appBar: MwAppBar(title: categoryName.toUpperCase()),
      body: brands.isEmpty
          ? const Center(child: Text('Nessun brand presente'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: brands.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final brand = brands[index];
                  final count =
                      filteredProducts.where((p) => p.brand == brand).length;

                  return Container(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: scheme.brightness == Brightness.dark
                                ? 0.3
                                : 0.05,
                          ),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BrandProductsScreen(
                                categoryName: categoryName,
                                brandName: brand,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: _buildBrandLogo(context, brand)),
                              const SizedBox(height: 10),
                              Text(
                                brand,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$count ${count == 1 ? 'modello' : 'modelli'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// 3. SCHERMATA PRODOTTI IN FORMATO GRIGLIA
class BrandProductsScreen extends StatelessWidget {
  final String categoryName;
  final String brandName;

  const BrandProductsScreen({
    super.key,
    required this.categoryName,
    required this.brandName,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final products = sampleProducts
        .where((p) => p.category == categoryName && p.brand == brandName)
        .toList();

    return Scaffold(
      appBar: MwAppBar(title: brandName.toUpperCase()),
      body: products.isEmpty
          ? Center(
              child: Text(
                'Nessun prodotto disponibile per questo brand',
                style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: scheme.brightness == Brightness.dark
                                ? 0.3
                                : 0.05,
                          ),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: product),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Hero(
                                      tag: 'product-image-${product.id}',
                                      child: Image.asset(
                                        product.imagePath,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.phone_iphone_rounded,
                                            color: kBrandRed,
                                            size: 48,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                product.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                              ),
                              if (product.variants.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  '${product.variants.length} ${product.variants.length == 1 ? 'variante' : 'varianti'}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
