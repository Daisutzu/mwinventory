import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mw_inventory/admin/bulk_import_screen.dart';
import 'package:mw_inventory/catalog_repository.dart';

void main() {
  setUpAll(() async {
    final dir = Directory.systemTemp.createTempSync('mw_inventory_import_test_');
    await catalogRepository.initForTest(dir.path, []);
  });

  testWidgets('raggruppa le righe con lo stesso modello in un solo prodotto',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BulkImportScreen()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      '111111 | 1234567890123 | TestBrand | Modello Uno 128GB BK\n'
      '111112 | 1234567890124 | TestBrand | Modello Uno 256GB BL\n'
      '111113 | 1234567890125 | TestBrand | Modello Due 64GB',
    );
    await tester.tap(find.text('Genera anteprima'));
    await tester.pumpAndSettle();

    expect(find.textContaining('2 prodotti riconosciuti'), findsOneWidget);
    expect(find.text('Modello Uno'), findsOneWidget);
    expect(find.textContaining('2 varianti'), findsOneWidget);
    expect(find.text('Modello Due'), findsOneWidget);
    expect(find.textContaining('1 variante'), findsOneWidget);

    await tester.tap(find.text('Conferma e importa'));
    await tester.pumpAndSettle();

    final saved = catalogRepository.getAll();
    expect(saved.length, 2);
    final modelloUno = saved.firstWhere((p) => p.name == 'Modello Uno');
    expect(modelloUno.variants, hasLength(2));
    expect(
      modelloUno.variants.map((v) => v.color),
      containsAll(['BK', 'BL']),
    );
  });

  testWidgets('ignora le righe che non rispettano il formato', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BulkImportScreen()),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      '222222 | 9876543210123 | TestBrand | Modello Valido 32GB\n'
      'questa riga non ha il formato giusto',
    );
    await tester.tap(find.text('Genera anteprima'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('1 righe ignorate'),
      findsOneWidget,
    );
    expect(find.text('Modello Valido'), findsOneWidget);
  });
}
