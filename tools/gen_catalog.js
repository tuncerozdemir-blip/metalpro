/* Web sürümündeki SERI_VERI verisini Flutter katalog dosyasına çevirir. */
const fs = require('fs');
const path = require('path');

const web = path.resolve(__dirname, '..', '..', 'index.html');
const html = fs.readFileSync(web, 'utf8');
const m = html.match(/const SERI_VERI = (\{[\s\S]*?\});/);
if (!m) throw new Error('SERI_VERI bulunamadı');
const data = JSON.parse(m[1]);

const num = x => Number(x).toString().replace(/,/, '.');
const rows = Object.entries(data).map(([key, list]) => {
  const satirlar = list.map(r => {
    const ad = r[0].replace(/'/g, "\\'");
    return `    CatalogRow('${ad}', ${num(r[1])}, ${num(r[2])}, ${num(r[3])}, ${num(r[4])}, ${num(r[5])}),`;
  }).join('\n');
  return `  '${key}': [\n${satirlar}\n  ],`;
}).join('\n');

const out = `// BU DOSYA tools/gen_catalog.js ile web sürümünden üretilmiştir.
// Kayıt: [tanım, h, b, tw, tf, kg/m] — ölçüler mm, ağırlık kg/m (çelik).

class CatalogRow {
  final String ad;
  final double h;
  final double b;
  final double tw;
  final double tf;
  final double kgm;

  const CatalogRow(this.ad, this.h, this.b, this.tw, this.tf, this.kgm);
}

const Map<String, List<CatalogRow>> katalogVerisi = {
${rows}
};

class SeriesInfo {
  final String key;
  final String ad;
  final String aciklama;
  final String std;
  final String aralik;

  const SeriesInfo(this.key, this.ad, this.aciklama, this.std, this.aralik);
}

const List<SeriesInfo> seriler = [
  SeriesInfo('ipe', 'IPE', 'Paralel flanşlı I kiriş', 'EN 10365', '80 – 600'),
  SeriesInfo('ipn', 'IPN', 'Eğimli flanşlı I profil', 'EN 10365', '80 – 600'),
  SeriesInfo('hea', 'HEA', 'Geniş flanşlı H kiriş (A)', 'EN 10365', '100 – 1000'),
  SeriesInfo('heb', 'HEB', 'Geniş flanşlı H kiriş (B)', 'EN 10365', '100 – 1000'),
  SeriesInfo('hem', 'HEM', 'Geniş flanşlı H kiriş (M)', 'EN 10365', '100 – 1000'),
  SeriesInfo('hl', 'HL', 'Ekstra geniş flanşlı kiriş', 'ARCELOR', '920 – 1100'),
  SeriesInfo('hd', 'HD', 'Geniş flanşlı kolon', 'ARCELOR', '260 – 400'),
  SeriesInfo('hp', 'HP', 'Geniş flanşlı kazık profili', 'EN 10365', '200 – 400'),
];

int get toplamBeden => katalogVerisi.values.fold(0, (a, l) => a + l.length);
`;

const dest = path.resolve(__dirname, '..', 'lib', 'core');
fs.mkdirSync(dest, { recursive: true });
fs.writeFileSync(path.join(dest, 'catalog.dart'), out, 'utf8');
console.log('catalog.dart yazıldı: ' + Object.values(data).reduce((a, v) => a + v.length, 0) + ' beden');
