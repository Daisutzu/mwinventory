import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'catalog.dart';
import 'category_style.dart';
import 'color_names.dart';
import 'pc_spec_utils.dart';
import 'product.dart';
import 'product_detail_screen.dart';
import 'scan_screen.dart';
import 'widgets/mw_app_bar.dart';
import 'widgets/selector_chip.dart';

class SearchProductsScreen extends StatefulWidget {
  const SearchProductsScreen({super.key});

  @override
  State<SearchProductsScreen> createState() => _SearchProductsScreenState();
}

// PC e PC Fissi condividono lo stesso modello di specifiche (CPU/RAM/
// storage), quindi i filtri si applicano a entrambe le categorie.
bool _isPcCategory(String category) =>
    category == 'PC' || category == 'PC Fissi';

class _SearchProductsScreenState extends State<SearchProductsScreen> {
  final _controller = TextEditingController();
  String _query = '';
  bool _filtersExpanded = false;
  final Set<String> _selectedFamilies = {};
  final Set<String> _selectedRam = {};
  final Set<String> _selectedStorage = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _filtersActive =>
      _selectedFamilies.isNotEmpty ||
      _selectedRam.isNotEmpty ||
      _selectedStorage.isNotEmpty;

  List<String> get _availableFamilies {
    final present = <String>{};
    for (final p in sampleProducts.where((p) => _isPcCategory(p.category))) {
      for (final v in p.pcVariants) {
        final f = cpuFamily(v.cpu);
        if (f != null) present.add(f);
      }
    }
    return kCpuFamilyOrder.where(present.contains).toList();
  }

  List<String> get _availableRam {
    final present = <String>{};
    for (final p in sampleProducts.where((p) => _isPcCategory(p.category))) {
      for (final v in p.pcVariants) {
        if (v.ram != null) present.add(v.ram!);
      }
    }
    final list = present.toList();
    list.sort((a, b) => sizeInGb(a).compareTo(sizeInGb(b)));
    return list;
  }

  List<String> get _availableStorage {
    final present = <String>{};
    for (final p in sampleProducts.where((p) => _isPcCategory(p.category))) {
      for (final v in p.pcVariants) {
        if (v.storage != null) present.add(v.storage!);
      }
    }
    final list = present.toList();
    list.sort((a, b) => sizeInGb(a).compareTo(sizeInGb(b)));
    return list;
  }

  Future<void> _scan() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const ScanScreen()),
    );
    if (result == null || !mounted) return;
    _controller.text = result;
    setState(() => _query = result);
  }

  void _clearFilters() {
    setState(() {
      _selectedFamilies.clear();
      _selectedRam.clear();
      _selectedStorage.clear();
    });
  }

  // Per ogni prodotto trovato, tiene traccia anche di quale codice ha
  // fatto scattare il match (per testo o per filtro), cosi' possiamo
  // mostrarlo subito nel risultato invece di farlo ricercare all'utente.
  List<(Product, String?)> _search() {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty && !_filtersActive) return [];

    final results = <(Product, String?)>[];
    for (final product in sampleProducts) {
      if (_filtersActive && !_isPcCategory(product.category)) continue;

      String? filterMatchedCode;
      if (_filtersActive) {
        for (final variant in product.pcVariants) {
          final familyOk = _selectedFamilies.isEmpty ||
              _selectedFamilies.contains(cpuFamily(variant.cpu));
          final ramOk =
              _selectedRam.isEmpty || _selectedRam.contains(variant.ram);
          final storageOk = _selectedStorage.isEmpty ||
              _selectedStorage.contains(variant.storage);
          if (familyOk && ramOk && storageOk) {
            filterMatchedCode = variant.code;
            break;
          }
        }
        if (filterMatchedCode == null) continue;
      }

      var textOk = q.isEmpty;
      String? textMatchedCode;
      if (!textOk) {
        final nameMatch = product.name.toLowerCase().contains(q);
        final brandMatch = product.brand.toLowerCase().contains(q);
        for (final variant in product.variants) {
          if (variant.code.toLowerCase().contains(q) ||
              (variant.ean?.toLowerCase().contains(q) ?? false) ||
              colorDisplayName(variant.color).toLowerCase().contains(q)) {
            textMatchedCode = variant.code;
            break;
          }
        }
        if (textMatchedCode == null) {
          for (final variant in product.pcVariants) {
            final specMatch = [
              variant.cpu,
              variant.ram,
              variant.storage,
              variant.gpu,
            ].whereType<String>().any((s) => s.toLowerCase().contains(q));
            if (variant.code.toLowerCase().contains(q) ||
                (variant.ean?.toLowerCase().contains(q) ?? false) ||
                specMatch) {
              textMatchedCode = variant.code;
              break;
            }
          }
        }
        textOk = nameMatch || brandMatch || textMatchedCode != null;
      }
      if (!textOk) continue;

      results.add((product, filterMatchedCode ?? textMatchedCode));
    }
    return results;
  }

  Widget _filterGroup(
    String label,
    List<String> options,
    Set<String> selected,
  ) {
    if (options.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              return SelectorChip(
                label: option,
                selected: selected.contains(option),
                onTap: () => setState(() {
                  if (!selected.add(option)) selected.remove(option);
                }),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final results = _search();
    final activeFilterCount = _selectedFamilies.length +
        _selectedRam.length +
        _selectedStorage.length;

    return Scaffold(
      appBar: const MwAppBar(title: 'CERCA PRODOTTO', showSearchAction: false),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: scheme.outlineVariant,
                        width: 1.5,
                      ),
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
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: scheme.outlineVariant,
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    tooltip: 'Scansiona QR/codice a barre',
                    icon: Icon(
                      Icons.qr_code_scanner_rounded,
                      color: scheme.onSurfaceVariant,
                    ),
                    onPressed: _scan,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _filtersActive ? kBrandRed : scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _filtersActive ? kBrandRed : scheme.outlineVariant,
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        tooltip: 'Filtri PC',
                        icon: Icon(
                          Icons.tune_rounded,
                          color: _filtersActive
                              ? Colors.white
                              : scheme.onSurfaceVariant,
                        ),
                        onPressed: () => setState(
                            () => _filtersExpanded = !_filtersExpanded),
                      ),
                      if (activeFilterCount > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$activeFilterCount',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: kBrandRed,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                if (_filtersExpanded)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: scheme.outlineVariant,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'FILTRI PC',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                                color: scheme.onSurface,
                              ),
                            ),
                            if (_filtersActive)
                              TextButton(
                                onPressed: _clearFilters,
                                style: TextButton.styleFrom(
                                  foregroundColor: kBrandRed,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Cancella filtri'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _filterGroup(
                          'PROCESSORE',
                          _availableFamilies,
                          _selectedFamilies,
                        ),
                        _filterGroup('RAM', _availableRam, _selectedRam),
                        _filterGroup(
                          'ARCHIVIAZIONE',
                          _availableStorage,
                          _selectedStorage,
                        ),
                      ],
                    ),
                  ),
                if (_filtersExpanded) const SizedBox(height: 12),
                if (_query.isEmpty && !_filtersActive)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Center(
                      child: Text(
                        'Digita per cercare tra tutti i prodotti\no usa i filtri per i PC',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  )
                else if (results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Center(
                      child: Text(
                        _query.isEmpty
                            ? 'Nessun PC corrisponde ai filtri selezionati'
                            : 'Nessun prodotto trovato per "$_query"',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  for (final (product, matchedCode) in results)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SearchResultTile(
                        product: product,
                        matchedCode: matchedCode,
                      ),
                    ),
              ],
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
                  errorBuilder: (context, error, stackTrace) => Icon(
                    categoryIcon(product.category),
                    color: categoryColor(product.category),
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
