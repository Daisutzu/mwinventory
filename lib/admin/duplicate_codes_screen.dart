import 'package:flutter/material.dart';
import '../catalog.dart';
import '../color_names.dart';
import '../product.dart';
import '../product_detail_screen.dart';
import '../widgets/mw_app_bar.dart';

// Controllo di integrita' del catalogo: un PIM o un EAN devono identificare
// UNA sola variante. Con quasi 800 codici inseriti tramite tanti import
// diversi nel tempo, un duplicato per errore di battitura o copia-incolla
// e' plausibile, e confonderebbe proprio lo scanner (due prodotti diversi
// che rispondono allo stesso codice). Solo consultazione: la correzione si
// fa dalla scheda del prodotto o dal form di modifica.
class _DuplicateItem {
  final Product product;
  final String spec;
  _DuplicateItem(this.product, this.spec);
}

class _DuplicateGroup {
  final String kind; // 'PIM' o 'EAN'
  final String value;
  final List<_DuplicateItem> items;
  _DuplicateGroup(this.kind, this.value, this.items);
}

List<_DuplicateGroup> _collectDuplicates() {
  final byCode = <String, List<_DuplicateItem>>{};
  final byEan = <String, List<_DuplicateItem>>{};

  for (final product in sampleProducts) {
    for (final v in product.variants) {
      final spec = '${v.storage} ${colorDisplayName(v.color)}'.trim();
      byCode.putIfAbsent(v.code, () => []).add(_DuplicateItem(product, spec));
      if (v.ean != null && v.ean!.isNotEmpty) {
        byEan.putIfAbsent(v.ean!, () => []).add(_DuplicateItem(product, spec));
      }
    }
    for (final v in product.pcVariants) {
      final spec = [v.cpu, v.ram, v.storage, v.gpu, v.color]
          .whereType<String>()
          .join(' ');
      byCode.putIfAbsent(v.code, () => []).add(_DuplicateItem(product, spec));
      if (v.ean != null && v.ean!.isNotEmpty) {
        byEan.putIfAbsent(v.ean!, () => []).add(_DuplicateItem(product, spec));
      }
    }
  }

  final groups = <_DuplicateGroup>[];
  byCode.forEach((code, items) {
    if (items.length > 1) groups.add(_DuplicateGroup('PIM', code, items));
  });
  byEan.forEach((ean, items) {
    if (items.length > 1) groups.add(_DuplicateGroup('EAN', ean, items));
  });
  groups.sort((a, b) {
    final k = a.kind.compareTo(b.kind);
    if (k != 0) return k;
    return a.value.compareTo(b.value);
  });
  return groups;
}

class DuplicateCodesScreen extends StatelessWidget {
  const DuplicateCodesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final groups = _collectDuplicates();

    return Scaffold(
      appBar: const MwAppBar(
        title: 'CODICI DUPLICATI',
        showSearchAction: false,
      ),
      body: groups.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Nessun PIM o EAN duplicato nel catalogo.',
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
                      '${groups.length} codici usati su più varianti · tocca un prodotto per aprirlo',
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
                    itemCount: groups.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: scheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: scheme.error.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      size: 16, color: scheme.error),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${group.kind} ${group.value}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: scheme.error,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${group.items.length}× usato',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            for (final item in group.items)
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailScreen(
                                        product: item.product,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.product.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: scheme.onSurface,
                                              ),
                                            ),
                                            if (item.spec.isNotEmpty)
                                              Text(
                                                '${item.product.brand} · ${item.spec}',
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
                          ],
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
