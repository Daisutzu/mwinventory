import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'catalog_repository.dart';
import 'color_names.dart';
import 'product.dart';
import 'search_history_repository.dart';
import 'widgets/generated_product_image.dart';
import 'widgets/mw_app_bar.dart';
import 'widgets/selector_chip.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product;
  String? selectedStorage;
  String? selectedColor;
  PcVariant? selectedPcVariant;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    searchHistoryRepository.recordView(_product.id);
    final storages = _product.availableStorages;
    if (storages.isNotEmpty) {
      selectedStorage = storages.first;
      final colors = _product.getColorsForStorage(selectedStorage!);
      if (colors.isNotEmpty) {
        selectedColor = colors.first;
      }
    }
    if (_product.pcVariants.isNotEmpty) {
      selectedPcVariant = _product.pcVariants.first;
    }
  }

  // Alcuni EAN-13 in catalogo sono in realta' un UPC-A (12 cifre, tipico
  // dei prodotti Apple made-in-USA) con uno "0" iniziale aggiunto per
  // uniformarli: e' un'equivalenza valida per il GS1, ma alcuni scanner
  // aziendali (es. EWA) si aspettano il codice a 12 cifre cosi' com'e'
  // stampato sulla confezione. Il tasto toglie lo zero e salva, cosi' il
  // codice a barre passa da EAN-13 a UPC-A senza dover ripassare da qui.
  void _removeLeadingZero(String targetCode, bool isPc, String currentEan) {
    final newEan = currentEan.substring(1);
    final updated = isPc
        ? Product(
            id: _product.id,
            name: _product.name,
            brand: _product.brand,
            category: _product.category,
            imagePath: _product.imagePath,
            variants: _product.variants,
            pcVariants: _product.pcVariants
                .map((v) => v.code != targetCode
                    ? v
                    : PcVariant(
                        cpu: v.cpu,
                        ram: v.ram,
                        storage: v.storage,
                        gpu: v.gpu,
                        screen: v.screen,
                        color: v.color,
                        code: v.code,
                        ean: newEan,
                      ))
                .toList(),
          )
        : Product(
            id: _product.id,
            name: _product.name,
            brand: _product.brand,
            category: _product.category,
            imagePath: _product.imagePath,
            pcVariants: _product.pcVariants,
            variants: _product.variants
                .map((v) => v.code != targetCode
                    ? v
                    : ProductVariant(
                        storage: v.storage,
                        color: v.color,
                        code: v.code,
                        ean: newEan,
                      ))
                .toList(),
          );

    catalogRepository.upsert(updated);
    setState(() {
      _product = updated;
      if (isPc) {
        selectedPcVariant =
            updated.pcVariants.firstWhere((v) => v.code == targetCode);
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Zero iniziale rimosso dall\'EAN')),
    );
  }

  void _onStorageSelected(String storage) {
    setState(() {
      selectedStorage = storage;
      final colors = widget.product.getColorsForStorage(storage);
      selectedColor = colors.isNotEmpty ? colors.first : null;
    });
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Codice $code copiato'),
        backgroundColor: const Color(0xFF1F2937),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, IconData icon, String label) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: muted,
          ),
        ),
      ],
    );
  }

  Widget _specPill(BuildContext context, IconData icon, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double value) =>
      '€ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

  Widget _priceSection(BuildContext context, double price, double? promoPrice) {
    final scheme = Theme.of(context).colorScheme;
    // In promozione solo se il prezzo promo e' effettivamente piu' basso di
    // quello di listino: il prezzo mostrato resta sempre quello originale,
    // barrato, con il promo in rosso accanto (richiesta esplicita).
    final hasPromo = promoPrice != null && promoPrice < price;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _formatPrice(price),
            style: TextStyle(
              fontSize: hasPromo ? 16 : 24,
              fontWeight: FontWeight.w700,
              color: hasPromo ? scheme.onSurfaceVariant : scheme.onSurface,
              decoration: hasPromo ? TextDecoration.lineThrough : null,
              decorationColor: scheme.onSurfaceVariant,
            ),
          ),
          if (hasPromo) ...[
            const SizedBox(width: 10),
            Text(
              _formatPrice(promoPrice),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'PROMO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pcConfigCard(BuildContext context, PcVariant variant) {
    final scheme = Theme.of(context).colorScheme;
    final selected = selectedPcVariant?.code == variant.code;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => selectedPcVariant = variant),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
                selected ? kBrandRed.withValues(alpha: 0.08) : scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? kBrandRed : scheme.outlineVariant,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (variant.cpu != null)
                _specPill(context, Icons.memory_rounded, variant.cpu!),
              if (variant.ram != null)
                _specPill(context, Icons.developer_board_rounded, variant.ram!),
              if (variant.storage != null)
                _specPill(context, Icons.sd_storage_rounded, variant.storage!),
              if (variant.gpu != null)
                _specPill(context, Icons.videogame_asset_rounded, variant.gpu!),
              if (variant.screen != null)
                _specPill(context, Icons.aspect_ratio_rounded, variant.screen!),
              if (variant.color != null)
                _specPill(context, Icons.palette_rounded, variant.color!),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final storages = product.availableStorages;
    final colors = selectedStorage != null
        ? product.getColorsForStorage(selectedStorage!)
        : <String>[];
    final isPc = product.pcVariants.isNotEmpty;
    final code = isPc
        ? selectedPcVariant?.code
        : (selectedStorage != null && selectedColor != null)
            ? product.getCode(selectedStorage!, selectedColor!)
            : null;
    final ean = isPc
        ? selectedPcVariant?.ean
        : (selectedStorage != null && selectedColor != null)
            ? product.getEan(selectedStorage!, selectedColor!)
            : null;
    // Se conosciamo l'EAN reale mostriamo quello: e' il formato che gli
    // scanner aziendali (es. EWA) sanno gia' leggere per giacenze/bollettina.
    // In assenza di EAN restiamo sul QR con il codice PIM interno. A 12
    // cifre e' un UPC-A (vedi _removeLeadingZero), a 13 un EAN-13 vero.
    final useEan = ean != null;
    final isUpcA = ean != null && ean.length == 12;
    final canRemoveLeadingZero =
        ean != null && ean.length == 13 && ean.startsWith('0');
    final barcodeValue = ean ?? code;
    final price = isPc
        ? selectedPcVariant?.price
        : (selectedStorage != null && selectedColor != null)
            ? product.getPrice(selectedStorage!, selectedColor!)
            : null;
    final promoPrice = isPc
        ? selectedPcVariant?.promoPrice
        : (selectedStorage != null && selectedColor != null)
            ? product.getPromoPrice(selectedStorage!, selectedColor!)
            : null;
    final scheme = Theme.of(context).colorScheme;
    final hasNoVariants = storages.isEmpty && !isPc;

    return Scaffold(
      appBar: MwAppBar(title: product.name),
      body: hasNoVariants
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Nessuna variante configurata per questo prodotto',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        product.brand,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: kBrandRed,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        '  ·  ${product.category}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 190,
                    width: double.infinity,
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
                    child: Center(
                      child: Hero(
                        tag: 'product-image-${product.id}',
                        child: Image.asset(
                          product.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              GeneratedProductImage(product: product),
                        ),
                      ),
                    ),
                  ),
                  if (price != null) ...[
                    const SizedBox(height: 16),
                    _priceSection(context, price, promoPrice),
                  ],
                  const SizedBox(height: 24),
                  if (isPc) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _sectionLabel(
                        context,
                        Icons.tune_rounded,
                        'CONFIGURAZIONE',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: product.pcVariants
                          .map(
                            (variant) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _pcConfigCard(context, variant),
                            ),
                          )
                          .toList(),
                    ),
                  ] else ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _sectionLabel(
                        context,
                        Icons.sd_storage_rounded,
                        'MEMORIA',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: storages.map((storage) {
                        return SelectorChip(
                          label: storage,
                          selected: storage == selectedStorage,
                          onTap: () => _onStorageSelected(storage),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _sectionLabel(
                        context,
                        Icons.palette_rounded,
                        'COLORE',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: colors.map((color) {
                        return SelectorChip(
                          label: colorDisplayName(color),
                          selected: color == selectedColor,
                          onTap: () => setState(() => selectedColor = color),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 28),
                  if (barcodeValue != null) ...[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: scheme.outlineVariant,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: scheme.brightness == Brightness.dark
                                  ? 0.3
                                  : 0.05,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        child: Column(
                          children: [
                            _sectionLabel(
                              context,
                              Icons.qr_code_2_rounded,
                              'CODICE PRODOTTO',
                            ),
                            const SizedBox(height: 18),
                            // Lo sfondo del QR resta bianco fisso (non segue
                            // il tema): un QR chiaro su scuro puo' non essere
                            // leggibile da tutti gli scanner.
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFF0F1F3),
                                  width: 1,
                                ),
                              ),
                              child: BarcodeWidget(
                                barcode: !useEan
                                    ? Barcode.qrCode()
                                    : isUpcA
                                        ? Barcode.upcA()
                                        : Barcode.ean13(),
                                data: barcodeValue,
                                width: useEan ? 240 : 190,
                                height: useEan ? 110 : 190,
                                drawText: useEan,
                                color: const Color(0xFF1F2937),
                                errorBuilder: (context, error) => const Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Text(
                                      'Impossibile generare il codice a barre'),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => _copyCode(barcodeValue),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          barcodeValue,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 4,
                                            color: scheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        Icons.copy_rounded,
                                        size: 18,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tocca il codice per copiarlo',
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            if (canRemoveLeadingZero) ...[
                              const SizedBox(height: 12),
                              TextButton.icon(
                                onPressed: () => _removeLeadingZero(
                                  code!,
                                  isPc,
                                  ean,
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: kBrandRed,
                                ),
                                icon: const Icon(
                                  Icons.exposure_zero_rounded,
                                  size: 18,
                                ),
                                label: const Text('Rimuovi lo 0 iniziale'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
