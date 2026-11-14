import 'package:flutter/material.dart';
import '../../core/models/game_category.dart';
import '../../core/services/app_store.dart';
import '../game/game_screen.dart';
import '../questions/custom_questions_screen.dart';
import '../settings/settings_screen.dart';
import '../../core/widgets/press_scale.dart';

class HomeScreen extends StatefulWidget {
  final AppStore store;
  const HomeScreen({super.key, required this.store});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selected = 'friends';
  int? maxRounds;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final category = gameCategories.firstWhere((c) => c.id == selected);
    final count = widget.store.countFor(selected);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'PASS THE PHONE',
                        style: t.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'أسئلتي',
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CustomQuestionsScreen(store: widget.store),
                          ),
                        );
                        if (mounted) setState(() {});
                      },
                      icon: const Icon(Icons.edit_note_rounded),
                    ),
                    IconButton(
                      tooltip: 'الإعدادات',
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(store: widget.store),
                        ),
                      ),
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 19),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 31,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.70),
                    borderRadius: BorderRadius.circular(32),
                    image: DecorationImage(
                      image: const AssetImage(
                        'assets/branding/purple_pass_the_phone_hero.png',
                      ),
                      fit: BoxFit.cover,
                      // A 35% tint leaves the unchanged text too low contrast
                      // over this artwork; use a softer, theme-aware blend.
                      colorFilter: ColorFilter.mode(
                        scheme.primaryContainer.withValues(alpha: 0.85),
                        BlendMode.srcOver,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: scheme.surface.withValues(alpha: 0.66),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.phone_android_rounded,
                              size: 26,
                              color: scheme.primary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'YOUR TURN',
                            style: t.textTheme.labelSmall?.copyWith(
                              color: scheme.onPrimaryContainer.withValues(
                                alpha: 0.74,
                              ),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'ادّي الموبايل',
                        style: t.textTheme.headlineLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'اختاروا المود، والباقي على القعدة.',
                        style: t.textTheme.bodyLarge?.copyWith(
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                PressScale(
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        widget.store.haptics.gameStart();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GameScreen(
                              session: widget.store.startGame('friends'),
                              category: gameCategories.first,
                              haptics: widget.store.haptics,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.flash_on_rounded),
                      label: const Text('ابدأ بسرعة  ·  The Crew'),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text('اختار المود', style: t.textTheme.titleLarge),
                const SizedBox(height: 13),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final tileWidth = (constraints.maxWidth - 12) / 2;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: gameCategories.map((c) {
                        final active = selected == c.id;
                        return Semantics(
                          key: ValueKey('category-${c.id}'),
                          selected: active,
                          button: true,
                          child: SizedBox(
                            width: tileWidth,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOutCubic,
                              decoration: BoxDecoration(
                                color: active
                                    ? c.color.withValues(alpha: 0.17)
                                    : t.cardTheme.color,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  width: active ? 2 : 1,
                                  color: active
                                      ? c.color
                                      : scheme.outlineVariant.withValues(
                                          alpha: 0.35,
                                        ),
                                ),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: () {
                                  if (selected != c.id) {
                                    widget.store.haptics.selection();
                                  }
                                  setState(() => selected = c.id);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(17),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            c.icon,
                                            color: c.color,
                                            size: 29,
                                          ),
                                          const Spacer(),
                                          Icon(
                                            active
                                                ? Icons.check_circle_rounded
                                                : Icons.circle_outlined,
                                            size: 20,
                                            color: active
                                                ? c.color
                                                : scheme.outline,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 22),
                                      Text(
                                        c.title,
                                        style: t.textTheme.titleLarge?.copyWith(
                                          fontSize: 19,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        c.subtitle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: t.textTheme.bodySmall?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text('عدد الجولات', style: t.textTheme.titleLarge),
                    ),
                    Text(
                      maxRounds == null ? 'مفتوح ∞' : '$maxRounds جولة',
                      style: t.textTheme.labelLarge?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in <int?>[null, 10, 20, 30, 50])
                      ChoiceChip(
                        label: Text(option == null ? '∞ مفتوح' : '$option'),
                        selected: maxRounds == option,
                        onSelected: (_) {
                          if (maxRounds != option) {
                            widget.store.haptics.selection();
                          }
                          setState(() => maxRounds = option);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: count == 0
                        ? null
                        : () {
                            widget.store.haptics.gameStart();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GameScreen(
                                  session: widget.store.startGame(
                                    selected,
                                    limit: maxRounds,
                                  ),
                                  category: category,
                                  haptics: widget.store.haptics,
                                ),
                              ),
                            );
                          },
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: Text(count == 0 ? 'ضيف أسئلة الأول' : 'يلا نلعب'),
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
