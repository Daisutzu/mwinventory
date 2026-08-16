import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mw_inventory/catalog.dart';
import 'package:mw_inventory/catalog_repository.dart';
import 'package:mw_inventory/search_products_screen.dart';

void main() {
  setUpAll(() async {
    final dir = Directory.systemTemp.createTempSync('mw_inventory_test_');
    await catalogRepository.initForTest(dir.path, initialSeedProducts);
  });

  testWidgets('mostra il prompt iniziale prima di digitare', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SearchProductsScreen()),
    );
    await tester.pumpAndSettle();

    expect(
        find.text('Digita per cercare tra tutti i prodotti'), findsOneWidget);
  });

  testWidgets('trova un prodotto cercando per nome', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SearchProductsScreen()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '17 Pro Max');
    await tester.pumpAndSettle();

    expect(find.text('iPhone 17 Pro Max'), findsOneWidget);
  });

  testWidgets('trova un prodotto cercando per codice PIM', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SearchProductsScreen()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '391721');
    await tester.pumpAndSettle();

    expect(find.text('iPhone 17 Pro Max'), findsOneWidget);
    expect(find.textContaining('Codice 391721'), findsOneWidget);
  });

  testWidgets('mostra un messaggio se non ci sono risultati', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SearchProductsScreen()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzznonexistent');
    await tester.pumpAndSettle();

    expect(find.textContaining('Nessun prodotto trovato'), findsOneWidget);
  });
}
