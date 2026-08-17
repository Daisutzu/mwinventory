// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mw_inventory/main.dart';

void main() {
  // Testa la homepage direttamente (non MWInventoryApp, che ora parte dalla
  // schermata password: richiede Firebase Auth inizializzato, non
  // disponibile nell'ambiente di `flutter test` senza un mock dedicato).
  testWidgets('la homepage mostra il titolo dell\'app', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CategoriesScreen()));

    expect(find.text('MW INVENTORY'), findsOneWidget);
  });
}
