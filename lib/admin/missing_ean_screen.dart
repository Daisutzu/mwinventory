import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';
import '../catalog.dart';
import '../catalog_repository.dart';
import '../color_names.dart';
import '../product.dart';
import '../widgets/mw_app_bar.dart';

// Elenco, sempre aggiornato col catalogo corrente, di tutte le varianti
// (telefoni/tablet o PC) senza un EAN-13 associato: utile per sapere cosa
// manca ancora da recuperare. Si puo' inserire l'EAN direttamente da qui:
// viene salvato nel catalogo (e sincronizzato sugli altri dispositivi via
// Firestore) e il codice a barre si genera da solo nella scheda prodotto.
class _MissingEanEntry {
  final Product product;
  final String code;
  final String spec;
  final bool isPc;

  _MissingEanEntry({
    required this.product,
    required this.code,
    required this.spec,
    required this.isPc,
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
        isPc: false,
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
        isPc: true,
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

// Applica l'EAN alla sola variante con quel codice, lasciando le altre
// invariate: Product/ProductVariant/PcVariant sono immutabili, quindi si
// ricostruisce la lista varianti al posto di modificarla in place.
Product _applyEan(_MissingEanEntry entry, String ean) {
  final product = entry.product;
  if (entry.isPc) {
    return Product(
      id: product.id,
      name: product.name,
      brand: product.brand,
      category: product.category,
      imagePath: product.imagePath,
      variants: product.variants,
      pcVariants: product.pcVariants
          .map((v) => v.code != entry.code
              ? v
              : PcVariant(
                  cpu: v.cpu,
                  ram: v.ram,
                  storage: v.storage,
                  gpu: v.gpu,
                  screen: v.screen,
                  color: v.color,
                  code: v.code,
                  ean: ean,
                ))
          .toList(),
    );
  }
  return Product(
    id: product.id,
    name: product.name,
    brand: product.brand,
    category: product.category,
    imagePath: product.imagePath,
    pcVariants: product.pcVariants,
    variants: product.variants
        .map((v) => v.code != entry.code
            ? v
            : ProductVariant(
                storage: v.storage,
                color: v.color,
                code: v.code,
                ean: ean,
              ))
        .toList(),
  );
}

class MissingEanScreen extends StatefulWidget {
  const MissingEanScreen({super.key});

  @override
  State<MissingEanScreen> createState() => _MissingEanScreenState();
}

class _MissingEanScreenState extends State<MissingEanScreen> {
  Future<void> _editEan(_MissingEanEntry entry) async {
    final controller = TextEditingController();
    final scheme = Theme.of(context).colorScheme;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry.product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Codice PIM ${entry.code}${entry.spec.isEmpty ? '' : ' · ${entry.spec}'}',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 14,
              decoration: const InputDecoration(
                labelText: 'Codice EAN',
                hintText: 'es. 195950639414',
              ),
              onSubmitted: (value) => Navigator.pop(context, value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: TextButton.styleFrom(foregroundColor: kBrandRed),
            child: const Text('Salva'),
          ),
        ],
      ),
    );

    final raw = result?.trim();
    if (raw == null || raw.isEmpty || !mounted) return;
    // Alcuni EAN derivati da un UPC-A a 12 cifre arrivano senza lo zero
    // iniziale: stesso trattamento gia' usato per il resto del catalogo.
    final ean = raw.padLeft(13, '0');

    catalogRepository.upsert(_applyEan(entry, ean));
    setState(() {});

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('EAN salvato per ${entry.product.name}')),
    );
  }

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
          child: Material(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _editEan(entry),
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
                      '${entries.length} varianti senza EAN-13 · tocca per inserirlo',
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
