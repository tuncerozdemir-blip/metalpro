import 'package:flutter_test/flutter_test.dart';

import 'package:metalpro/core/catalog.dart';
import 'package:metalpro/core/engine.dart';

void main() {
  final steel = metals.first;
  final iron = metals.firstWhere((m) => m.key == 'castIron');

  group('Hesaplama motoru', () {
    test('Dolu mil ⌀27 · 3000 mm · dökme demir · 100 adet', () {
      final r = calculate(
        shape: 'dolumil',
        weightMode: false,
        values: {
          'kA': const TextValue('27', 'mm'),
          'kL': const TextValue('3000', 'mm'),
        },
        metal: iron,
        adet: 100,
        birimFiyat: 55,
        girilenKg: 0,
        kgTon: false,
      );
      expect(r.kgBirim, closeTo(13.52, 0.01));
      expect(r.kgToplam, closeTo(1351.80, 0.02));
      expect(r.fiyat, closeTo(74349.16, 1));
    });

    test('Katalog IPE 200 · 6 m', () {
      final kat = katalogVerisi['ipe']!.firstWhere((r) => r.ad == 'IPE 200');
      final r = calculate(
        shape: 'i',
        weightMode: false,
        values: {'iL': const TextValue('6000', 'mm')},
        metal: steel,
        adet: 1,
        birimFiyat: 0,
        girilenKg: 0,
        kgTon: false,
        katalog: kat,
      );
      expect(r.kgMetre, closeTo(22.4, 0.001));
      expect(r.kgToplam, closeTo(134.4, 0.001));
      expect(r.formul, contains('katalog'));
    });

    test('Katalog HEM 320 · 12 m · 2 adet', () {
      final kat = katalogVerisi['hem']!.firstWhere((r) => r.ad == 'HEM 320');
      final r = calculate(
        shape: 'i',
        weightMode: false,
        values: {'iL': const TextValue('12000', 'mm')},
        metal: steel,
        adet: 2,
        birimFiyat: 0,
        girilenKg: 0,
        kgTon: false,
        katalog: kat,
      );
      expect(r.kgMetre, closeTo(245, 0.001));
      expect(r.kgToplam, closeTo(5880, 0.001));
    });

    test('Ağırlıktan: 134,4 kg → 6 m', () {
      final kat = katalogVerisi['ipe']!.firstWhere((r) => r.ad == 'IPE 200');
      final r = calculate(
        shape: 'i',
        weightMode: true,
        values: {'iL': const TextValue('6000', 'mm')},
        metal: steel,
        adet: 1,
        birimFiyat: 0,
        girilenKg: 134.4,
        kgTon: false,
        katalog: kat,
      );
      expect(r.boyM, closeTo(6, 0.001));
      expect(r.kgToplam, closeTo(134.4, 0.001));
    });

    test('Kutu 100×50×3 · 6 m → 40,69 kg', () {
      final r = calculate(
        shape: 'kutu',
        weightMode: false,
        values: {
          'bA': const TextValue('100', 'mm'),
          'bB': const TextValue('50', 'mm'),
          'bT': const TextValue('3', 'mm'),
          'bL': const TextValue('6', 'm'),
        },
        metal: steel,
        adet: 1,
        birimFiyat: 0,
        girilenKg: 0,
        kgTon: false,
      );
      expect(r.kgToplam, closeTo(40.6944, 0.001));
    });

    test('T 100×100×10 · 6 m · 2 adet → 178,98 kg', () {
      final r = calculate(
        shape: 't',
        weightMode: false,
        values: {
          'tA': const TextValue('100', 'mm'),
          'tB': const TextValue('100', 'mm'),
          'tT': const TextValue('10', 'mm'),
          'tL': const TextValue('6000', 'mm'),
        },
        metal: steel,
        adet: 2,
        birimFiyat: 0,
        girilenKg: 0,
        kgTon: false,
      );
      expect(r.kgToplam, closeTo(178.98, 0.01));
    });

    test('223 katalog bedeni yüklendi', () {
      expect(toplamBeden, 223);
    });
  });
}
