import 'package:flutter/material.dart';
import '../../core/models/game_category.dart';
import '../../core/services/app_store.dart';
import '../../core/services/game_session.dart';
import '../game/game_screen.dart';
import '../questions/custom_questions_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppStore store;
  const HomeScreen({super.key, required this.store});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selected = 'friends';
  int? maxRounds; // null means unlimited
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = gameCategories.firstWhere((c) => c.id == selected);
    final count = widget.store.countFor(selected);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: 'الإعدادات',
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(store: widget.store),
                        ),
                      ),
                    ),
                    Text(
                      'PASS THE PHONE',
                      style: theme.textTheme.labelLarge?.copyWith(
                        letterSpacing: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      tooltip: 'أسئلتي',
                      icon: const Icon(Icons.edit_note_rounded),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CustomQuestionsScreen(store: widget.store),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primaryContainer,
                    ),
                    child: Icon(
                      Icons.phone_android_rounded,
                      size: 58,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'ادّي الموبايل',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(fontSize: 34),
                ),
                const SizedBox(height: 8),
                Text(
                  'اقرأ السؤال، اختار صاحبك، وخلي الموبايل يلف!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 26),
                Text('اختاروا المود', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                ...gameCategories.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => setState(() => selected = c.id),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: c.color.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(c.icon, color: c.color),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.title,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    Text(
                                      '${c.subtitle} • ${widget.store.countFor(c.id)} سؤال',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                selected == c.id
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: selected == c.id
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('عدد الجولات', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final option in <int?>[null, 10, 20, 30, 50])
                      ChoiceChip(
                        label: Text(option == null ? 'مفتوح ∞' : '$option'),
                        selected: maxRounds == option,
                        onSelected: (_) => setState(() => maxRounds = option),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'الأسئلة بتتخلط تلقائيًا. لو خلصت، بتبدأ دورة جديدة.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: count == 0
                      ? null
                      : () {
                          final session = GameSession(
                            widget.store.available(selected),
                            limit: maxRounds,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GameScreen(
                                session: session,
                                category: category,
                              ),
                            ),
                          );
                        },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    count == 0 ? 'ضيف أسئلة للمود الأول' : 'يلا نبدأ!',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
