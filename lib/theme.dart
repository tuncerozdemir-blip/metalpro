import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

const Color primaryLight = Color(0xFF0D5C82);
const Color primaryDark = Color(0xFF2B8FC0);
const Color bgLight = Color(0xFFEAEFF4);
const Color bgDark = Color(0xFF0A1622);
const Color panelLight = Color(0xFFFFFFFF);
const Color panelDark = Color(0xFF101F2E);
const Color lineLight = Color(0xFFD8E1EA);
const Color lineDark = Color(0xFF1E3346);

ThemeData _build(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final bg = dark ? bgDark : bgLight;
  final panel = dark ? panelDark : panelLight;
  final line = dark ? lineDark : lineLight;
  final primary = dark ? primaryDark : primaryLight;
  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: brightness,
    surface: panel,
  ).copyWith(primary: primary, outline: line);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    cardColor: panel,
    dividerColor: line,
    fontFamily: 'Roboto',
    appBarTheme: AppBarTheme(
      backgroundColor: panel,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 12,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: line)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),
  );
}

final ThemeData lightTheme = _build(Brightness.light);
final ThemeData darkTheme = _build(Brightness.dark);

/// Ortak üst çubuk: marka + ana sayfa + tema düğmesi.
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onHome;

  const TopBar({super.key, required this.onHome});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? const Color(0xFF071320) : const Color(0xFF0B1D30),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.view_sidebar_outlined, color: Color(0xFF7DD3FC), size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('MetalPro',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Text('AĞIRLIK HESAPLAYICI',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 9, letterSpacing: 1.4, color: Color(0xFF5A7186))),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Ana sayfa',
          icon: const Icon(Icons.home_outlined, size: 19),
          onPressed: onHome,
        ),
        IconButton(
          tooltip: 'Temayı değiştir',
          icon: Icon(
            theme.brightness == Brightness.dark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
            size: 19,
          ),
          onPressed: () {
            themeMode.value = theme.brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
          },
        ),
        const SizedBox(width: 6),
      ],
    );
  }
}

/// Bölüm başlığı + geri dönüş düğmesi.
class SubHeader extends StatelessWidget {
  final String title;
  final String badge;
  final String? backLabel;
  final VoidCallback onBack;

  const SubHeader({
    super.key,
    required this.title,
    required this.badge,
    this.backLabel,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 15),
            label: Text(backLabel ?? (title.startsWith('I / H') ? 'PROFİLLER' : 'GERİ'),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 10, letterSpacing: .8)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              side: BorderSide(color: theme.dividerColor),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .09),
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: .25)),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(badge,
                style: TextStyle(fontFamily: 'monospace', fontSize: 10,
                    letterSpacing: 1, color: theme.colorScheme.primary)),
          ),
        ],
      ),
    );
  }
}

class HeroBlock extends StatelessWidget {
  final String kicker;
  final String count;
  final String title;
  final String description;

  const HeroBlock({
    super.key,
    required this.kicker,
    required this.count,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Kicker(text: kicker, primary: theme.colorScheme.primary),
              const SizedBox(width: 8),
              _Kicker(text: count, primary: theme.colorScheme.onSurface.withValues(alpha: .55)),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 7),
          Text(description,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: .64))),
        ],
      ),
    );
  }
}

class _Kicker extends StatelessWidget {
  final String text;
  final Color primary;
  const _Kicker({required this.text, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .09),
        border: Border.all(color: primary.withValues(alpha: .22)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(text,
          style: TextStyle(fontFamily: 'monospace', fontSize: 9.5,
              letterSpacing: 1.4, color: primary)),
    );
  }
}
