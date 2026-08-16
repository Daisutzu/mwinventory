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
      find.text(
          'Digita per cercare tra tutti i prodotti\no usa i filtri per i PC'),
      findsOneWidget,
    );
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

  testWidgets('il filtro per famiglia di processore mostra solo i PC coerenti',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SearchProductsScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Apple Silicon'));
    await tester.tap(find.text('Apple Silicon'));
    await tester.pumpAndSettle();

    // Richiude il pannello filtri: con molti chip a schermo occupa quasi
    // tutto il viewport di test e nasconderebbe i risultati sotto la riga
    // di cache del ListView (lazy rendering), pur essendo comunque presenti
    // nella lista e raggiungibili scorrendo su un dispositivo vero.
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.text('MacBook Air 13\'\''), findsOneWidget);
    expect(find.text('Vivobook 15 F1504'), findsNothing);
    expect(find.text('iPhone 17 Pro Max'), findsNothing);
  });
}
