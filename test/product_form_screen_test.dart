import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mw_inventory/admin/product_form_screen.dart';
import 'package:mw_inventory/catalog_repository.dart';
import 'package:mw_inventory/product.dart';

void main() {
  setUpAll(() async {
    final dir =
        Directory.systemTemp.createTempSync('mw_inventory_product_form_test_');
    await catalogRepository.initForTest(dir.path, [
      Product(
        id: 'p1',
        name: 'Telefono Test',
        brand: 'MarcaTest',
        category: 'Telefonia',
        imagePath: 'assets/products/p1.png',
        variants: [
          ProductVariant(
            storage: '128GB',
            color: 'Nero',
            code: '500001',
            ean: '0111111111111',
          ),
        ],
      ),
    ]);
  });

  testWidgets(
      'al salvataggio non sovrascrive un EAN corretto nel frattempo da un altro dispositivo',
      (tester) async {
    final product = catalogRepository.getAll().single;

    await tester.pumpWidget(
      MaterialApp(home: ProductFormScreen(product: product)),
    );
    await tester.pumpAndSettle();

    // Mentre il form e' aperto, un altro dispositivo sincronizza la
    // correzione dell'EAN (es. tasto "Rimuovi lo 0 iniziale").
    catalogRepository.upsert(
      Product(
        id: product.id,
        name: product.name,
        brand: product.brand,
        category: product.category,
        imagePath: product.imagePath,
        variants: [
          ProductVariant(
            storage: '128GB',
            color: 'Nero',
            code: '500001',
            ean: '111111111111',
          ),
        ],
      ),
    );

    // L'operatore modifica un altro campo (non l'EAN di questa variante) e
    // salva: non deve riportare indietro il vecchio EAN caricato all'apertura.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'es. Apple'),
      'MarcaTest',
    );

    await tester.ensureVisible(find.text('Salva modifiche'));
    await tester.tap(find.text('Salva modifiche'));
    await tester.pumpAndSettle();

    expect(
      catalogRepository.getAll().single.variants.single.ean,
      '111111111111',
    );
  });
}
