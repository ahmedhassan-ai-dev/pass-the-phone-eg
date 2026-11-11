import 'package:flutter/material.dart';
import '../../core/services/app_store.dart';

class SettingsScreen extends StatelessWidget {
  final AppStore store;
  const SettingsScreen({super.key, required this.store});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('الإعدادات')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
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
                      title: Text('تلقائي'),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.light,
                      title: Text('فاتح'),
                    ),
                    RadioListTile<ThemeMode>(
                      value: ThemeMode.dark,
                      title: Text('داكن'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Center(child: Text('Pass The Phone · v0.4')),
            ],
          ),
        ),
      ),
    ),
  );
}
