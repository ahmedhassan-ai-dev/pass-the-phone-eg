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
          child: AnimatedBuilder(
            animation: store,
            builder: (context, _) => ListView(
              padding: const EdgeInsets.all(22),
              children: [
                Text(
                  'طريقة اللعب',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        title: const Text('شاشة تسليم الموبايل'),
                        subtitle: const Text(
                          'لو قفلتها، الزر هيعرض السؤال التالي مباشرة. التغيير بيبدأ من اللعبة الجديدة.',
                        ),
                        value: store.handoffEnabled,
                        onChanged: store.setHandoffEnabled,
                        secondary: const Icon(Icons.phone_android_rounded),
                      ),
                      const Divider(height: 1, indent: 18, endIndent: 18),
                      SwitchListTile.adaptive(
                        title: const Text('اهتزازات خفيفة'),
                        subtitle: const Text(
                          'عند اختيار الفئة والتنقل بين الأسئلة.',
                        ),
                        value: store.hapticsEnabled,
                        onChanged: store.setHapticsEnabled,
                        secondary: const Icon(Icons.vibration_rounded),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'إضافات اللعب',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Card(
                  child: SwitchListTile.adaptive(
                    title: const Text('كروت مفاجأة'),
                    subtitle: const Text(
                      'تحديات مختلفة تظهر وسط أسئلة The Crew. بتبدأ من اللعبة الجديدة.',
                    ),
                    value: store.surpriseEnabled,
                    onChanged: store.setSurpriseEnabled,
                    secondary: const Icon(Icons.auto_awesome_rounded),
                  ),
                ),
                const SizedBox(height: 28),
                Text('المظهر', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
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
                Center(
                  child: Text(
                    'Pass The Phone · v0.7',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
