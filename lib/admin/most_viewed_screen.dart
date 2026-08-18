import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../catalog.dart';
import '../product.dart';
import '../product_detail_screen.dart';
import '../search_history_repository.dart';
import '../widgets/mw_app_bar.dart';

// Classifica dei prodotti aperti piu' spesso: usa il conteggio aggregato su
// Firestore (tutti i dispositivi del negozio) quando disponibile, altrimenti
// ricade su quello solo locale (offline, o cloud non abilitato come nei
// test). Solo consultazione, nessuna azione da fare qui.
class _RankedProduct {
  final Product product;
  final int count;
  _RankedProduct(this.product, this.count);
}

List<_RankedProduct> _rankProducts(Map<String, int> counts) {
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

class MostViewedScreen extends StatefulWidget {
  const MostViewedScreen({super.key});

  @override
  State<MostViewedScreen> createState() => _MostViewedScreenState();
}

class _MostViewedScreenState extends State<MostViewedScreen> {
  bool _loading = true;
  bool _isAggregated = false;
  List<_RankedProduct> _ranked = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final aggregated = await searchHistoryRepository.fetchAggregatedViewCounts();
    final counts = aggregated ?? searchHistoryRepository.getViewCounts();
    if (!mounted) return;
    setState(() {
      _ranked = _rankProducts(counts);
      _isAggregated = aggregated != null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const MwAppBar(
        title: 'PRODOTTI PIÙ CERCATI',
        showSearchAction: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _ranked.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Nessun dato ancora: la classifica si popola man '
                      'mano che si aprono le schede prodotto.',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
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
                          _isAggregated
                              ? 'Aggregato su tutti i dispositivi del negozio'
                              : 'Solo questo dispositivo (aggregazione non disponibile ora)',
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
                        itemCount: _ranked.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final entry = _ranked[index];
                          return Material(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailScreen(
                                      product: entry.product,
                                    ),
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
                                          color:
                                              scheme.surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(8),
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
