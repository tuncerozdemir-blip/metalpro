import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/catalog.dart';
import '../core/engine.dart';
import '../draw/drawing.dart';
import '../theme.dart';
import '../widgets/blueprint.dart';

/// Oturum boyunca eklenen özel metaller (web sürümündeki metals dizisinin karşılığı).
final ValueNotifier<List<Metal>> customMetals = ValueNotifier<List<Metal>>([]);

class CalcScreen extends StatefulWidget {
  final String shape;
  final CatalogRow? catalog;
  final SeriesInfo? series;

  const CalcScreen({
    super.key,
    required this.shape,
    this.catalog,
    this.series,
  });

  @override
  State<CalcScreen> createState() => _CalcScreenState();
}

class _CalcScreenState extends State<CalcScreen> {
  late final Map<String, TextEditingController> _c;
  late final Map<String, String> _u;
  late final TextEditingController _adet;
  late final TextEditingController _fiyat;
  late final TextEditingController _kg;

  String _metalKey = 'carbonSteel';
  bool _weightMode = false;
  String _kgUnit = 'kg';
  CalcResult? _result;

  static const List<String> _tumAlanlar = [
    'tA', 'tB', 'tT', 'tL',
    'iA', 'iB', 'iT', 'iS', 'iL',
    'kA', 'kL',
    'bA', 'bB', 'bT', 'bL',
    'pD', 'pT', 'pL',
    'lA', 'lB', 'lT', 'lL',
    'sA', 'sB', 'sT',
  ];

  @override
  void initState() {
    super.initState();
    _c = {for (final id in _tumAlanlar) id: TextEditingController()};
    _u = {for (final id in _tumAlanlar) id: 'mm'};
    _adet = TextEditingController(text: '1');
    _fiyat = TextEditingController(text: '0');
    _kg = TextEditingController();

    if (widget.catalog != null) {
      final k = widget.catalog!;
      _c['iA']!.text = sayi(k.h);
      _c['iB']!.text = sayi(k.b);
      _c['iT']!.text = sayi(k.tw);
      _c['iS']!.text = sayi(k.tf);
    }
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    _adet.dispose();
    _fiyat.dispose();
    _kg.dispose();
    super.dispose();
  }

  List<String> get _alanlar {
    switch (widget.shape) {
      case 't':
        return ['tA', 'tB', 'tT', 'tL'];
      case 'i':
        return ['iA', 'iB', 'iT', 'iS', 'iL'];
      case 'kare':
      case 'altikose':
      case 'dolumil':
        return ['kA', 'kL'];
      case 'kutu':
        return ['bA', 'bB', 'bT', 'bL'];
      case 'boru':
        return ['pD', 'pT', 'pL'];
      case 'l':
        return ['lA', 'lB', 'lT', 'lL'];
      case 'sac':
        return ['sA', 'sB', 'sT'];
      default:
        return const [];
    }
  }

  (String, String) _etiket(String id) {
    const map = {
      'tA': ('A', 'Toplam Yükseklik'),
      'tB': ('B', 'Kanat Genişliği'),
      'tT': ('t', 'Kalınlık'),
      'tL': ('L', 'Uzunluk'),
      'iA': ('h', 'Yükseklik'),
      'iB': ('b', 'Flanş Genişliği'),
      'iT': ('tw', 'Gövde Kalınlığı'),
      'iS': ('tf', 'Flanş Kalınlığı'),
      'iL': ('L', 'Uzunluk'),
      'kL': ('L', 'Uzunluk'),
      'bA': ('A', 'Genişlik'),
      'bB': ('B', 'Yükseklik'),
      'bT': ('t', 'Duvar Kalınlığı'),
      'bL': ('L', 'Uzunluk'),
      'pD': ('D', 'Dış Çap'),
      'pT': ('t', 'Et Kalınlığı'),
      'pL': ('L', 'Uzunluk'),
      'lA': ('A', 'Kenar 1'),
      'lB': ('B', 'Kenar 2'),
      'lT': ('t', 'Kalınlık'),
      'lL': ('L', 'Uzunluk'),
      'sA': ('A', 'Genişlik'),
      'sB': ('B', 'Uzunluk'),
      'sT': ('t', 'Kalınlık'),
    };
    if (id == 'kA') {
      return switch (widget.shape) {
        'altikose' => ('s', 'İki Karşı Kenar'),
        'dolumil' => ('⌀', 'Çap'),
        _ => ('a', 'Kenar'),
      };
    }
    return map[id] ?? (id, id);
  }

  Metal get _metal {
    final all = [...metals, ...customMetals.value];
    return all.firstWhere(
      (m) => m.key == _metalKey,
      orElse: () => metals.first,
    );
  }

  ProfileDef get _profil => profiles.firstWhere(
        (p) => p.key == widget.shape,
        orElse: () => profiles.first,
      );

  void _geri() {
    if (widget.catalog != null) {
      Navigator.of(context).pop(); // hesap → beden listesi
      return;
    }
    // Keyfi hesapta seri ekranına (yoksa ana sayfaya) dön.
    Navigator.of(context).popUntil(
      (route) => route.isFirst || route.settings.name == 'series',
    );
  }

  void _keyfiyeGec() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CalcScreen(shape: 'i'),
      ),
    );
  }

  void _hesapla() {
    try {
      final adetRaw = int.tryParse(_adet.text.trim()) ?? 1;
      final adet = adetRaw < 1 ? 1 : adetRaw;
      final fiyat = double.tryParse(_fiyat.text.replaceAll(',', '.')) ?? 0;
      final kgRaw = double.tryParse(_kg.text.replaceAll(',', '.')) ?? 0;

      final values = {
        for (final entry in _c.entries)
          entry.key: TextValue(entry.value.text, _u[entry.key]!),
      };

      final r = calculate(
        shape: widget.shape,
        weightMode: _weightMode,
        values: values,
        metal: _metal,
        adet: adet,
        birimFiyat: fiyat,
        girilenKg: kgRaw,
        kgTon: _kgUnit == 'ton',
        katalog: widget.catalog,
      );

      setState(() => _result = r);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hesaplama tamamlandı'),
          duration: Duration(seconds: 2),
        ),
      );
    } on ArgumentError catch (e) {
      final msg = e.message.toString().replaceFirst('Invalid argument(s): ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _temizle() {
    for (final c in _c.values) {
      if (widget.catalog != null && c == _c['iA']) continue;
      if (widget.catalog != null && c == _c['iB']) continue;
      if (widget.catalog != null && c == _c['iT']) continue;
      if (widget.catalog != null && c == _c['iS']) continue;
      c.clear();
    }
    for (final id in _tumAlanlar) {
      _u[id] = 'mm';
    }
    _kg.clear();
    _adet.text = '1';
    _fiyat.text = '0';
    setState(() => _result = null);
  }

  String get _metin {
    final r = _result;
    if (r == null) return '';
    return sonucMetni(
      profil: widget.catalog?.ad ?? _profil.ad,
      seri: widget.series?.ad.toUpperCase(),
      malzeme: _metal.name,
      metal: _metal,
      r: r,
      weightMode: _weightMode,
    );
  }

  Future<void> _paylas() async {
    if (_result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce hesaplama yapın.')),
      );
      return;
    }
    await SharePlus.instance.share(ShareParams(text: _metin, subject: 'MetalPro'));
  }

  Future<void> _kaydet() async {
    if (_result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce hesaplama yapın.')),
      );
      return;
    }
    try {
      final dir = await getApplicationDocumentsDirectory();
      if (!mounted) return;
      final ad = (widget.catalog?.ad ?? _profil.kod).replaceAll(RegExp(r'\s+'), '');
      final dosya = File('${dir.path}/metalpro-$ad.txt');
      await dosya.writeAsString(_metin);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kaydedildi: ${dosya.path}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kaydedilemedi: $e')),
      );
    }
  }

  Future<void> _metalEkle() async {
    final adCtrl = TextEditingController();
    final yogCtrl = TextEditingController();
    final kaydedildi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Özel Metal Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: adCtrl,
              decoration: const InputDecoration(labelText: 'Metal adı', hintText: 'ör. Paslanmaz 316'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: yogCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Yoğunluk (kg/m³)', hintText: 'ör. 8000'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('VAZGEÇ')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('METAL EKLE'),
          ),
        ],
      ),
    );

    if (kaydedildi != true) return;
    if (!mounted) return;
    final ad = adCtrl.text.trim();
    final yog = double.tryParse(yogCtrl.text.replaceAll(',', '.'));
    if (ad.isEmpty || yog == null || yog <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Metal adı ve geçerli yoğunluk girin.')),
      );
      return;
    }
    final m = Metal('custom_${DateTime.now().microsecondsSinceEpoch}', ad, yog);
    customMetals.value = [...customMetals.value, m];
    setState(() => _metalKey = m.key);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kat = widget.catalog;
    final genis = MediaQuery.of(context).size.width >= 940;

    return Scaffold(
      appBar: TopBar(onHome: () => Navigator.of(context).popUntil((r) => r.isFirst)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1240),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SubHeader(
                  title: kat?.ad ?? _profil.ad,
                  badge: kat != null
                      ? (widget.series?.ad ?? kat.h.toStringAsFixed(0)).toUpperCase()
                      : _profil.kod,
                  backLabel: kat != null
                      ? 'BEDENLER'
                      : (widget.shape == 'i' ? 'SERİLER' : 'PROFİLLER'),
                  onBack: _geri,
                ),
                if (kat != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.fromLTRB(11, 9, 9, 9),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: .07),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: .25)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text('KATALOG',
                              style: TextStyle(fontFamily: 'monospace', fontSize: 9,
                                  letterSpacing: 1, color: Colors.white)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${kat.ad}   h ${sayi(kat.h)} · b ${sayi(kat.b)} · tw ${sayi(kat.tw)} · tf ${sayi(kat.tf)} mm · G ${sayi(kat.kgm)} kg/m',
                            style: TextStyle(fontFamily: 'monospace', fontSize: 11,
                                color: theme.colorScheme.onSurface.withValues(alpha: .82)),
                          ),
                        ),
                        TextButton(
                          onPressed: _keyfiyeGec,
                          child: const Text('KEYFİ DÜZENLE',
                              style: TextStyle(fontFamily: 'monospace', fontSize: 10, letterSpacing: .8)),
                        ),
                      ],
                    ),
                  ),
                LayoutBuilder(builder: (context, cons) {
                  final form = _formPanel(theme);
                  final result = _resultPanel(theme);
                  if (!genis) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [form, const SizedBox(height: 16), result],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: form),
                      const SizedBox(width: 18),
                      Expanded(flex: 4, child: result),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _formPanel(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlueprintPanel(
            svg: sectionSvg(widget.shape, form: true),
            tag: 'KESİT ÖLÇÜLERİ',
            code: widget.catalog != null
                ? (widget.series?.ad ?? 'KATALOG').toUpperCase()
                : _profil.kod,
            designation: widget.catalog?.ad ?? _profil.tanitim,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Malzeme
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _metalKey,
                        decoration: const InputDecoration(labelText: 'Malzeme'),
                        items: [
                          for (final m in [...metals, ...customMetals.value])
                            DropdownMenuItem(value: m.key, child: Text(m.name)),
                        ],
                        onChanged: (v) => setState(() => _metalKey = v ?? 'carbonSteel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _metalEkle,
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.add, size: 19),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Mod
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _modButon('UZUNLUKTAN', !_weightMode, () => setState(() => _weightMode = false)),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: _modButon('AĞIRLIKTAN', _weightMode, () => setState(() => _weightMode = true)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ..._dimensionFields(),
                const SizedBox(height: 6),
                _bolumBasligi('GENEL BİLGİ'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _adet,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '#  Adet'),
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _fiyat,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: '₺  Fiyat (TL/kg)'),
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
                if (_weightMode) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _kg,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'kg  Toplam Ağırlık'),
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 82,
                        child: DropdownButtonFormField<String>(
                          initialValue: _kgUnit,
                          decoration: const InputDecoration(labelText: 'Birim'),
                          items: const [
                            DropdownMenuItem(value: 'kg', child: Text('kg')),
                            DropdownMenuItem(value: 'ton', child: Text('ton')),
                          ],
                          onChanged: (v) => setState(() => _kgUnit = v ?? 'kg'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Girilen ağırlık toplam ağırlıktır; adet başına ağırlık otomatik hesaplanır.',
                    style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withValues(alpha: .58)),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _temizle,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          side: BorderSide(color: theme.dividerColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('SIFIRLA',
                            style: TextStyle(fontFamily: 'monospace', letterSpacing: 1.4)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _hesapla,
                        child: const Text('HESAPLA',
                            style: TextStyle(fontFamily: 'monospace', letterSpacing: 1.4)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modButon(String label, bool aktif, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Material(
      color: aktif ? theme.colorScheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(3),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              letterSpacing: 1.1,
              color: aktif ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: .62),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bolumBasligi(String text) {
    return Row(
      children: [
        Expanded(child: Divider(color: Theme.of(context).dividerColor, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Text(text,
              style: TextStyle(fontFamily: 'monospace', fontSize: 9.5,
                  letterSpacing: 1.5,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .5))),
        ),
        Expanded(child: Divider(color: Theme.of(context).dividerColor, height: 1)),
      ],
    );
  }

  List<Widget> _dimensionFields() {
    final alanlar = _alanlar;
    final widgets = <Widget>[];
    for (var i = 0; i < alanlar.length; i += 2) {
      final pair = alanlar.sublist(i, (i + 2).clamp(0, alanlar.length));
      widgets.add(pair.length == 2
          ? Row(children: [
              Expanded(child: _alan(pair[0])),
              const SizedBox(width: 12),
              Expanded(child: _alan(pair[1])),
            ])
          : _alan(pair[0]));
      widgets.add(const SizedBox(height: 12));
    }
    return widgets;
  }

  Widget _alan(String id) {
    final theme = Theme.of(context);
    final (sym, label) = _etiket(id);
    final locked = widget.catalog != null && id != 'iL';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: .75)),
            children: [
              TextSpan(
                text: '$sym ',
                style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary),
              ),
              TextSpan(text: label),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _c[id],
                enabled: !locked,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: InputDecoration(
                  isDense: true,
                  filled: locked,
                  fillColor: theme.colorScheme.onSurface.withValues(alpha: .04),
                  hintText: locked ? 'katalog' : '0',
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 62,
              child: DropdownButtonFormField<String>(
                initialValue: _u[id],
                isDense: true,
                decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 7)),
                items: const [
                  DropdownMenuItem(value: 'mm', child: Text('mm')),
                  DropdownMenuItem(value: 'cm', child: Text('cm')),
                  DropdownMenuItem(value: 'm', child: Text('m')),
                ],
                onChanged: locked ? null : (v) => setState(() => _u[id] = v ?? 'mm'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _resultPanel(ThemeData theme) {
    final r = _result;
    final kg = r != null ? fmt(r.kgToplam) : '0,00';
    final sub = r == null
        ? 'Hesaplama bekleniyor'
        : (_weightMode
            ? 'Adet başına ${fmt(r.kgBirim)} kg · boy ${fmt(r.boyM, 3)} m'
            : '${r.adet} adet × ${fmt(r.kgBirim)} kg · boy ${fmt(r.boyM, 3)} m');

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: .07),
                  Colors.transparent,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TOPLAM AĞIRLIK',
                    style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace', letterSpacing: 1.5,
                        color: theme.colorScheme.onSurface.withValues(alpha: .55))),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(kg,
                        style: theme.textTheme.displaySmall?.copyWith(
                            fontFamily: 'monospace', fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary)),
                    const SizedBox(width: 7),
                    Text('kg',
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: 'monospace', color: theme.colorScheme.primary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(sub,
                    style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace', fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: .6))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              children: [
                _satir('Adet başına ağırlık', r != null ? '${fmt(r.kgBirim)} kg' : '0,00 kg', theme),
                _satir('Birim ağırlık', r != null ? '${fmt(r.kgMetre)} kg/m' : '0,00 kg/m', theme),
                _satir('Adet', r != null ? '${r.adet}' : '1', theme),
                _satir('Kesit alanı', r != null ? '${fmt(r.kesitMm2)} mm²' : '0,00 mm²', theme),
                _satir('Birim fiyat', r != null ? '${fmt(r.birimFiyat)} TL/kg' : '0,00 TL/kg', theme),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: .035),
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.catalog != null ? 'KATALOG AĞIRLIK FORMÜLÜ' : 'KESİT FORMÜLÜ',
                        style: TextStyle(fontFamily: 'monospace', fontSize: 9,
                            letterSpacing: 1.3,
                            color: theme.colorScheme.onSurface.withValues(alpha: .5)),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        r?.formul ??
                            (widget.catalog != null
                                ? 'm = G · L · n   (G = ${fmt(widget.catalog!.kgm, 1)} kg/m · katalog)'
                                : _profil.formul),
                        style: TextStyle(fontFamily: 'monospace', fontSize: 11,
                            color: theme.colorScheme.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 11, 12, 13),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: .07),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: .25)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TOPLAM FİYAT',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 10,
                              letterSpacing: 1.2,
                              color: theme.colorScheme.onSurface.withValues(alpha: .65))),
                      Text(r != null ? '${fmt(r.fiyat)} TL' : '0,00 TL',
                          style: theme.textTheme.titleLarge?.copyWith(
                              fontFamily: 'monospace', fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _paylas,
                        icon: const Icon(Icons.share_outlined, size: 16),
                        label: const Text('PAYLAŞ',
                            style: TextStyle(fontFamily: 'monospace', fontSize: 11, letterSpacing: 1)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          side: BorderSide(color: theme.dividerColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ),
                    // path_provider web'de desteklenmediği için KAYDET yalnızca mobil/masaüstünde görünür.
                    if (!kIsWeb) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _kaydet,
                          icon: const Icon(Icons.save_outlined, size: 16),
                          label: const Text('KAYDET',
                              style: TextStyle(fontFamily: 'monospace', fontSize: 11, letterSpacing: 1)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            side: BorderSide(color: theme.dividerColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _satir(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: .62))),
          Text(value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
