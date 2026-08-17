import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../catalog.dart';
import '../color_names.dart';
import '../product.dart';
import '../product_detail_screen.dart';
import '../widgets/mw_app_bar.dart';

// Elenco, sempre aggiornato col catalogo corrente, di tutte le varianti
// senza un prezzo: prodotti nuovi che lo scraper non ha ancora processato,
// o PIM che MediaWorld non trova piu' (fuori catalogo, cambiati, ecc.).
// A differenza dei prodotti senza EAN, qui non si inserisce nulla a mano:
// il prezzo arriva solo dallo scraper automatico, questa schermata serve
// solo a capire cosa manca e aprire la scheda prodotto per verificare.
class _MissingPriceEntry {
  final Product product;
  final String code;
  final String spec;

  _MissingPriceEntry({
    required this.product,
    required this.code,
    required this.spec,
  });
}

List<_MissingPriceEntry> _collectMissingPrice() {
  final entries = <_MissingPriceEntry>[];
  for (final product in sampleProducts) {
    for (final variant in product.variants) {
      if (variant.price != null) continue;
      entries.add(_MissingPriceEntry(
        product: product,
        code: variant.code,
        spec: '${variant.storage} ${colorDisplayName(variant.color)}'.trim(),
      ));
    }
    for (final variant in product.pcVariants) {
      if (variant.price != null) continue;
      final parts = [
        variant.cpu,
        variant.ram,
        variant.storage,
        variant.color,
      ].whereType<String>();
      entries.add(_MissingPriceEntry(
        product: product,
        code: variant.code,
        spec: parts.join(' '),
      ));
    }
  }
  entries.sort((a, b) {
    final brand = a.product.brand.compareTo(b.product.brand);
    if (brand != 0) return brand;
    final name = a.product.name.compareTo(b.product.name);
    if (name != 0) return name;
    return a.code.compareTo(b.code);
  });
  return entries;
}

class MissingPriceScreen extends StatelessWidget {
  const MissingPriceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final entries = _collectMissingPrice();

    final children = <Widget>[];
    String? currentBrand;
    for (final entry in entries) {
      if (entry.product.brand != currentBrand) {
        currentBrand = entry.product.brand;
        if (children.isNotEmpty) children.add(const SizedBox(height: 4));
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
            child: Text(
              currentBrand.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: kBrandRed,
              ),
            ),
          ),
        );
      }
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
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
                  border: Border.all(color: scheme.outlineVariant, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            if (entry.spec.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                entry.spec,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.code,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const MwAppBar(
        title: 'PRODOTTI SENZA PREZZO',
        showSearchAction: false,
      ),
      body: entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Tutti i prodotti del catalogo hanno un prezzo.',
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
                      '${entries.length} varianti senza prezzo · lo scraper li aggiorna ogni notte',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: children,
                  ),
                ),
              ],
            ),
    );
  }
}
