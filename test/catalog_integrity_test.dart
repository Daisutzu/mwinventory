import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mw_inventory/catalog.dart';
import 'package:mw_inventory/catalog_repository.dart';
import 'package:mw_inventory/main.dart';

void main() {
  setUpAll(() async {
    final dir = Directory.systemTemp.createTempSync('mw_inventory_test_');
    await catalogRepository.initForTest(dir.path, initialSeedProducts);
  });

  test('il catalogo Telefonia non contiene codici PIM duplicati', () {
    final telefonia = sampleProducts.where((p) => p.category == 'Telefonia');
    final codes = <String>[];
    for (final product in telefonia) {
      for (final variant in product.variants) {
        codes.add(variant.code);
      }
    }
    final duplicates =
        codes.toSet().where((c) => codes.where((x) => x == c).length > 1);
    expect(duplicates, isEmpty,
        reason: 'Codici duplicati trovati: $duplicates');
  });

  test('ogni brand Telefonia abilitato ha un logo mappato', () {
    for (final brand in telefoniaBrands) {
      expect(brandLogos.containsKey(brand), isTrue,
          reason: 'Manca logo per $brand');
    }
    expect(telefoniaBrands.contains('NTE'), isFalse);
    expect(telefoniaBrands.contains('ZTE'), isTrue);
  });

  test('il catalogo PC non contiene codici PIM duplicati', () {
    final pc = sampleProducts.where((p) => p.category == 'PC');
    final codes = <String>[];
    for (final product in pc) {
      for (final variant in product.pcVariants) {
        codes.add(variant.code);
      }
    }
    final duplicates =
        codes.toSet().where((c) => codes.where((x) => x == c).length > 1);
    expect(duplicates, isEmpty,
        reason: 'Codici duplicati trovati: $duplicates');
  });

  test('ogni prodotto ha un percorso immagine univoco', () {
    final paths = sampleProducts.map((p) => p.imagePath).toList();
    final duplicates =
        paths.toSet().where((p) => paths.where((x) => x == p).length > 1);
    expect(duplicates, isEmpty,
        reason: 'Prodotti diversi condividono la stessa immagine: $duplicates');
  });
}
