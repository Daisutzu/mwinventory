import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../app_colors.dart';
import '../catalog.dart';
import '../catalog_repository.dart';
import '../color_names.dart';
import '../product.dart';
import '../widgets/mw_app_bar.dart';

// Importazione massiva: incolla un elenco "PIM | EAN | Marchio | Modello"
// (lo stesso formato usato finora per i cataloghi) e lo trasforma in
// prodotti pronti da salvare. Il riconoscimento di memoria/colore (per
// Telefonia/Tablet) e di CPU/RAM/storage/GPU tra parentesi (per PC/PC
// Fissi) e' automatico ma non infallibile: per questo c'e' sempre
// un'anteprima da controllare prima di confermare, e quel che non viene
// riconosciuto resta comunque importato (solo con meno dettagli), mai
// scartato in silenzio.
//
// In alternativa al testo si puo' fotografare un elenco stampato: il
// riconoscimento testo (solo Android/iOS, non disponibile sul web) legge
// la foto e riempie lo stesso campo, cosi' resta comunque il controllo
// dell'anteprima prima di importare - l'accuratezza dipende dalla qualita'
// della foto e da quanto l'elenco fotografato somiglia al formato a
// colonne PIM/EAN/Marchio/Modello.

const _categories = [
  'Telefonia',
  'Tablet',
  'PC',
  'PC Fissi',
  'TV',
  'Console',
  'Accessori',
];

bool _isPhoneStyle(String category) =>
    category == 'Telefonia' || category == 'Tablet' || category == 'Accessori';

final _parenRe = RegExp(r'\(([^)]*)\)\s*$');
final _ramStorageRe = RegExp(r'(\d+)\+(\d+)\s*(GB|TB)?', caseSensitive: false);
final _storageOnlyRe = RegExp(r'(\d+)\s*(GB|TB)\b', caseSensitive: false);

String _collapseSpaces(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

class _PhoneExtract {
  final String base;
  final String storage;
  final String color;
  _PhoneExtract(this.base, this.storage, this.color);
}

_PhoneExtract _extractPhoneStyle(String text) {
  String base = text;
  String? storage;

  final m1 = _ramStorageRe.firstMatch(base);
  if (m1 != null) {
    final unit = (m1.group(3) ?? 'GB').toUpperCase();
    storage = '${m1.group(1)}GB+${m1.group(2)}$unit';
    base = _collapseSpaces(base.substring(0, m1.start) + base.substring(m1.end));
  } else {
    final m2 = _storageOnlyRe.firstMatch(base);
    if (m2 != null) {
      storage = '${m2.group(1)}${m2.group(2)!.toUpperCase()}';
      base =
          _collapseSpaces(base.substring(0, m2.start) + base.substring(m2.end));
    }
  }

  String? color;
  final tokens = base.split(' ');
  if (tokens.isNotEmpty) {
    final last = tokens.last;
    if (colorNames.containsKey(last.toUpperCase())) {
      color = last;
      base = _collapseSpaces(tokens.sublist(0, tokens.length - 1).join(' '));
    }
  }

  return _PhoneExtract(base, storage ?? 'Standard', color ?? 'Standard');
}

class _PcExtract {
  final String base;
  final String? cpu;
  final String? ram;
  final String? storage;
  final String? gpu;
  _PcExtract(this.base, this.cpu, this.ram, this.storage, this.gpu);
}

_PcExtract _extractPcStyle(String text) {
  final m = _parenRe.firstMatch(text);
  if (m == null) return _PcExtract(text.trim(), null, null, null, null);

  final base = text.substring(0, m.start).trim();
  final tokens = m.group(1)!.trim().split(RegExp(r'\s+'));
  if (tokens.isEmpty || tokens.first.isEmpty) {
    return _PcExtract(base, null, null, null, null);
  }

  final cpu = tokens.first;
  String? ram;
  String? storage;
  if (tokens.length > 1) {
    final rs =
        RegExp(r'^(\d+)/(\d+)(GB|TB)?$', caseSensitive: false).firstMatch(tokens[1]);
    if (rs != null) {
      ram = '${rs.group(1)}GB';
      storage = '${rs.group(2)}${(rs.group(3) ?? 'GB').toUpperCase()}';
    }
  }
  final gpu = tokens.length > 2 ? tokens.sublist(2).join(' ') : null;

  return _PcExtract(base, cpu, ram, storage, gpu);
}

class _ParsedLine {
  final String brand;
  final String pim;
  final String? ean;
  final String rawModel;
  _ParsedLine({
    required this.brand,
    required this.pim,
    required this.ean,
    required this.rawModel,
  });
}

List<_ParsedLine> _parseLines(String text) {
  final lines = <_ParsedLine>[];
  for (final raw in text.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    if (RegExp(r'^#+$').hasMatch(line.replaceAll(' ', ''))) continue;

    var parts = line.split('|').map((p) => p.trim()).toList();
    if (parts.length != 4) {
      // Foto/testo senza "|" (es. colonne di un elenco stampato riletto
      // con la fotocamera): si prova con tabulazioni o almeno due spazi,
      // che di solito segnano il confine tra una colonna e l'altra.
      final fallback = line
          .split(RegExp(r'\t+|\s{2,}'))
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();
      if (fallback.length == 4) parts = fallback;
    }
    if (parts.length != 4) continue;

    final pim = parts[0];
    if (!RegExp(r'^\d+$').hasMatch(pim)) continue;
    final eanRaw = parts[1];
    final ean = RegExp(r'^\d+$').hasMatch(eanRaw) ? eanRaw.padLeft(13, '0') : null;
    lines.add(_ParsedLine(
      brand: parts[2],
      pim: pim,
      ean: ean,
      rawModel: parts[3],
    ));
  }
  return lines;
}

Set<String> _existingCatalogCodes() {
  final codes = <String>{};
  for (final product in sampleProducts) {
    for (final v in product.variants) {
      codes.add(v.code);
    }
    for (final v in product.pcVariants) {
      codes.add(v.code);
    }
  }
  return codes;
}

String _slug(String brand, String name) {
  final s = (brand + name).toLowerCase().replaceAll('+', 'plus');
  return s.replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

List<Product> _buildProducts(List<_ParsedLine> lines, String category) {
  final byKey = <String, Product>{};
  final order = <String>[];
  final now = DateTime.now().microsecondsSinceEpoch;
  var i = 0;

  for (final line in lines) {
    i++;
    final String base;
    ProductVariant? variant;
    PcVariant? pcVariant;

    if (_isPhoneStyle(category)) {
      final e = _extractPhoneStyle(line.rawModel);
      base = e.base;
      variant = ProductVariant(
        storage: e.storage,
        color: e.color,
        code: line.pim,
        ean: line.ean,
      );
    } else {
      final e = _extractPcStyle(line.rawModel);
      base = e.base;
      pcVariant = PcVariant(
        cpu: e.cpu,
        ram: e.ram,
        storage: e.storage,
        gpu: e.gpu,
        code: line.pim,
        ean: line.ean,
      );
    }

    final key = '${line.brand.toLowerCase()}|${base.toLowerCase()}';
    final existing = byKey[key];
    if (existing != null) {
      byKey[key] = Product(
        id: existing.id,
        name: existing.name,
        brand: existing.brand,
        category: existing.category,
        imagePath: existing.imagePath,
        variants: variant != null
            ? [...existing.variants, variant]
            : existing.variants,
        pcVariants: pcVariant != null
            ? [...existing.pcVariants, pcVariant]
            : existing.pcVariants,
      );
    } else {
      byKey[key] = Product(
        id: 'import_${now}_$i',
        name: base.isEmpty ? line.rawModel : base,
        brand: line.brand,
        category: category,
        imagePath: 'assets/products/${_slug(line.brand, base)}.png',
        variants: variant != null ? [variant] : [],
        pcVariants: pcVariant != null ? [pcVariant] : [],
      );
      order.add(key);
    }
  }

  return [for (final key in order) byKey[key]!];
}

class BulkImportScreen extends StatefulWidget {
  const BulkImportScreen({super.key});

  @override
  State<BulkImportScreen> createState() => _BulkImportScreenState();
}

bool get _ocrSupported {
  if (kIsWeb) return false;
  return Platform.isAndroid || Platform.isIOS;
}

class _BulkImportScreenState extends State<BulkImportScreen> {
  final _textController = TextEditingController();
  String _category = _categories.first;
  List<Product>? _preview;
  int _skippedLines = 0;
  int _duplicateCount = 0;
  bool _scanning = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _buildPreview() {
    final allLines = _parseLines(_textController.text);
    final existingCodes = _existingCatalogCodes();
    final newLines =
        allLines.where((l) => !existingCodes.contains(l.pim)).toList();

    final totalNonEmpty = _textController.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !RegExp(r'^#+$').hasMatch(l.replaceAll(' ', '')))
        .length;

    setState(() {
      _preview = _buildProducts(newLines, _category);
      _duplicateCount = allLines.length - newLines.length;
      _skippedLines = totalNonEmpty - allLines.length;
    });
  }

  Future<void> _scanPhoto() async {
    final picker = ImagePicker();
    XFile? photo;
    try {
      photo = await picker.pickImage(source: ImageSource.camera, maxWidth: 2400);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotocamera non disponibile: $e')),
      );
      return;
    }
    if (photo == null || !mounted) return;

    setState(() => _scanning = true);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(InputImage.fromFilePath(photo.path));
      final extracted = result.text.trim();
      if (extracted.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nessun testo riconosciuto nella foto.')),
        );
      } else {
        setState(() {
          _textController.text = _textController.text.trim().isEmpty
              ? extracted
              : '${_textController.text.trim()}\n$extracted';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lettura foto non riuscita: $e')),
        );
      }
    } finally {
      await recognizer.close();
      if (mounted) setState(() => _scanning = false);
    }
  }

  void _confirmImport() {
    final preview = _preview;
    if (preview == null) return;
    for (final product in preview) {
      catalogRepository.upsert(product);
    }
    final count = preview.length;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Importati $count prodotti in $_category')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final preview = _preview;

    return Scaffold(
      appBar: MwAppBar(
        title: 'IMPORTA ELENCO',
        showSearchAction: false,
        actions: [
          if (preview == null && _ocrSupported)
            IconButton(
              tooltip: 'Fotografa un elenco stampato',
              icon: _scanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.camera_alt_rounded, color: Colors.white),
              onPressed: _scanning ? null : _scanPhoto,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: preview == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Formato: PIM | EAN | Marchio | Modello, una riga per prodotto '
                    '(come le liste incollate finora).',
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: _categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (value) => setState(() => _category = value!),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                      decoration: const InputDecoration(
                        alignLabelWithHint: true,
                        hintText: '123456 | 1234567890123 | MARCA | Modello 128GB Nero',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _buildPreview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBrandRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Genera anteprima'),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${preview.length} prodotti riconosciuti'
                    '${_duplicateCount > 0 ? ' · $_duplicateCount già nel catalogo (ignorati)' : ''}'
                    '${_skippedLines > 0 ? ' · $_skippedLines righe ignorate (formato non valido)' : ''}',
                    style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: preview.isEmpty
                        ? Center(
                            child: Text(
                              'Nessun prodotto riconosciuto: controlla il formato.',
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          )
                        : ListView.separated(
                            itemCount: preview.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final product = preview[index];
                              final variantCount = _isPhoneStyle(_category)
                                  ? product.variants.length
                                  : product.pcVariants.length;
                              return Container(
                                decoration: BoxDecoration(
                                  color: scheme.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: scheme.outlineVariant,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${product.brand} · $variantCount ${variantCount == 1 ? 'variante' : 'varianti'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _preview = null),
                          child: const Text('Indietro'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: preview.isEmpty ? null : _confirmImport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kBrandRed,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Conferma e importa'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
