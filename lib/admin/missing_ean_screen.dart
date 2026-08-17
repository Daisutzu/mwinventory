import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../catalog.dart';
import '../color_names.dart';
import '../product.dart';
import '../widgets/mw_app_bar.dart';

// Elenco, sempre aggiornato col catalogo corrente, di tutte le varianti
// (telefoni/tablet o PC) senza un EAN-13 associato: utile per sapere cosa
// manca ancora da recuperare, senza dover rigenerare un report a parte.
class _MissingEanEntry {
  final Product product;
  final String code;
  final String spec;

  _MissingEanEntry({
    required this.product,
    required this.code,
    required this.spec,
  });
}

List<_MissingEanEntry> _collectMissingEan() {
  final entries = <_MissingEanEntry>[];
  for (final product in sampleProducts) {
    for (final variant in product.variants) {
      if (variant.ean != null) continue;
      entries.add(_MissingEanEntry(
        product: product,
        code: variant.code,
        spec: '${variant.storage} ${colorDisplayName(variant.color)}'.trim(),
      ));
    }
    for (final variant in product.pcVariants) {
      if (variant.ean != null) continue;
      final parts = [
        variant.cpu,
        variant.ram,
        variant.storage,
        variant.color,
      ].whereType<String>();
      entries.add(_MissingEanEntry(
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

class MissingEanScreen extends StatelessWidget {
  const MissingEanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final entries = _collectMissingEan();

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
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outlineVariant, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const MwAppBar(
        title: 'PRODOTTI SENZA EAN',
        showSearchAction: false,
      ),
      body: entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Tutti i prodotti del catalogo hanno un EAN-13.',
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
                      '${entries.length} varianti senza EAN-13',
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
