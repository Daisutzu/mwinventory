import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../catalog_repository.dart';
import '../product.dart';
import '../widgets/mw_app_bar.dart';

const _categories = ['Telefonia', 'PC', 'TV', 'Gaming'];

// Rappresentazione modificabile di una variante mentre si compila il form:
// niente TextEditingController per riga (troppi da gestire/smaltire), solo
// stringhe semplici aggiornate via onChanged e ridisegnate col setState.
class _PhoneVariantDraft {
  String storage;
  String color;
  String code;
  String ean;
  _PhoneVariantDraft({
    this.storage = '',
    this.color = '',
    this.code = '',
    this.ean = '',
  });
}

class _PcVariantDraft {
  String cpu;
  String ram;
  String storage;
  String gpu;
  String screen;
  String color;
  String code;
  String ean;
  _PcVariantDraft({
    this.cpu = '',
    this.ram = '',
    this.storage = '',
    this.gpu = '',
    this.screen = '',
    this.color = '',
    this.code = '',
    this.ean = '',
  });
}

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  late String _category;
  late final TextEditingController _brandController;
  late final TextEditingController _nameController;
  late final TextEditingController _imagePathController;
  final List<_PhoneVariantDraft> _phoneVariants = [];
  final List<_PcVariantDraft> _pcVariants = [];

  bool get _isEditing => widget.product != null;
  bool get _isPhoneStyle => _category == 'Telefonia';

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _category = p?.category ?? _categories.first;
    _brandController = TextEditingController(text: p?.brand ?? '');
    _nameController = TextEditingController(text: p?.name ?? '');
    _imagePathController = TextEditingController(text: p?.imagePath ?? '');
    if (p != null) {
      for (final v in p.variants) {
        _phoneVariants.add(
          _PhoneVariantDraft(
            storage: v.storage,
            color: v.color,
            code: v.code,
            ean: v.ean ?? '',
          ),
        );
      }
      for (final v in p.pcVariants) {
        _pcVariants.add(
          _PcVariantDraft(
            cpu: v.cpu ?? '',
            ram: v.ram ?? '',
            storage: v.storage ?? '',
            gpu: v.gpu ?? '',
            screen: v.screen ?? '',
            color: v.color ?? '',
            code: v.code,
            ean: v.ean ?? '',
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _nameController.dispose();
    _imagePathController.dispose();
    super.dispose();
  }

  String _slugPath() {
    final slug = (_brandController.text + _nameController.text)
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '');
    return 'assets/products/$slug.png';
  }

  void _save() {
    final name = _nameController.text.trim();
    final brand = _brandController.text.trim();
    if (name.isEmpty || brand.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome e marca sono obbligatori')),
      );
      return;
    }
    final imagePath = _imagePathController.text.trim().isEmpty
        ? _slugPath()
        : _imagePathController.text.trim();

    final variants = _phoneVariants
        .where((v) =>
            v.storage.isNotEmpty && v.color.isNotEmpty && v.code.isNotEmpty)
        .map((v) => ProductVariant(
              storage: v.storage,
              color: v.color,
              code: v.code,
              ean: v.ean.isEmpty ? null : v.ean,
            ))
        .toList();
    final pcVariants = _pcVariants
        .where((v) => v.code.isNotEmpty)
        .map(
          (v) => PcVariant(
            code: v.code,
            cpu: v.cpu.isEmpty ? null : v.cpu,
            ram: v.ram.isEmpty ? null : v.ram,
            storage: v.storage.isEmpty ? null : v.storage,
            gpu: v.gpu.isEmpty ? null : v.gpu,
            screen: v.screen.isEmpty ? null : v.screen,
            color: v.color.isEmpty ? null : v.color,
            ean: v.ean.isEmpty ? null : v.ean,
          ),
        )
        .toList();

    final id =
        widget.product?.id ?? 'custom_${DateTime.now().microsecondsSinceEpoch}';
    final product = Product(
      id: id,
      name: name,
      brand: brand,
      category: _category,
      imagePath: imagePath,
      variants: variants,
      pcVariants: pcVariants,
    );
    // Niente await: Hive aggiorna la mappa in memoria in modo sincrono
    // dentro put(), il Future restituito segue solo il flush su disco.
    // Aspettarlo prima di chiudere lo schermo non serve e nei test non si
    // risolve mai in tempo utile.
    catalogRepository.upsert(product);
    Navigator.pop(context, true);
  }

  Widget _fieldLabel(BuildContext context, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: scheme.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  InputDecoration _decoration(BuildContext context, {String? hint}) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: scheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kBrandRed, width: 1.5),
      ),
    );
  }

  Widget _smallField(
    BuildContext context, {
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      width: 130,
      child: TextFormField(
        initialValue: value,
        onChanged: onChanged,
        decoration: _decoration(context, hint: label),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _phoneVariantCard(int index) {
    final scheme = Theme.of(context).colorScheme;
    final v = _phoneVariants[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _smallField(
                  context,
                  label: 'Memoria',
                  value: v.storage,
                  onChanged: (val) => v.storage = val,
                ),
                _smallField(
                  context,
                  label: 'Colore',
                  value: v.color,
                  onChanged: (val) => v.color = val,
                ),
                _smallField(
                  context,
                  label: 'Codice PIM',
                  value: v.code,
                  onChanged: (val) => v.code = val,
                ),
                _smallField(
                  context,
                  label: 'EAN-13 (opzionale)',
                  value: v.ean,
                  onChanged: (val) => v.ean = val,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: scheme.onSurfaceVariant),
            onPressed: () => setState(() => _phoneVariants.removeAt(index)),
          ),
        ],
      ),
    );
  }

  Widget _pcVariantCard(int index) {
    final scheme = Theme.of(context).colorScheme;
    final v = _pcVariants[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _smallField(context,
                    label: 'CPU',
                    value: v.cpu,
                    onChanged: (val) => v.cpu = val),
                _smallField(context,
                    label: 'RAM',
                    value: v.ram,
                    onChanged: (val) => v.ram = val),
                _smallField(
                  context,
                  label: 'Storage',
                  value: v.storage,
                  onChanged: (val) => v.storage = val,
                ),
                _smallField(context,
                    label: 'GPU',
                    value: v.gpu,
                    onChanged: (val) => v.gpu = val),
                _smallField(
                  context,
                  label: 'Schermo',
                  value: v.screen,
                  onChanged: (val) => v.screen = val,
                ),
                _smallField(
                  context,
                  label: 'Colore',
                  value: v.color,
                  onChanged: (val) => v.color = val,
                ),
                _smallField(
                  context,
                  label: 'Codice PIM',
                  value: v.code,
                  onChanged: (val) => v.code = val,
                ),
                _smallField(
                  context,
                  label: 'EAN-13 (opzionale)',
                  value: v.ean,
                  onChanged: (val) => v.ean = val,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: scheme.onSurfaceVariant),
            onPressed: () => setState(() => _pcVariants.removeAt(index)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: MwAppBar(
        title: _isEditing ? 'MODIFICA PRODOTTO' : 'NUOVO PRODOTTO',
        showSearchAction: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _fieldLabel(context, 'CATEGORIA'),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: _decoration(context),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 16),
            _fieldLabel(context, 'MARCA'),
            TextFormField(
              controller: _brandController,
              decoration: _decoration(context, hint: 'es. Apple'),
            ),
            const SizedBox(height: 16),
            _fieldLabel(context, 'NOME PRODOTTO'),
            TextFormField(
              controller: _nameController,
              decoration: _decoration(context, hint: 'es. iPhone 17'),
            ),
            const SizedBox(height: 16),
            _fieldLabel(context, 'PERCORSO IMMAGINE (opzionale)'),
            TextFormField(
              controller: _imagePathController,
              decoration: _decoration(
                context,
                hint: 'assets/products/....png (auto se vuoto)',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isPhoneStyle
                      ? 'VARIANTI (memoria/colore)'
                      : 'CONFIGURAZIONI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 0.3,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() {
                    if (_isPhoneStyle) {
                      _phoneVariants.add(_PhoneVariantDraft());
                    } else {
                      _pcVariants.add(_PcVariantDraft());
                    }
                  }),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Aggiungi'),
                  style: TextButton.styleFrom(foregroundColor: kBrandRed),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isPhoneStyle)
              for (var i = 0; i < _phoneVariants.length; i++)
                _phoneVariantCard(i)
            else
              for (var i = 0; i < _pcVariants.length; i++) _pcVariantCard(i),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kBrandRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                    _isEditing ? 'Salva modifiche' : 'Aggiungi al catalogo'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
