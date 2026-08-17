import 'package:flutter/material.dart';
import '../color_names.dart';
import '../product.dart';

// Genera al volo un'immagine stilizzata (stessa "sagoma colorata" usata
// per il resto del catalogo) quando manca il file in assets/products/ -
// il caso tipico e' un prodotto aggiunto tramite import massivo o da
// foto, che non ha mai avuto un'immagine pre-generata. Nessun file da
// scrivere: e' un widget disegnato a schermo con Canvas, con la stessa
// logica (forma in base alla categoria, un colore per variante) usata
// per generare le immagini vere.

enum _Shape { phone, tablet, laptop, tv, box, handheld, headset }

_Shape _shapeFor(Product product) {
  final name = product.name.toLowerCase();
  switch (product.category) {
    case 'Telefonia':
      return _Shape.phone;
    case 'Tablet':
      return _Shape.tablet;
    case 'PC':
      return _Shape.laptop;
    case 'PC Fissi':
      if (name.contains('aio') ||
          name.contains('imac') ||
          name.contains('all-in-one')) {
        return _Shape.tv;
      }
      return _Shape.box;
    case 'TV':
      return _Shape.tv;
    case 'Console':
      if (product.brand == 'Meta Quest') return _Shape.headset;
      if (name.contains('switch') ||
          name.contains('ally') ||
          name.contains('portal')) {
        return _Shape.handheld;
      }
      return _Shape.box;
    default:
      return _Shape.box;
  }
}

const _fallbackGrey = Color(0xFF9AA0A6);

const Map<String, Color> _keywordColors = {
  'nero': Color(0xFF1C1C1E),
  'nera': Color(0xFF1C1C1E),
  'black': Color(0xFF1C1C1E),
  'bianc': Color(0xFFF5F5F7),
  'white': Color(0xFFF5F5F7),
  'luna': Color(0xFFB0A89E),
  'argento': Color(0xFFC0C2C8),
  'silver': Color(0xFFC0C2C8),
  'grigio': Color(0xFF787C84),
  'grey': Color(0xFF787C84),
  'gray': Color(0xFF787C84),
  'blu': Color(0xFF1E5FD9),
  'blue': Color(0xFF1E5FD9),
  'verde': Color(0xFF43A047),
  'green': Color(0xFF43A047),
  'rosa': Color(0xFFF48FB1),
  'pink': Color(0xFFF48FB1),
  'ross': Color(0xFFD84315),
  'red': Color(0xFFD84315),
  'giall': Color(0xFFFDD835),
  'yellow': Color(0xFFFDD835),
  'viola': Color(0xFF8E24AA),
  'purple': Color(0xFF8E24AA),
  'lavanda': Color(0xFFB39DDB),
  'turchese': Color(0xFF1DBFAF),
  'crema': Color(0xFFEEE2C7),
  'grafite': Color(0xFF424246),
  'oro': Color(0xFFD4AF64),
  'gold': Color(0xFFD4AF64),
  'neon': Color(0xFF782882),
  'standard': _fallbackGrey,
};

Color _resolveColor(String? raw) {
  if (raw == null || raw.isEmpty) return _fallbackGrey;
  final translated = colorNames[raw.trim().toUpperCase()] ?? raw;
  final low = translated.toLowerCase();
  if (low.contains('siderale')) {
    return low.contains('nero') ? const Color(0xFF3C3C42) : const Color(0xFF5F6368);
  }
  for (final entry in _keywordColors.entries) {
    if (low.contains(entry.key)) return entry.value;
  }
  return _fallbackGrey;
}

List<Color> _colorsFor(Product product) {
  final raw = product.variants.isNotEmpty
      ? product.variants.map((v) => v.color)
      : product.pcVariants.map((v) => v.color);
  final colors = <Color>[];
  for (final r in raw) {
    final c = _resolveColor(r);
    if (!colors.contains(c)) colors.add(c);
    if (colors.length == 4) break;
  }
  return colors.isEmpty ? [_fallbackGrey] : colors;
}

class GeneratedProductImage extends StatelessWidget {
  final Product product;

  const GeneratedProductImage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _LineupPainter(_shapeFor(product), _colorsFor(product)),
      ),
    );
  }
}

class _LineupPainter extends CustomPainter {
  final _Shape shape;
  final List<Color> colors;

  _LineupPainter(this.shape, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final slotWidth = size.width / colors.length;
    for (var i = 0; i < colors.length; i++) {
      final slot = Rect.fromLTWH(slotWidth * i, 0, slotWidth, size.height);
      _drawShape(canvas, slot, colors[i]);
    }
  }

  void _drawShape(Canvas canvas, Rect slot, Color color) {
    final dark = Color.lerp(color, Colors.black, 0.16)!;
    final darker = Color.lerp(color, Colors.black, 0.3)!;
    final light = Color.lerp(color, Colors.white, 0.16)!;
    final darkFill = Paint()..color = dark;
    final darkerFill = Paint()..color = darker;
    final lightFill = Paint()..color = light;

    switch (shape) {
      case _Shape.phone:
        _phone(canvas, slot, darkFill, lightFill, darkerFill);
      case _Shape.tablet:
        _tablet(canvas, slot, darkFill, lightFill, darkerFill);
      case _Shape.laptop:
        _laptop(canvas, slot, darkFill, lightFill);
      case _Shape.tv:
        _tv(canvas, slot, darkFill, lightFill, darkerFill);
      case _Shape.box:
        _box(canvas, slot, darkFill, lightFill);
      case _Shape.handheld:
        _handheld(canvas, slot, darkFill, lightFill);
      case _Shape.headset:
        _headset(canvas, slot, darkFill, lightFill);
    }
  }

  double _fit(Rect slot, double naturalW, double naturalH) {
    final sw = slot.width * 0.78 / naturalW;
    final sh = slot.height * 0.78 / naturalH;
    return sw < sh ? sw : sh;
  }

  void _phone(Canvas canvas, Rect slot, Paint body, Paint screen, Paint accent) {
    const w = 130.0, h = 250.0, r = 22.0;
    final s = _fit(slot, w, h);
    final cx = slot.center.dx, cy = slot.center.dy;
    final outer = Rect.fromCenter(center: Offset(cx, cy), width: w * s, height: h * s);
    canvas.drawRRect(RRect.fromRectAndRadius(outer, Radius.circular(r * s)), body);
    final pad = 9 * s;
    canvas.drawRRect(
      RRect.fromRectAndRadius(outer.deflate(pad), Radius.circular((r - 6) * s)),
      screen,
    );
    canvas.drawCircle(Offset(cx, outer.top + pad * 1.3), 3.5 * s, accent);
  }

  void _tablet(Canvas canvas, Rect slot, Paint body, Paint screen, Paint accent) {
    const w = 176.0, h = 250.0, r = 22.0;
    final s = _fit(slot, w, h);
    final cx = slot.center.dx, cy = slot.center.dy;
    final outer = Rect.fromCenter(center: Offset(cx, cy), width: w * s, height: h * s);
    canvas.drawRRect(RRect.fromRectAndRadius(outer, Radius.circular(r * s)), body);
    final pad = 10 * s;
    canvas.drawRRect(
      RRect.fromRectAndRadius(outer.deflate(pad), Radius.circular((r - 6) * s)),
      screen,
    );
    canvas.drawCircle(Offset(cx, outer.top + pad / 2), 3 * s, accent);
  }

  void _laptop(Canvas canvas, Rect slot, Paint body, Paint screen) {
    const w = 190.0, h = 120.0;
    final s = _fit(slot, w, h + 20);
    final cx = slot.center.dx, cy = slot.center.dy - 8 * s;
    final outer = Rect.fromCenter(center: Offset(cx, cy), width: w * s, height: h * s);
    canvas.drawRRect(RRect.fromRectAndRadius(outer, Radius.circular(8 * s)), body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(outer.deflate(8 * s), Radius.circular(3 * s)),
      screen,
    );
    final base = Rect.fromCenter(
      center: Offset(cx, outer.bottom + 10 * s),
      width: w * 1.15 * s,
      height: 10 * s,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(base, Radius.circular(4 * s)), body);
  }

  void _tv(Canvas canvas, Rect slot, Paint body, Paint screen, Paint accent) {
    const w = 250.0, h = 148.0;
    final s = _fit(slot, w, h + 40);
    final cx = slot.center.dx, cy = slot.center.dy - 16 * s;
    final outer = Rect.fromCenter(center: Offset(cx, cy), width: w * s, height: h * s);
    canvas.drawRRect(RRect.fromRectAndRadius(outer, Radius.circular(8 * s)), body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(outer.deflate(8 * s), Radius.circular(4 * s)),
      screen,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, outer.bottom + 13 * s), width: 12 * s, height: 26 * s),
      accent,
    );
    final base = Rect.fromCenter(
      center: Offset(cx, outer.bottom + 29 * s),
      width: 92 * s,
      height: 10 * s,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(base, Radius.circular(5 * s)), accent);
  }

  void _box(Canvas canvas, Rect slot, Paint body, Paint accent) {
    const w = 132.0, h = 268.0;
    final s = _fit(slot, w, h);
    final cx = slot.center.dx, cy = slot.center.dy;
    final outer = Rect.fromCenter(center: Offset(cx, cy), width: w * s, height: h * s);
    canvas.drawRRect(RRect.fromRectAndRadius(outer, Radius.circular(20 * s)), body);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, outer.top + 64 * s), width: (w - 28) * s, height: 8 * s),
      accent,
    );
    canvas.drawCircle(Offset(cx, outer.bottom - 27 * s), 7 * s, accent);
  }

  void _handheld(Canvas canvas, Rect slot, Paint body, Paint screen) {
    const w = 270.0, h = 118.0;
    final s = _fit(slot, w, h);
    final cx = slot.center.dx, cy = slot.center.dy;
    final outer = Rect.fromCenter(center: Offset(cx, cy), width: w * s, height: h * s);
    canvas.drawRRect(RRect.fromRectAndRadius(outer, Radius.circular(28 * s)), body);
    final inner = Rect.fromCenter(center: Offset(cx, cy), width: w * 0.56 * s, height: (h - 24) * s);
    canvas.drawRRect(RRect.fromRectAndRadius(inner, Radius.circular(10 * s)), screen);
    canvas.drawCircle(Offset(outer.left + 32 * s, cy), 12 * s, screen);
    canvas.drawCircle(Offset(outer.right - 32 * s, cy), 12 * s, screen);
  }

  void _headset(Canvas canvas, Rect slot, Paint body, Paint screen) {
    const vw = 210.0, vh = 100.0;
    final s = _fit(slot, vw, vh + 70);
    final cx = slot.center.dx, cy = slot.center.dy + 10 * s;
    final visor = Rect.fromCenter(center: Offset(cx, cy), width: vw * s, height: vh * s);
    final strap = Paint()
      ..color = body.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16 * s
      ..strokeCap = StrokeCap.round;
    final strapRect = Rect.fromCenter(
      center: Offset(cx, visor.top - 12 * s),
      width: vw * s,
      height: 68 * s,
    );
    canvas.drawArc(strapRect, 3.4, 2.6, false, strap);
    canvas.drawRRect(RRect.fromRectAndRadius(visor, Radius.circular(30 * s)), body);
    canvas.drawRRect(
      RRect.fromRectAndRadius(visor.deflate(14 * s), Radius.circular(18 * s)),
      screen,
    );
  }

  @override
  bool shouldRepaint(covariant _LineupPainter oldDelegate) =>
      oldDelegate.shape != shape || oldDelegate.colors != colors;
}
