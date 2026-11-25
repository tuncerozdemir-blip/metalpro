import 'package:flutter/material.dart';

import '../core/engine.dart';
import '../draw/drawing.dart';
import '../theme.dart';
import '../widgets/blueprint.dart';
import 'calc.dart';
import 'series.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, String key) {
    if (key == 'i') {
      Navigator.of(context).push(MaterialPageRoute(
        settings: const RouteSettings(name: 'series'),
        builder: (_) => const SeriesScreen(),
      ));
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => CalcScreen(shape: key)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(onHome: () {}),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 50),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeroBlock(
                  kicker: 'KESİT SEÇİMİ',
                  count: '9 PROFİL',
                  title: 'Metal Ağırlık Hesaplayıcı',
                  description: 'Hesaplamak istediğiniz profili seçin. Ölçüler mm olarak girilir, sonuç kg ve TL olarak hesaplanır.',
                ),
                LayoutBuilder(builder: (context, c) {
                  // Telefonda da en az 3 kart yan yana sığar; geniş ekranda 4-5.
                  // Kartlar kompakt kaldığı için dar sütunlarda metin taşması olmaz.
                  final count = c.maxWidth >= 1100 ? 5 : (c.maxWidth >= 820 ? 4 : 3);
                  return GridView.count(
                    crossAxisCount: count,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 8,
                    childAspectRatio: .58,
                    children: [
                      for (final p in profiles)
                        TechnicalCard(
                          code: p.kod,
                          designation: p.tanitim,
                          title: p.ad,
                          description: p.aciklama,
                          svg: solidSvg(p.key),
                          formula: p.formul,
                          action: 'HESAPLA  →',
                          onTap: () => _open(context, p.key),
                          compact: true,
                          height: 120,
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
