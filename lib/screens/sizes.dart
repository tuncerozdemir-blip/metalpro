import 'package:flutter/material.dart';

import '../core/catalog.dart';
import '../core/engine.dart';
import '../theme.dart';
import 'calc.dart';

class SizesScreen extends StatefulWidget {
  final SeriesInfo series;

  const SizesScreen({super.key, required this.series});

  @override
  State<SizesScreen> createState() => _SizesScreenState();
}

class _SizesScreenState extends State<SizesScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final all = katalogVerisi[widget.series.key] ?? const <CatalogRow>[];
    final q = _search.text.trim().toLowerCase();
    final rows = q.isEmpty ? all : all.where((r) => r.ad.toLowerCase().contains(q)).toList();

    return Scaffold(
      appBar: TopBar(onHome: () => Navigator.of(context).popUntil((r) => r.isFirst)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 50),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SubHeader(
                  title: '${widget.series.ad} · Beden Seçimi',
                  badge: '${widget.series.ad} / ${all.length}',
                  onBack: () => Navigator.of(context).pop(),
                ),
                HeroBlock(
                  kicker: 'BEDEN LİSTESİ',
                  count: 'h × b × tw × tf · kg/m',
                  title: '${widget.series.ad} profil bedenleri',
                  description: 'Listeden bir beden seçtiğinizde ölçüler ve katalog ağırlığı otomatik doldurulur.',
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 360,
                        child: TextField(
                          controller: _search,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search, size: 18),
                            hintText: 'Beden ara (ör. 200, IPE 300…)',
                          ),
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${rows.length} / ${all.length} BEDEN',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 10,
                              color: theme.colorScheme.onSurface.withValues(alpha: .6))),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Container(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .45),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                        child: Row(children: [
                          const Expanded(flex: 14, child: Text('TANIM', style: _head)),
                          const Expanded(flex: 15, child: Text('h × b (mm)', style: _head)),
                          if (MediaQuery.of(context).size.width >= 700)
                            const Expanded(flex: 14, child: Text('tw / tf (mm)', style: _head)),
                          const Expanded(flex: 8, child: Text('kg/m', style: _head, textAlign: TextAlign.right)),
                          const SizedBox(width: 16),
                        ]),
                      ),
                      if (rows.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('Beden bulunamadı.'),
                        )
                      else
                        for (final r in rows)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => CalcScreen(
                                  shape: 'i',
                                  catalog: r,
                                  series: widget.series,
                                ),
                              )),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.dividerColor))),
                                child: Row(children: [
                                  Expanded(flex: 14, child: Text(r.ad, style: const TextStyle(
                                      fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold))),
                                  Expanded(flex: 15, child: Text(
                                      '${sayi(r.h)} × ${sayi(r.b)}',
                                      style: TextStyle(fontFamily: 'monospace', fontSize: 12,
                                          color: theme.colorScheme.onSurface.withValues(alpha: .6)))),
                                  if (MediaQuery.of(context).size.width >= 700)
                                    Expanded(flex: 14, child: Text(
                                        '${sayi(r.tw)} / ${sayi(r.tf)}',
                                        style: TextStyle(fontFamily: 'monospace', fontSize: 12,
                                            color: theme.colorScheme.onSurface.withValues(alpha: .6)))),
                                  Expanded(flex: 8, child: Text(sayi(r.kgm),
                                      textAlign: TextAlign.right,
                                      style: TextStyle(fontFamily: 'monospace', fontSize: 12,
                                          fontWeight: FontWeight.bold, color: theme.colorScheme.primary))),
                                  const SizedBox(width: 16, child: Icon(Icons.arrow_forward, size: 13)),
                                ]),
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const TextStyle _head = TextStyle(
  fontFamily: 'monospace',
  fontSize: 9,
  letterSpacing: 1.2,
  color: Color(0xFF5A7186),
);
