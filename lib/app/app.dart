import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:speedodriver/core/theme/theme_controller.dart';
import 'package:speedodriver/app/app_theme.dart';
import 'package:speedodriver/app/router.dart';

class AuraMailApp extends ConsumerWidget {
  const AuraMailApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider);
    return MaterialApp.router(
      title: 'app.title'.tr(),
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      theme: AppTheme.lightTheme,
      darkTheme: theme.dark,
      themeMode: theme.mode,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
