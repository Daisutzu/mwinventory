import 'package:flutter_test/flutter_test.dart';
import 'package:mw_inventory/color_names.dart';

void main() {
  test('traduce le sigle colore note in italiano', () {
    expect(colorDisplayName('BK'), 'Nero');
    expect(colorDisplayName('WH'), 'Bianco');
    expect(colorDisplayName('bl'), 'Blu');
  });

  test('mostra la sigla originale se non mappata', () {
    expect(colorDisplayName('ZZZ'), 'ZZZ');
  });
}
