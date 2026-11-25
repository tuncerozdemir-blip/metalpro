import 'package:flutter/material.dart';

import '../core/catalog.dart';
import '../draw/drawing.dart';
import '../theme.dart';
import '../widgets/blueprint.dart';
import 'calc.dart';
import 'sizes.dart';

class SeriesScreen extends StatelessWidget {
  const SeriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(onHome: () => Navigator.of(context).popUntil((r) => r.isFirst)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 50),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SubHeader(
                  title: 'I / H Profil Serileri',
                  badge: '8 SERİ · $toplamBeden BEDEN',
                  onBack: () => Navigator.of(context).pop(),
                ),
                const HeroBlock(
                  kicker: 'SERİ SEÇİMİ',
                  count: 'EN 10365 · KATALOG',
                  title: 'I / H profil tipini seçin',
                  description: 'Gerçek katalog ölçüleriyle hesaplamak için seri ve beden seçin. Kendi ölçülerinizi girmek isterseniz Keyfi Hesap’ı kullanın.',
                ),
                LayoutBuilder(builder: (context, c) {
                  final count = c.maxWidth >= 900 ? 4 : (c.maxWidth >= 620 ? 3 : (c.maxWidth >= 420 ? 2 : 1));
                  return GridView.count(
                    crossAxisCount: count,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: count >= 3 ? .68 : .74,
                    children: [
                      for (final s in seriler)
                        TechnicalCard(
                          code: s.ad,
                          designation: '${s.ad} · ${s.std}',
                          title: s.ad,
                          description: s.aciklama,
                          svg: solidSvg('i'),
                          meta: '${katalogVerisi[s.key]!.length} BEDEN   ${s.aralik} mm   ${s.std}',
                          action: 'BEDENLERİ GÖR  →',
                          height: 150,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => SizesScreen(series: s)),
                          ),
                        ),
                      TechnicalCard(
                        code: 'USER',
                        designation: 'KEYFİ HESAP',
                        title: 'KEYFİ HESAP',
                        description: 'Kendi ölçülerinizi girin (h · b · tw · tf).',
                        svg: sectionSvg('i'),
                        meta: 'SERBEST ÖLÇÜ   mm / cm / m',
                        action: 'ÖLÇÜ GİR  →',
                        height: 150,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CalcScreen(shape: 'i')),
                        ),
                      ),
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
}
