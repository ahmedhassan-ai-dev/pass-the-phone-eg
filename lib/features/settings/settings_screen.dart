import 'package:flutter/material.dart';
import '../../core/services/app_store.dart';

class SettingsScreen extends StatelessWidget {
  final AppStore store;
  const SettingsScreen({super.key, required this.store});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('الإعدادات')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Text('المظهر', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          RadioGroup<ThemeMode>(
            groupValue: store.themeMode,
            onChanged: (mode) {
              if (mode != null) store.setTheme(mode);
            },
            child: const Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  title: Text('حسب إعدادات الجهاز'),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  title: Text('الوضع الفاتح ☀️'),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  title: Text('الوضع الداكن 🌙'),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          const ListTile(
            leading: Icon(Icons.offline_bolt_rounded),
            title: Text('Offline بالكامل'),
            subtitle: Text('مفيش حسابات أو إنترنت مطلوب للعب'),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Pass The Phone'),
            subtitle: Text('نسخة 0.2.0 • من غير إعلانات حاليًا'),
          ),
        ],
      ),
    ),
  );
}
