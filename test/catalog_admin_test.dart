import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mw_inventory/admin/catalog_admin_screen.dart';
import 'package:mw_inventory/catalog_repository.dart';
import 'package:mw_inventory/product.dart';

void main() {
  setUpAll(() async {
    final dir = Directory.systemTemp.createTempSync('mw_inventory_admin_test_');
    await catalogRepository.initForTest(dir.path, [
      Product(
        id: 'seed1',
        name: 'Prodotto Iniziale',
        brand: 'MarcaTest',
        category: 'Telefonia',
        imagePath: 'assets/products/seed1.png',
        variants: [
          ProductVariant(storage: '128GB', color: 'Nero', code: '11111'),
        ],
      ),
    ]);
  });

  testWidgets('aggiunge, modifica ed elimina un prodotto', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CatalogAdminScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Prodotto Iniziale'), findsOneWidget);

    // --- Aggiunta ---
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'es. Apple'), 'Nuova Marca');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'es. iPhone 17'),
      'Prodotto Nuovo',
    );

    await tester.tap(find.text('Aggiungi'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Memoria'), '256GB');
    await tester.enterText(find.widgetWithText(TextFormField, 'Colore'), 'Blu');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Codice PIM'), '99999');

    await tester.ensureVisible(find.text('Aggiungi al catalogo'));
    await tester.tap(find.text('Aggiungi al catalogo'));
    await tester.pumpAndSettle();

    expect(find.text('Prodotto Nuovo'), findsOneWidget);
    expect(find.text('Prodotto Iniziale'), findsOneWidget);

    // --- Modifica ---
    // Ordinamento per marca: "MarcaTest" (seed) viene prima di "Nuova Marca",
    // quindi il pulsante di modifica del prodotto appena creato e' l'ultimo.
    final editButtons = find.widgetWithIcon(IconButton, Icons.edit_rounded);
    await tester.tap(editButtons.last);
    await tester.pumpAndSettle();

    final nameField = find.widgetWithText(TextFormField, 'es. iPhone 17');
    await tester.enterText(nameField, 'Prodotto Nuovo Modificato');
    await tester.ensureVisible(find.text('Salva modifiche'));
    await tester.tap(find.text('Salva modifiche'));
    await tester.pumpAndSettle();

    expect(find.text('Prodotto Nuovo Modificato'), findsOneWidget);
    expect(find.text('Prodotto Nuovo'), findsNothing);

    // --- Eliminazione ---
    await tester.tap(find.byIcon(Icons.delete_rounded).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elimina'));
    await tester.pumpAndSettle();

    expect(find.text('Prodotto Nuovo Modificato'), findsNothing);
    expect(find.text('Prodotto Iniziale'), findsOneWidget);
  });
}
