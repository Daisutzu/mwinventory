import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mw_inventory/product.dart';
import 'package:mw_inventory/product_detail_screen.dart';
import 'package:mw_inventory/search_history_repository.dart';
import 'package:mw_inventory/widgets/selector_chip.dart';

void main() {
  setUpAll(() async {
    final dir =
        Directory.systemTemp.createTempSync('mw_inventory_detail_test_');
    Hive.init(dir.path);
    await searchHistoryRepository.init();
  });

  testWidgets('mostra il QR code per la variante selezionata di default',
      (WidgetTester tester) async {
    final product = Product(
      id: '1',
      name: 'iPhone 15',
      brand: 'Apple',
      category: 'Telefonia',
      imagePath: 'assets/products/iphone15.png',
      variants: [
        ProductVariant(storage: '128GB', color: 'Nero', code: '12345'),
        ProductVariant(storage: '128GB', color: 'Rosa', code: '12346'),
        ProductVariant(storage: '256GB', color: 'Nero', code: '12347'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailScreen(product: product)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BarcodeWidget), findsOneWidget);
    expect(find.text('12345'), findsOneWidget);

    await tester.tap(find.widgetWithText(SelectorChip, '256GB'));
    await tester.pumpAndSettle();

    expect(find.text('12347'), findsOneWidget);
  });

  testWidgets('mostra il QR per la configurazione PC selezionata',
      (WidgetTester tester) async {
    final product = Product(
      id: 'pc1',
      name: 'Vivobook 15 F1504',
      brand: 'Asus',
      category: 'PC',
      imagePath: 'assets/products/asusvivobook15f1504.png',
      variants: const [],
      pcVariants: [
        PcVariant(code: '425638', cpu: 'C5', ram: '16GB', storage: '512GB'),
        PcVariant(code: '499342', cpu: 'C7', ram: '16GB', storage: '512GB'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailScreen(product: product)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BarcodeWidget), findsOneWidget);
    expect(find.text('425638'), findsOneWidget);
    expect(find.text('C7'), findsOneWidget);

    await tester.tap(find.text('C7'));
    await tester.pumpAndSettle();

    expect(find.text('499342'), findsOneWidget);
  });

  testWidgets('mostra un messaggio se il prodotto non ha varianti',
      (WidgetTester tester) async {
    final product = Product(
      id: '2',
      name: 'Prodotto senza varianti',
      brand: 'Test',
      category: 'Telefonia',
      imagePath: 'assets/products/none.png',
      variants: [],
    );

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailScreen(product: product)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BarcodeWidget), findsNothing);
    expect(
      find.text('Nessuna variante configurata per questo prodotto'),
      findsOneWidget,
    );
  });
}
