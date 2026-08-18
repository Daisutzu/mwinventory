import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mw_inventory/admin/duplicate_codes_screen.dart';
import 'package:mw_inventory/catalog_repository.dart';
import 'package:mw_inventory/product.dart';

void main() {
  setUpAll(() async {
    final dir = Directory.systemTemp
        .createTempSync('mw_inventory_duplicate_codes_test_');
    await catalogRepository.initForTest(dir.path, [
      Product(
        id: 'a',
        name: 'Telefono A',
        brand: 'MarcaTest',
        category: 'Telefonia',
        imagePath: 'assets/products/a.png',
        variants: [
          ProductVariant(
            storage: '128GB',
            color: 'Nero',
            code: '11111',
            ean: '9990000000001',
          ),
        ],
      ),
      Product(
        id: 'b',
        name: 'Telefono B',
        brand: 'MarcaTest',
        category: 'Telefonia',
        imagePath: 'assets/products/b.png',
        variants: [
          // Stesso EAN di "Telefono A" per errore: deve comparire come
          // duplicato.
          ProductVariant(
            storage: '256GB',
            color: 'Blu',
            code: '22222',
            ean: '9990000000001',
          ),
        ],
      ),
      Product(
        id: 'c',
        name: 'Telefono C',
        brand: 'MarcaTest',
        category: 'Telefonia',
        imagePath: 'assets/products/c.png',
        variants: [
          ProductVariant(
            storage: '128GB',
            color: 'Nero',
            code: '33333',
            ean: '9990000000099',
          ),
        ],
      ),
    ]);
  });

  testWidgets('segnala l\'EAN duplicato e lo riporta a entrambi i prodotti',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DuplicateCodesScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('EAN 9990000000001'), findsOneWidget);
    expect(find.text('Telefono A'), findsOneWidget);
    expect(find.text('Telefono B'), findsOneWidget);
    expect(find.text('Telefono C'), findsNothing);
  });
}
