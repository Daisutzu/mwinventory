import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'catalog.dart';
import 'color_names.dart';
import 'product.dart';
import 'product_detail_screen.dart';
import 'widgets/mw_app_bar.dart';

class SearchProductsScreen extends StatefulWidget {
  const SearchProductsScreen({super.key});

  @override
  State<SearchProductsScreen> createState() => _SearchProductsScreenState();
}

class _SearchProductsScreenState extends State<SearchProductsScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Per ogni prodotto trovato, tiene traccia anche di quale codice ha
  // fatto scattare il match (se la ricerca era per codice), cosi' possiamo
  // mostrarlo subito nel risultato invece di farlo ricercare all'utente.
  List<(Product, String?)> _search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final results = <(Product, String?)>[];
    for (final product in sampleProducts) {
      final nameMatch = product.name.toLowerCase().contains(q);
      final brandMatch = product.brand.toLowerCase().contains(q);

      String? matchedCode;
      for (final variant in product.variants) {
        if (variant.code.toLowerCase().contains(q) ||
            colorDisplayName(variant.color).toLowerCase().contains(q)) {
          matchedCode = variant.code;
          break;
        }
      }
      for (final variant in product.pcVariants) {
        final specMatch = [
          variant.cpu,
          variant.ram,
          variant.storage,
          variant.gpu,
        ].whereType<String>().any((s) => s.toLowerCase().contains(q));
        if (variant.code.toLowerCase().contains(q) || specMatch) {
          matchedCode = variant.code;
          break;
        }
      }

      if (nameMatch || brandMatch || matchedCode != null) {
        results.add((product, matchedCode));
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final results = _search(_query);

    return Scaffold(
      appBar: const MwAppBar(title: 'CERCA PRODOTTO', showSearchAction: false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outlineVariant, width: 1.5),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (value) => setState(() => _query = value),
                style: TextStyle(color: scheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Nome, marca, colore o codice PIM...',
                  hintStyle: TextStyle(color: scheme.onSurfaceVariant),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: scheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? Center(
                    child: Text(
                      'Digita per cercare tra tutti i prodotti',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  )
                : results.isEmpty
                    ? Center(
                        child: Text(
                          'Nessun prodotto trovato per "$_query"',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final (product, matchedCode) = results[index];
                          return _SearchResultTile(
                            product: product,
                            matchedCode: matchedCode,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final Product product;
  final String? matchedCode;

  const _SearchResultTile({required this.product, this.matchedCode});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset(
                  product.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.phone_iphone_rounded,
                    color: kBrandRed,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      matchedCode != null
                          ? '${product.brand} · Codice $matchedCode'
                          : '${product.brand} · ${product.category}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
