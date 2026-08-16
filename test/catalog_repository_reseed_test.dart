import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mw_inventory/catalog_repository.dart';
import 'package:mw_inventory/product.dart';

void main() {
  // Riproduce lo scenario reale: un dispositivo ha gia' installato l'app
  // (box Hive non vuoto) e riceve un aggiornamento in cui il catalogo di
  // partenza nel codice e' cambiato (es. aggiunto un EAN). Riavviando
  // l'app, i dati sul dispositivo devono allinearsi al nuovo seed, senza
  // perdere un prodotto aggiunto a mano dallo staff.
  test('un cambiamento nel seed si propaga anche su un box gia\' popolato',
      () async {
    final dir = Directory.systemTemp.createTempSync('mw_inventory_reseed_test_');

    final seedV1 = [
      Product(
        id: 'p1',
        name: 'Prodotto Uno',
        brand: 'MarcaTest',
        category: 'Telefonia',
        imagePath: 'assets/products/p1.png',
        variants: [
          ProductVariant(storage: '128GB', color: 'Nero', code: '11111'),
        ],
      ),
    ];

    final repo1 = CatalogRepository();
    await repo1.initForTest(dir.path, seedV1);
    expect(repo1.getAll().single.variants.single.ean, isNull);

    // Lo staff aggiunge un prodotto personalizzato dalla schermata di gestione.
    await repo1.upsert(Product(
      id: 'custom_1',
      name: 'Prodotto Aggiunto A Mano',
      brand: 'MarcaTest',
      category: 'Telefonia',
      imagePath: 'assets/products/custom1.png',
      variants: [
        ProductVariant(storage: '256GB', color: 'Blu', code: '99999'),
      ],
    ));

    await Hive.close();

    // "Riavvio dell'app" con un catalogo di partenza aggiornato: EAN
    // aggiunto su un prodotto esistente, e una categoria del tutto nuova
    // (stesso scenario di Tablet/PC Fissi/Console/TV aggiunti dopo che il
    // telefono aveva gia' installato l'app).
    final seedV2 = [
      Product(
        id: 'p1',
        name: 'Prodotto Uno',
        brand: 'MarcaTest',
        category: 'Telefonia',
        imagePath: 'assets/products/p1.png',
        variants: [
          ProductVariant(
            storage: '128GB',
            color: 'Nero',
            code: '11111',
            ean: '1234567890123',
          ),
        ],
      ),
      Product(
        id: 'tab1',
        name: 'Tablet Nuovo',
        brand: 'MarcaTest',
        category: 'Tablet',
        imagePath: 'assets/products/tab1.png',
        variants: [
          ProductVariant(storage: '64GB', color: 'Grigio', code: '22222'),
        ],
      ),
    ];

    final repo2 = CatalogRepository();
    await repo2.initForTest(dir.path, seedV2);

    final all = repo2.getAll();
    expect(all, hasLength(3));

    final updated = all.firstWhere((p) => p.id == 'p1');
    expect(updated.variants.single.ean, '1234567890123');

    final newCategoryProduct = all.firstWhere((p) => p.id == 'tab1');
    expect(newCategoryProduct.category, 'Tablet');

    final custom = all.firstWhere((p) => p.id == 'custom_1');
    expect(custom.name, 'Prodotto Aggiunto A Mano');
  });
}
