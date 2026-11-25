import 'catalog.dart';

/* Web sürümüyle aynı hesaplama kuralları:
   - tüm mm/cm/m girdileri önce metreye çevrilir
   - yoğunluk kg/m³
   - katalog bedenlerinde kg/m doğrudan tablodan alınır */

class Metal {
  final String key;
  final String name;
  final double density;

  const Metal(this.key, this.name, this.density);
}

const List<Metal> metals = [
  Metal('carbonSteel', 'Çelik (Karbon)', 7850),
  Metal('stainless', 'Paslanmaz Çelik 304', 7930),
  Metal('castIron', 'Dökme Demir', 7870),
  Metal('aluminum', 'Alüminyum', 2700),
  Metal('copper', 'Bakır', 8960),
  Metal('brass', 'Pirinç', 8750),
  Metal('bronze', 'Bronz', 8900),
  Metal('lead', 'Kurşun', 11340),
  Metal('silver', 'Gümüş', 10490),
  Metal('gold', 'Altın', 19300),
];

class ProfileDef {
  final String key;
  final String ad;
  final String aciklama;
  final String kod;
  final String tanitim;
  final String formul;

  const ProfileDef(this.key, this.ad, this.aciklama, this.kod, this.tanitim, this.formul);
}

const List<ProfileDef> profiles = [
  ProfileDef('altikose', 'ALTİ KÖŞE', 'Altıgen kesitli dolu profil', 'HEX', 'HEX 30', 'A = (3√3 / 2)·d²'),
  ProfileDef('dolumil', 'DOLU MİL', 'Dolu silindirik mil', 'ROD', 'ROD ⌀30', 'A = π·d² / 4'),
  ProfileDef('boru', 'BORU', 'İçi boş silindirik profil', 'PIPE', '⌀114,3 × 3,6', 'A = (π/4)·[D² − (D − 2t)²]'),
  ProfileDef('kare', 'KARE', 'Kare kesitli dolu profil', 'SQR', 'SQR 20', 'A = a²'),
  ProfileDef('kutu', 'KUTU PROFİL', 'İçi boş dikdörtgen kutu profil', 'BOX', 'BOX 100×50×3', 'A = A·B − (A − 2t)·(B − 2t)'),
  ProfileDef('t', 'T PROFİL', 'T kesitli kiriş profili', 'TEE', 'TEE 100×100×10', 'A = B·t + (A − t)·t'),
  ProfileDef('i', 'I / H PROFİL', 'Kiriş / flanş profili', 'IBEAM', 'I 200×100×5,6/8,5', 'A = t·(A − 2s) + 2·B·s'),
  ProfileDef('l', 'L PROFİL', 'Köşebent / açı profili', 'ANGLE', 'L 50×50×5', 'A = A·t + B·t − t²'),
  ProfileDef('sac', 'SAC / LEVHA', 'Düzlem metal levha', 'PLATE', 'PLATE 1000×2000×3', 'm = A·B·t·ρ'),
];

class CalcResult {
  final double kesitMm2;
  final double kgMetre;
  final double kgBirim;
  final double kgToplam;
  final double boyM;
  final double fiyat;
  final int adet;
  final double birimFiyat;
  final String formul;

  const CalcResult({
    required this.kesitMm2,
    required this.kgMetre,
    required this.kgBirim,
    required this.kgToplam,
    required this.boyM,
    required this.fiyat,
    required this.adet,
    required this.birimFiyat,
    required this.formul,
  });
}

double toMeter(double value, String unit) {
  if (unit == 'mm') return value / 1000;
  if (unit == 'cm') return value / 100;
  return value;
}

String fmt(num value, [int dec = 2]) {
  final neg = value < 0;
  final fixed = value.abs().toStringAsFixed(dec);
  final parts = fixed.split('.');
  final buf = StringBuffer();
  for (var i = 0; i < parts[0].length; i++) {
    if (i > 0 && (parts[0].length - i) % 3 == 0) buf.write('.');
    buf.write(parts[0][i]);
  }
  final out = neg ? '-$buf' : buf.toString();
  return dec > 0 ? '$out,${parts[1]}' : out;
}

String sayi(num value) => value.toString().replaceAll('.', ',');

CalcResult calculate({
  required String shape,
  required bool weightMode,
  required Map<String, TextValue> values,
  required Metal metal,
  required int adet,
  required double birimFiyat,
  required double girilenKg,
  required bool kgTon,
  CatalogRow? katalog,
}) {
  double? get(String id) {
    final v = values[id];
    if (v == null || v.text.trim().isEmpty) return null;
    final parsed = double.tryParse(v.text.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) return null;
    return toMeter(parsed, v.unit);
  }

  double mm(String id) {
    final v = values[id];
    if (v == null || v.text.trim().isEmpty) throw ArgumentError('Tüm ölçüleri girin.');
    final parsed = double.tryParse(v.text.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) throw ArgumentError('Geçerli bir ölçü girin.');
    return toMeter(parsed, v.unit);
  }

  late double kesit; // m²
  late double boy;   // m, adet başına
  String formul;

  if (shape == 'i' && katalog != null) {
    final l = get('iL');
    if (l == null) throw ArgumentError('Uzunluk değerini girin.');
    kesit = katalog.kgm / 7850;
    boy = l;
    formul = 'm = G · L · n   (G = ${fmt(katalog.kgm, 1)} kg/m · katalog)';
  } else {
    if (shape != 'sac') {
      final l = get(_lengthId(shape));
      if (l == null) throw ArgumentError('Uzunluk değerini girin.');
      boy = l;
    }

    switch (shape) {
      case 't':
        final a = mm('tA'), b = mm('tB'), t = mm('tT');
        if (t >= a) throw ArgumentError('Kalınlık (t), yükseklikten (A) küçük olmalı.');
        kesit = b * t + (a - t) * t;
        break;
      case 'i':
        final a = mm('iA'), b = mm('iB'), t = mm('iT'), s = mm('iS');
        if (2 * s >= a) throw ArgumentError('Flanş kalınlığı çok büyük: 2s < A olmalı.');
        kesit = t * (a - 2 * s) + 2 * b * s;
        break;
      case 'kare':
        final d = mm('kA');
        kesit = d * d;
        break;
      case 'altikose':
        final d = mm('kA');
        kesit = (3 * _sqrt3 / 2) * d * d;
        break;
      case 'dolumil':
        final d = mm('kA');
        kesit = 3.141592653589793 * (d / 2) * (d / 2);
        break;
      case 'kutu':
        final a = mm('bA'), b = mm('bB'), t = mm('bT');
        if (2 * t >= a || 2 * t >= b) throw ArgumentError('Duvar kalınlığı çok büyük: 2t < A ve B olmalı.');
        kesit = a * b - (a - 2 * t) * (b - 2 * t);
        break;
      case 'boru':
        final d = mm('pD'), t = mm('pT');
        if (2 * t >= d) throw ArgumentError('Et kalınlığı çok büyük: 2t < D olmalı.');
        kesit = (3.141592653589793 / 4) * (d * d - (d - 2 * t) * (d - 2 * t));
        break;
      case 'l':
        final a = mm('lA'), b = mm('lB'), t = mm('lT');
        if (t > a || t > b) throw ArgumentError('Kalınlık kenar ölçülerinden büyük olamaz.');
        kesit = a * t + b * t - t * t;
        break;
      case 'sac':
        final a = mm('sA'), b = mm('sB'), t = mm('sT');
        kesit = a * t;
        boy = b;
        break;
      default:
        throw ArgumentError('Bilinmeyen profil tipi.');
    }
    formul = profiles.firstWhere((p) => p.key == shape).formul;
  }

  if (kesit <= 0) throw ArgumentError('Kesit alanı hesaplanamadı.');

  final kgMetre = kesit * metal.density;
  late double kgBirim, kgToplam;

  if (weightMode) {
    final total = kgTon ? girilenKg * 1000 : girilenKg;
    if (total <= 0) throw ArgumentError('Geçerli bir toplam ağırlık girin.');
    kgToplam = total;
    kgBirim = total / adet;
    boy = kgBirim / kgMetre;
  } else {
    kgBirim = kgMetre * boy;
    kgToplam = kgBirim * adet;
  }

  return CalcResult(
    kesitMm2: kesit * 1e6,
    kgMetre: kgMetre,
    kgBirim: kgBirim,
    kgToplam: kgToplam,
    boyM: boy,
    fiyat: kgToplam * birimFiyat,
    adet: adet,
    birimFiyat: birimFiyat,
    formul: formul,
  );
}

String _lengthId(String shape) {
  switch (shape) {
    case 'kare':
    case 'altikose':
    case 'dolumil':
      return 'kL';
    case 'kutu':
      return 'bL';
    case 'boru':
      return 'pL';
    default:
      return '${shape}L';
  }
}

const double _sqrt3 = 1.7320508075688772;

class TextValue {
  final String text;
  final String unit;
  const TextValue(this.text, this.unit);
}

String sonucMetni({
  required String profil,
  required String? seri,
  required String malzeme,
  required Metal metal,
  required CalcResult r,
  required bool weightMode,
}) {
  return [
    'METALPRO — HESAP SONUCU',
    '------------------------------',
    'Profil        : $profil',
    if (seri != null) 'Seri          : $seri (katalog)',
    'Malzeme       : $malzeme (${metal.density} kg/m³)',
    'Kesit alanı   : ${fmt(r.kesitMm2)} mm²',
    'Birim ağırlık : ${fmt(r.kgMetre)} kg/m',
    'Boy           : ${fmt(r.boyM, 3)} m',
    'Adet          : ${r.adet}',
    'Adet başına   : ${fmt(r.kgBirim)} kg',
    'Toplam ağırlık: ${fmt(r.kgToplam)} kg',
    'Birim fiyat   : ${fmt(r.birimFiyat)} TL/kg',
    'Toplam fiyat  : ${fmt(r.fiyat)} TL',
  ].join('\n');
}
