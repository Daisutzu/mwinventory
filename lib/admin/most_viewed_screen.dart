import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../catalog.dart';
import '../product.dart';
import '../product_detail_screen.dart';
import '../search_history_repository.dart';
import '../widgets/mw_app_bar.dart';

// Classifica dei prodotti aperti piu' spesso su QUESTO dispositivo (dato
// locale, non aggregato tra dispositivi): utile per capire cosa i clienti
// chiedono davvero senza dover fare domande in giro. Solo consultazione,
// nessuna azione da fare qui.
class _RankedProduct {
  final Product product;
  final int count;
  _RankedProduct(this.product, this.count);
}

List<_RankedProduct> _rankProducts() {
  final counts = searchHistoryRepository.getViewCounts();
  final ranked = <_RankedProduct>[];
  for (final entry in counts.entries) {
    Product? product;
    for (final p in sampleProducts) {
      if (p.id == entry.key) {
        product = p;
        break;
      }
    }
    // Un prodotto puo' essere stato eliminato dal catalogo dopo essere
    // stato visualizzato: l'id resta orfano nel conteggio, lo ignoriamo.
    if (product != null) {
      ranked.add(_RankedProduct(product, entry.value));
    }
  }
  ranked.sort((a, b) => b.count.compareTo(a.count));
  return ranked;
}

class MostViewedScreen extends StatelessWidget {
  const MostViewedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ranked = _rankProducts();

    return Scaffold(
      appBar: const MwAppBar(
        title: 'PRODOTTI PIÙ CERCATI',
        showSearchAction: false,
      ),
      body: ranked.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Nessun dato ancora: la classifica si popola man mano '
                  'che si aprono le schede prodotto su questo dispositivo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Basato sulle aperture scheda su questo dispositivo',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: ranked.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = ranked[index];
                      return Material(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailScreen(product: entry.product),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: scheme.outlineVariant),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 28,
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: index < 3
                                            ? kBrandRed
                                            : scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: scheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          '${entry.product.brand} · ${entry.product.category}',
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: scheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      entry.count == 1
                                          ? '1 apertura'
                                          : '${entry.count} aperture',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: scheme.onSurface,
                                      ),
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
              ],
            ),
    );
  }
}
