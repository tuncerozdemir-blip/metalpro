import 'dart:math' as math;

import 'package:flutter/material.dart';

/* Web sürümündeki teknik çizim motorunun Dart karşılığı.
   Kesit görünümü 240x150, solid perspektif görünümü 300x180 viewBox kullanır. */

const String _dim = '#3fb6f0';
const String _lbl = '#8fd0f5';
const String _out = '#d5e6f5';
const String _mono = 'ui-monospace,Consolas,monospace';

const String _defs = '''
<defs>
  <pattern id="hatch" width="9" height="9" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">
    <line x1="0" y1="0" x2="0" y2="9" stroke="#a8d8f5" stroke-width="1.1" opacity=".32"/>
  </pattern>
  <linearGradient id="steel" x1="0" y1="0" x2="1" y2="1">
    <stop offset="0" stop-color="#3a7099"/><stop offset=".45" stop-color="#1d486c"/><stop offset="1" stop-color="#0c2439"/>
  </linearGradient>
  <linearGradient id="bore" x1="0" y1="1" x2="1" y2="0">
    <stop offset="0" stop-color="#050e17"/><stop offset=".55" stop-color="#0c1e2e"/><stop offset="1" stop-color="#2b5b82"/>
  </linearGradient>
  <filter id="softBlur" x="-35%" y="-70%" width="170%" height="240%">
    <feGaussianBlur stdDeviation="7"/>
  </filter>
</defs>''';

String dimH(num x1, num x2, num y, String label, [bool below = false]) =>
    '<line x1="$x1" y1="$y" x2="$x2" y2="$y" stroke="$_dim" stroke-width=".9"/>'
    '<polygon points="$x1,$y ${x1 + 6},${y - 3} ${x1 + 6},${y + 3}" fill="$_dim"/>'
    '<polygon points="$x2,$y ${x2 - 6},${y - 3} ${x2 - 6},${y + 3}" fill="$_dim"/>'
    '<text x="${(x1 + x2) / 2}" y="${below ? y + 12 : y - 5}" fill="$_lbl" '
    'font-family="$_mono" font-size="9.5" text-anchor="middle">$label</text>';

String dimV(num y1, num y2, num x, String label, String side) {
  final right = side == 'right';
  return '<line x1="$x" y1="$y1" x2="$x" y2="$y2" stroke="$_dim" stroke-width=".9"/>'
      '<polygon points="$x,$y1 ${x - 3},${y1 + 6} ${x + 3},${y1 + 6}" fill="$_dim"/>'
      '<polygon points="$x,$y2 ${x - 3},${y2 - 6} ${x + 3},${y2 - 6}" fill="$_dim"/>'
      '<text x="${right ? x + 7 : x - 7}" y="${(y1 + y2) / 2 + 3.5}" fill="$_lbl" '
      'font-family="$_mono" font-size="9.5" text-anchor="${right ? 'start' : 'end'}">$label</text>';
}

String ext(num x1, num y1, num x2, num y2) =>
    '<line x1="$x1" y1="$y1" x2="$x2" y2="$y2" stroke="$_dim" stroke-width=".6" '
    'stroke-dasharray="3 2" opacity=".6"/>';

String cl(num x1, num y1, num x2, num y2) =>
    '<line x1="$x1" y1="$y1" x2="$x2" y2="$y2" stroke="#5f93bd" stroke-width=".7" '
    'stroke-dasharray="10 3 2 3" opacity=".7"/>';

String hpoly(String pts) =>
    '<polygon points="$pts" fill="url(#steel)"/>'
    '<polygon points="$pts" fill="url(#hatch)" stroke="$_out" stroke-width="1.35" stroke-linejoin="round"/>';

String hrect(num x, num y, num w, num h) =>
    '<rect x="$x" y="$y" width="$w" height="$h" fill="url(#steel)"/>'
    '<rect x="$x" y="$y" width="$w" height="$h" fill="url(#hatch)" stroke="$_out" stroke-width="1.35"/>';

String hcircle(num cx, num cy, num r) =>
    '<circle cx="$cx" cy="$cy" r="$r" fill="url(#steel)"/>'
    '<circle cx="$cx" cy="$cy" r="$r" fill="url(#hatch)" stroke="$_out" stroke-width="1.35"/>';

String hole(num x, num y, num w, num h) =>
    '<rect x="$x" y="$y" width="$w" height="$h" fill="#0a1b2c" stroke="$_out" stroke-width="1.1"/>';

String note(num x, num y, String txt, [String anchor = 'start']) =>
    '<text x="$x" y="$y" fill="$_lbl" font-family="$_mono" font-size="8.5" '
    'text-anchor="$anchor" opacity=".9">$txt</text>';

const Map<String, Map<String, String>> _katalogLabels = {
  'altikose': {'d': '30', 's': '26'},
  'dolumil': {'d': '&#8960;30'},
  'boru': {'D': '&#8960;114,3', 't': '3,6'},
  'kare': {'a': '20'},
  'kutu': {'A': '100', 'B': '50', 't': '3'},
  't': {'A': '100', 'B': '100', 't': '10'},
  'i': {'A': '200', 'B': '100', 't': '5,6', 's': '8,5'},
  'l': {'A': '50', 'B': '50', 't': '5'},
  'sac': {'A': '1000', 'B': '2000', 't': '3'},
};

const Map<String, Map<String, String>> _formLabels = {
  'altikose': {'d': 'd', 's': 's'},
  'dolumil': {'d': '&#8960;d'},
  'boru': {'D': '&#8960;D', 't': 't'},
  'kare': {'a': 'a'},
  'kutu': {'A': 'A', 'B': 'B', 't': 't'},
  't': {'A': 'A', 'B': 'B', 't': 't'},
  'i': {'A': 'A', 'B': 'B', 't': 't', 's': 's'},
  'l': {'A': 'A', 'B': 'B', 't': 't'},
  'sac': {'A': 'A', 'B': 'B', 't': 't'},
};

String _sectionBody(String key, Map<String, String> l) {
  switch (key) {
    case 'altikose':
      return [
        cl(118, 26, 118, 118), cl(66, 72, 170, 72),
        hpoly('160,72 139,36 97,36 76,72 97,108 139,108'),
        ext(76, 72, 76, 126), ext(160, 72, 160, 126),
        dimH(76, 160, 120, l['d']!, true),
        ext(97, 36, 50, 36), ext(97, 108, 50, 108),
        dimV(36, 108, 44, l['s']!, 'left')
      ].join();
    case 'dolumil':
      return [
        cl(118, 20, 118, 124), cl(62, 72, 174, 72), hcircle(118, 72, 40),
        ext(78, 72, 78, 132), ext(158, 72, 158, 132),
        dimH(78, 158, 126, l['d']!, true)
      ].join();
    case 'boru':
      return [
        cl(112, 20, 112, 124), cl(60, 72, 164, 72), hcircle(112, 72, 40),
        '<circle cx="112" cy="72" r="28" fill="#0a1b2c" stroke="$_out" stroke-width="1.1"/>',
        ext(72, 72, 72, 132), ext(152, 72, 152, 132),
        dimH(72, 152, 124, l['D']!, true),
        '<line x1="141" y1="45" x2="172" y2="28" stroke="$_dim" stroke-width=".7"/>',
        note(175, 29, l['t']!)
      ].join();
    case 'kare':
      return [
        cl(118, 24, 118, 120), cl(64, 72, 172, 72), hrect(80, 34, 76, 76),
        ext(80, 34, 80, 20), ext(156, 34, 156, 20), dimH(80, 156, 22, l['a']!)
      ].join();
    case 'kutu':
      return [
        cl(122, 28, 122, 116), cl(50, 71, 192, 71), hrect(58, 36, 128, 70),
        hole(69, 47, 106, 48),
        ext(58, 106, 58, 122), ext(186, 106, 186, 122), dimH(58, 186, 124, l['A']!, true),
        ext(186, 36, 202, 36), ext(186, 106, 202, 106), dimV(36, 106, 200, l['B']!, 'right'),
        '<line x1="64" y1="42" x2="44" y2="26" stroke="$_dim" stroke-width=".7"/>',
        note(40, 25, l['t']!, 'end')
      ].join();
    case 't':
      return [
        cl(118, 24, 118, 124),
        hpoly('62,32 174,32 174,46 124,46 124,116 112,116 112,46 62,46'),
        ext(62, 32, 62, 20), ext(174, 32, 174, 20), dimH(62, 174, 20, l['B']!),
        ext(174, 32, 190, 32), ext(124, 116, 190, 116), dimV(32, 116, 188, l['A']!, 'right'),
        ext(62, 32, 54, 32), ext(62, 46, 54, 46), dimV(32, 46, 52, l['t']!, 'left')
      ].join();
    case 'i':
      return [
        cl(118, 22, 118, 126), cl(56, 73, 180, 73),
        hpoly('62,30 174,30 174,44 124,44 124,102 174,102 174,116 62,116 62,102 112,102 112,44 62,44'),
        ext(62, 30, 62, 18), ext(174, 30, 174, 18), dimH(62, 174, 18, l['B']!),
        ext(174, 30, 190, 30), ext(174, 116, 190, 116), dimV(30, 116, 188, l['A']!, 'right'),
        ext(62, 30, 54, 30), ext(62, 44, 54, 44), dimV(30, 44, 52, l['s']!, 'left'),
        ext(112, 116, 112, 130), ext(124, 116, 124, 130), dimH(112, 124, 130, l['t']!, true)
      ].join();
    case 'l':
      return [
        cl(118, 22, 118, 116),
        hpoly('62,30 62,118 176,118 176,104 76,104 76,30'),
        ext(176, 30, 192, 30), ext(176, 118, 192, 118), dimV(30, 118, 190, l['A']!, 'right'),
        ext(62, 118, 62, 132), ext(176, 118, 176, 132), dimH(62, 176, 132, l['B']!, true),
        ext(62, 30, 62, 18), ext(76, 30, 76, 18), dimH(62, 76, 18, l['t']!)
      ].join();
    case 'sac':
      return [
        hrect(44, 64, 152, 16),
        ext(44, 80, 44, 100), ext(196, 80, 196, 100), dimH(44, 196, 96, l['A']!, true),
        ext(196, 64, 216, 64), ext(196, 80, 216, 80), dimV(64, 80, 214, l['t']!, 'right'),
        '<line x1="120" y1="64" x2="120" y2="48" stroke="$_dim" stroke-width=".7"/>',
        note(124, 46, l['B']!)
      ].join();
    default:
      return '';
  }
}

String sectionSvg(String key, {bool form = false}) {
  final labels = form ? _formLabels[key] ?? _formLabels['t']! : _katalogLabels[key] ?? _katalogLabels['t']!;
  return '<svg viewBox="0 0 240 150" preserveAspectRatio="xMidYMid meet" '
      'xmlns="http://www.w3.org/2000/svg">$_defs${_sectionBody(key, labels)}</svg>';
}

/* -------------------- Solid perspektif -------------------- */

class _Shape {
  final List<Offset> outer;
  final List<List<Offset>> holes;
  final Offset d;
  const _Shape(this.outer, this.holes, this.d);
}

const Map<String, _Shape> _solids = {
  't': _Shape([
    Offset(50, 44), Offset(160, 44), Offset(160, 66), Offset(115, 66),
    Offset(115, 150), Offset(97, 150), Offset(97, 66), Offset(50, 66)
  ], [], Offset(44, -28)),
  'i': _Shape([
    Offset(50, 40), Offset(160, 40), Offset(160, 58), Offset(114, 58),
    Offset(114, 132), Offset(160, 132), Offset(160, 150), Offset(50, 150),
    Offset(50, 132), Offset(96, 132), Offset(96, 58), Offset(50, 58)
  ], [], Offset(44, -28)),
  'kare': _Shape([
    Offset(56, 58), Offset(144, 58), Offset(144, 146), Offset(56, 146)
  ], [], Offset(44, -28)),
  'kutu': _Shape([
    Offset(52, 54), Offset(168, 54), Offset(168, 144), Offset(52, 144)
  ], [
    [Offset(66, 68), Offset(154, 68), Offset(154, 130), Offset(66, 130)]
  ], Offset(44, -28)),
  'boru': _Shape([
    Offset(157, 100), Offset(151, 127), Offset(135, 145), Offset(108, 152),
    Offset(81, 145), Offset(65, 127), Offset(59, 100), Offset(65, 73),
    Offset(81, 55), Offset(108, 48), Offset(135, 55), Offset(151, 73)
  ], [
    [Offset(141, 100), Offset(137, 116), Offset(124, 129), Offset(105, 136),
     Offset(86, 129), Offset(73, 116), Offset(69, 100), Offset(73, 84),
     Offset(86, 71), Offset(105, 64), Offset(124, 71), Offset(137, 84)]
  ], Offset(52, -34)),
  'dolumil': _Shape([
    Offset(157, 100), Offset(151, 127), Offset(135, 145), Offset(108, 152),
    Offset(81, 145), Offset(65, 127), Offset(59, 100), Offset(65, 73),
    Offset(81, 55), Offset(108, 48), Offset(135, 55), Offset(151, 73)
  ], [], Offset(52, -34)),
  'altikose': _Shape([
    Offset(157, 100), Offset(131, 55), Offset(79, 55), Offset(53, 100),
    Offset(79, 145), Offset(131, 145)
  ], [], Offset(44, -28)),
  'l': _Shape([
    Offset(52, 50), Offset(52, 150), Offset(160, 150), Offset(160, 126),
    Offset(76, 126), Offset(76, 50)
  ], [], Offset(44, -28)),
  'sac': _Shape([
    Offset(56, 84), Offset(186, 84), Offset(186, 98), Offset(56, 98)
  ], [], Offset(70, -38)),
};

String _path(List<Offset> pts) => 'M${pts.map((p) => '${p.dx},${p.dy}').join('L')}Z';

String _faceShade(Offset p1, Offset p2) {
  final dx = p2.dx - p1.dx, dy = p2.dy - p1.dy;
  final len = math.sqrt(dx * dx + dy * dy);
  final nx = dy / len, ny = -dx / len;
  final nd = nx * -0.6 + ny * -0.8;
  final f = 0.34 + 0.62 * math.max(0, math.min(1, (nd + 1) / 2));
  return 'rgb(${(24 + 76 * f).round()},${(48 + 106 * f).round()},${(72 + 118 * f).round()})';
}

String solidSvg(String key) {
  final s = _solids[key] ?? _solids['i']!;
  final o = s.d;
  final c = s.outer;
  var minX = 1e9, maxX = -1e9, maxY = -1e9;
  for (final p in c) {
    minX = math.min(minX, p.dx);
    maxX = math.max(maxX, p.dx);
    maxY = math.max(maxY, p.dy);
  }
  final cx = (minX + maxX) / 2 + o.dx * 0.35;
  final rx = (maxX - minX) / 2 + 8;
  final out = StringBuffer();

  out.writeln('<ellipse cx="${cx.toStringAsFixed(1)}" cy="${(maxY + 11).toStringAsFixed(1)}" '
      'rx="${rx.toStringAsFixed(1)}" ry="8" fill="#04101c" opacity=".6" filter="url(#softBlur)"/>');
  out.writeln('<path d="${_path(c)}" transform="translate(${o.dx},${o.dy})" fill="#14314c" '
      'stroke="$_out" stroke-opacity=".45" stroke-width="1.1"/>');

  for (var i = 0; i < c.length; i++) {
    final p1 = c[i], p2 = c[(i + 1) % c.length];
    final shade = _faceShade(p1, p2);
    out.writeln('<polygon points="${p1.dx},${p1.dy} ${p2.dx},${p2.dy} '
        '${p2.dx + o.dx},${p2.dy + o.dy} ${p1.dx + o.dx},${p1.dy + o.dy}" '
        'fill="$shade" stroke="$shade" stroke-width=".5"/>');
  }
  for (final h in s.holes) {
    out.writeln('<path d="${_path(h)}" fill="url(#bore)"/>');
  }

  final front = StringBuffer(_path(c));
  for (final h in s.holes) {
    front.write(_path(h));
  }
  out.writeln('<path d="$front" fill="url(#steel)" fill-rule="evenodd"/>');
  out.writeln('<path d="$front" fill="url(#hatch)" fill-rule="evenodd" '
      'stroke="$_out" stroke-width="1.5" stroke-linejoin="round"/>');

  return '<svg viewBox="0 0 300 180" preserveAspectRatio="xMidYMid meet" '
      'xmlns="http://www.w3.org/2000/svg">$_defs$out</svg>';
}
