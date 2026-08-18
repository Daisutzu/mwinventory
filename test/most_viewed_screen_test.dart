import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mw_inventory/admin/most_viewed_screen.dart';
import 'package:mw_inventory/catalog_repository.dart';
import 'package:mw_inventory/product.dart';
import 'package:mw_inventory/search_history_repository.dart';

void main() {
  setUpAll(() async {
    final dir =
        Directory.systemTemp.createTempSync('mw_inventory_most_viewed_test_');
    Hive.init(dir.path);
    await searchHistoryRepository.init();
    await catalogRepository.initForTest(dir.path, [
      Product(
        id: 'p1',
        name: 'Prodotto Popolare',
        brand: 'MarcaTest',
        category: 'Telefonia',
        imagePath: 'assets/products/p1.png',
        variants: [ProductVariant(storage: '128GB', color: 'Nero', code: '1')],
      ),
      Product(
        id: 'p2',
        name: 'Prodotto Raro',
        brand: 'MarcaTest',
        category: 'Telefonia',
        imagePath: 'assets/products/p2.png',
        variants: [ProductVariant(storage: '128GB', color: 'Nero', code: '2')],
      ),
    ]);
  });

  testWidgets('mostra un messaggio se non ci sono ancora dati',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MostViewedScreen()),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Nessun dato ancora'),
      findsOneWidget,
    );
  });

  testWidgets('ordina i prodotti per numero di aperture', (tester) async {
    searchHistoryRepository.recordView('p2');
    searchHistoryRepository.recordView('p1');
    searchHistoryRepository.recordView('p1');
    searchHistoryRepository.recordView('p1');

    await tester.pumpWidget(
      const MaterialApp(home: MostViewedScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Prodotto Popolare'), findsOneWidget);
    expect(find.text('Prodotto Raro'), findsOneWidget);
    expect(find.text('3 aperture'), findsOneWidget);
    expect(find.text('1 apertura'), findsOneWidget);

    // "Prodotto Popolare" (3 aperture) deve comparire prima di "Prodotto
    // Raro" (1 apertura) nell'ordine verticale della lista.
    final popolareY = tester.getTopLeft(find.text('Prodotto Popolare')).dy;
    final raroY = tester.getTopLeft(find.text('Prodotto Raro')).dy;
    expect(popolareY, lessThan(raroY));
  });
}
