import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mw_inventory/product.dart';
import 'package:mw_inventory/widgets/generated_product_image.dart';

void main() {
  testWidgets(
      'disegna un\'immagine al posto di un asset mancante, senza errori',
      (tester) async {
    final product = Product(
      id: 'import_test',
      name: 'Prodotto Importato',
      brand: 'MarcaTest',
      category: 'Tablet',
      imagePath: 'assets/products/questo-file-non-esiste.png',
      variants: [
        ProductVariant(storage: '128GB', color: 'BK', code: '11111'),
        ProductVariant(storage: '256GB', color: 'BL', code: '11112'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 56,
          height: 56,
          child: GeneratedProductImage(product: product),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('funziona anche per le categorie stile PC (PcVariant)',
      (tester) async {
    final product = Product(
      id: 'import_test_pc',
      name: 'PC Importato',
      brand: 'MarcaTest',
      category: 'PC Fissi',
      imagePath: 'assets/products/questo-file-non-esiste-2.png',
      variants: const [],
      pcVariants: [
        PcVariant(code: '22222', cpu: 'I5', ram: '16GB', storage: '512GB'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 56,
          height: 56,
          child: GeneratedProductImage(product: product),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(CustomPaint), findsWidgets);
  });
}
