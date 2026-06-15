import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:speedodriver/app/app.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Supabase (Use --dart-define=SUPABASE_URL=... or replace default value)
  await Supabase.initialize(
    url: const String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://rifcywuokzcykdnrplni.supabase.co',
    ),
    anonKey: const String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'eyJhbGciOiJIUzIMiOiJzdXBhYmFzZSInJwbG5pOjE3ODA5MzI4MzUsImV4cCI6MjA5NjUwODgzNX0.UppZyGNPUFxFxKa500M2FbKckQECJ3nDazKVKPvR7fg',
    ),
  );
  /*{
    // 1. English
    en
    // 2. Hindi (India)
    hi

  }*/
  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('hi')],
        path: 'assets/i18n',
        fallbackLocale: const Locale('en'),
        child: const AuraMailApp(),
      ),
    ),
  );
}
