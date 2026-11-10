import 'package:flutter/material.dart';
import '../core/services/app_store.dart';
import '../core/theme/app_theme.dart';
import '../features/home/home_screen.dart';

class PassThePhoneApp extends StatelessWidget {
  final AppStore store;
  const PassThePhoneApp({super.key, required this.store});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ادّي الموبايل',
      theme: AppTheme.build(Brightness.light),
      darkTheme: AppTheme.build(Brightness.dark),
      themeMode: store.themeMode,
      locale: const Locale('ar'),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: HomeScreen(store: store),
    ),
  );
}
