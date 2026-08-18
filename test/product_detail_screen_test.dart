import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mw_inventory/catalog_repository.dart';
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
    await catalogRepository.initForTest(dir.path, []);
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
    expect(find.textContaining('Codice PIM'), findsNothing);
  });

  testWidgets(
      'mostra anche il codice PIM come riferimento quando il codice a barre e\' un EAN',
      (WidgetTester tester) async {
    final product = Product(
      id: 'pim1',
      name: 'iPhone 16',
      brand: 'Apple',
      category: 'Telefonia',
      imagePath: 'assets/products/iphone16.png',
      variants: [
        ProductVariant(
          storage: '128GB',
          color: 'Nero',
          code: '400123',
          ean: '0195949047123',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailScreen(product: product)),
    );
    await tester.pumpAndSettle();

    expect(find.text('0195949047123'), findsOneWidget);
    expect(find.text('Codice PIM: 400123'), findsOneWidget);
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

  testWidgets(
      'il tasto "Rimuovi lo 0 iniziale" toglie lo zero e salva l\'EAN',
      (WidgetTester tester) async {
    final product = Product(
      id: 'zero1',
      name: 'iPhone Air',
      brand: 'Apple',
      category: 'Telefonia',
      imagePath: 'assets/products/iphoneair.png',
      variants: [
        ProductVariant(
          storage: '256GB',
          color: 'Oro',
          code: '393509',
          ean: '0195950622980',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailScreen(product: product)),
    );
    await tester.pumpAndSettle();

    expect(find.text('0195950622980'), findsOneWidget);
    expect(find.text('Rimuovi lo 0 iniziale'), findsOneWidget);

    await tester.ensureVisible(find.text('Rimuovi lo 0 iniziale'));
    await tester.tap(find.text('Rimuovi lo 0 iniziale'));
    await tester.pumpAndSettle();

    expect(find.text('195950622980'), findsOneWidget);
    expect(find.text('Rimuovi lo 0 iniziale'), findsNothing);
    expect(
      catalogRepository.getAll().single.variants.single.ean,
      '195950622980',
    );
  });

  testWidgets(
      'mostra gli accessori consigliati e naviga alla loro scheda al tocco',
      (WidgetTester tester) async {
    final accessory = Product(
      id: 'acc1',
      name: 'Custodia in silicone',
      brand: 'Apple',
      category: 'Accessori',
      imagePath: 'assets/products/custodia.png',
      variants: [
        ProductVariant(storage: 'Unica', color: 'Bianco', code: '600001'),
      ],
    );
    final product = Product(
      id: 'main1',
      name: 'iPhone 17',
      brand: 'Apple',
      category: 'Telefonia',
      imagePath: 'assets/products/iphone17.png',
      variants: [
        ProductVariant(storage: '128GB', color: 'Nero', code: '700001'),
      ],
      recommendedAccessoryIds: ['acc1'],
    );

    // Niente await: Box.put() di Hive aggiorna la mappa in memoria in modo
    // sincrono, ma il Future che restituisce non si risolve mai in tempo
    // utile dentro flutter test (vedi la stessa nota in product_form_screen).
    catalogRepository.upsert(accessory);
    catalogRepository.upsert(product);

    await tester.pumpWidget(
      MaterialApp(home: ProductDetailScreen(product: product)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Custodia in silicone'), findsOneWidget);

    await tester.ensureVisible(find.text('Custodia in silicone'));
    await tester.tap(find.text('Custodia in silicone'));
    await tester.pumpAndSettle();

    expect(find.text('600001'), findsOneWidget);
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
