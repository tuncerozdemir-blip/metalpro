import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:metalpro/main.dart';
import 'package:metalpro/screens/home.dart';

void main() {
  testWidgets('Ana sayfa 9 profil kartı gösterir', (WidgetTester tester) async {
    await tester.pumpWidget(const MetalProApp());

    expect(find.text('Metal Ağırlık Hesaplayıcı'), findsOneWidget);
    expect(find.text('HESAPLA  →'), findsNWidgets(9));
  });

  testWidgets('Telefonda ana sayfada 3 kart yan yana sığar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    final karts = find.byType(Card);
    expect(karts, findsNWidgets(9));

    final xler = <double>{};
    for (var i = 0; i < 9; i++) {
      xler.add(tester.getTopLeft(karts.at(i)).dx.round().toDouble());
    }
    expect(xler.length, 3, reason: 'Üç farklı sütun x konumu bekleniyor: $xler');

    // Kompakt kartlarda açıklama satırı gizli, aksiyon görünür.
    expect(find.text('Altıgen kesitli dolu profil'), findsNothing);
    expect(find.text('HESAPLA  →'), findsNWidgets(9));
  });
}
