import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:speedodriver/core/api/api_client.dart';
import 'package:speedodriver/core/api/endpoints.dart';

class ThemeBundle {
  final ThemeData light;
  final ThemeData dark;
  final ThemeMode mode;
  ThemeBundle(this.light, this.dark, this.mode);
}

final uiThemeVarsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiClientProvider);
  try {
    final r = await api.getJson<Map<String, dynamic>>(Endpoints.uiThemeCurrent);
    final vars = (r['vars'] as Map).cast<String, dynamic>();
    return vars;
  } catch (_) {
    return {};
  }
});

final themeControllerProvider = Provider<ThemeBundle>((ref) {
  final vars = ref.watch(uiThemeVarsProvider).valueOrNull ?? {};

  Color parse(String? v, Color fallback) {
    if (v == null || v.isEmpty) return fallback;
    final s = v.replaceAll('#', '');
    if (s.length == 6) return Color(int.parse('FF$s', radix: 16));
    return fallback;
  }

  final bg = parse(vars['--bg']?.toString(), const Color(0xFFFFFFFF));
  final fg = parse(vars['--fg']?.toString(), const Color(0xFF111827));
  final primary = parse(vars['--primary']?.toString(), const Color(0xFF0EA5E9));
  final surface = parse(vars['--surface']?.toString(), const Color(0xFFF5F5F5));

  ThemeData mk(Brightness b) {
    final scheme = ColorScheme.fromSeed(seedColor: primary, brightness: b, surface: surface);
    return ThemeData(
      brightness: b,
      colorScheme: scheme.copyWith(surface: surface, primary: primary),
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(backgroundColor: surface, foregroundColor: fg),
      useMaterial3: true,
    );
  }

  return ThemeBundle(mk(Brightness.light), mk(Brightness.dark), ThemeMode.system);
});