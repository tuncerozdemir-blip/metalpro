import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const Color bpBg = Color(0xFF0A1B2C);
const Color bpLine = Color(0x127DD3FC);
const Color bpText = Color(0xFF8DC2E6);
const Color bpMuted = Color(0xFF4F83AD);

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = bpLine
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 13) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 13) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RaSymbol extends StatelessWidget {
  const RaSymbol({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(13, 8),
      painter: _RaPainter(),
    );
  }
}

class _RaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = bpMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawLine(const Offset(1, 3), const Offset(6, 11), p);
    canvas.drawLine(const Offset(6, 11), const Offset(15, 0), p);
    canvas.drawLine(const Offset(13, 0), const Offset(19, 6), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Teknik pafta: ızgara zemin + çizim + antet.
class BlueprintPanel extends StatelessWidget {
  final String svg;
  final String tag;
  final String code;
  final String designation;
  final double height;
  final bool compact;

  const BlueprintPanel({
    super.key,
    required this.svg,
    required this.tag,
    required this.code,
    required this.designation,
    this.height = 196,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final foot = compact ? 19.0 : 23.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height - foot,
          child: Stack(
            children: [
              CustomPaint(painter: _GridPainter(), child: const SizedBox.expand()),
              Positioned(
                left: compact ? 5 : 9,
                top: compact ? 4 : 7,
                child: Text(
                  tag,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: compact ? 6 : 7.5,
                    letterSpacing: compact ? .4 : 1.2,
                    color: const Color(0xFF5F93BD),
                  ),
                ),
              ),
              Positioned(
                right: compact ? 5 : 9,
                top: compact ? 3 : 5,
                child: Text(
                  code,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: compact ? 8 : 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: compact ? .5 : 1.2,
                    color: const Color(0xFF3F78A6),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(compact ? 3 : 6, compact ? 13 : 17, compact ? 3 : 6, 2),
                  child: SvgPicture.string(
                    svg,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: foot,
          padding: EdgeInsets.symmetric(horizontal: compact ? 5 : 8),
          decoration: const BoxDecoration(
            color: Color(0x08060C16),
            border: Border(top: BorderSide(color: Color(0x2A7DD3FC))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  designation,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: compact ? 7 : 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: compact ? .2 : .7,
                    color: bpText,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              if (!compact) const RaSymbol(),
              const SizedBox(width: 2),
              Text('Ra 3,2',
                  style: TextStyle(fontFamily: 'monospace', fontSize: compact ? 6 : 7.5, color: bpMuted)),
              if (!compact) ...[
                const SizedBox(width: 10),
                const Text('mm',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 7.5, color: bpMuted)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Ana sayfa / seri sayfasındaki kart görünümü.
class TechnicalCard extends StatelessWidget {
  final String code;
  final String designation;
  final String title;
  final String description;
  final String svg;
  final String? formula;
  final String? meta;
  final String action;
  final VoidCallback onTap;
  final double height;
  final bool compact;

  const TechnicalCard({
    super.key,
    required this.code,
    required this.designation,
    required this.title,
    required this.description,
    required this.svg,
    this.formula,
    this.meta,
    required this.action,
    required this.onTap,
    this.height = 196,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlueprintPanel(
              svg: svg,
              tag: 'KESİT GÖRÜNÜMÜ',
              code: code,
              designation: designation,
              height: height,
              compact: compact,
            ),
            Padding(
              padding: compact
                  ? const EdgeInsets.fromLTRB(7, 7, 7, 8)
                  : const EdgeInsets.fromLTRB(14, 12, 14, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: compact ? 1 : null,
                      overflow: compact ? TextOverflow.ellipsis : null,
                      style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: compact ? 10.5 : null, fontWeight: FontWeight.bold)),
                  if (!compact) ...[
                    const SizedBox(height: 3),
                    Text(description,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: .62))),
                  ],
                  if (formula != null && !compact) ...[
                    const SizedBox(height: 7),
                    Text(formula!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 9.5,
                            color: theme.colorScheme.primary)),
                  ],
                  if (meta != null && !compact) ...[
                    const SizedBox(height: 6),
                    Text(meta!,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 9.5,
                            color: Color(0xFF5A7186))),
                  ],
                  SizedBox(height: compact ? 5 : 9),
                  Text(action,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: compact ? 8 : 9.5,
                          letterSpacing: compact ? .6 : 1.2,
                          color: theme.colorScheme.onSurface.withValues(alpha: .6))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
