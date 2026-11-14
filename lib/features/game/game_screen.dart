import 'package:flutter/material.dart';
import '../../core/models/game_category.dart';
import '../../core/services/game_session.dart';
import '../../core/services/haptic_service.dart';
import '../../core/widgets/press_scale.dart';
import '../../core/widgets/question_card.dart';

class GameScreen extends StatefulWidget {
  final GameSession session;
  final GameCategory category;
  final HapticService haptics;
  const GameScreen({
    super.key,
    required this.session,
    required this.category,
    required this.haptics,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  void advance() {
    final game = widget.session;
    if (game.phase == GamePhase.finished) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      if (game.phase == GamePhase.question) {
        game.handOff();
      } else {
        game.revealNext();
      }
    });
    if (game.phase == GamePhase.handoff) {
      widget.haptics.passPhone();
    } else if (game.phase == GamePhase.question) {
      widget.haptics.revealQuestion();
    }
  }

  Future<void> exitGame() async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('نخرج من اللعبة؟'),
        content: const Text(
          'الأسئلة اللي ظهرت هتفضل متسجلة عشان ما تتكررش بسرعة.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('نكمل'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    if (approved == true && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final game = widget.session;
    final handoff = game.phase == GamePhase.handoff;
    final finished = game.phase == GamePhase.finished;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 440);
    final contentKey = ValueKey('${game.round}-${game.phase.name}');
    final question = finished
        ? 'عايزين جولة كمان؟'
        : handoff
        ? 'الموبايل وصل؟'
        : game.current.text;
    final isSurprise =
        !handoff && !finished && game.current.category == 'surprise';
    final header = finished
        ? 'خلصت الجولة'
        : handoff
        ? 'الدور عليك'
        : isSurprise
        ? 'كارت مفاجأة ✦'
        : 'مين فيكم؟';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) await exitGame();
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: exitGame,
                          tooltip: 'إنهاء اللعبة',
                          icon: const Icon(Icons.close_rounded),
                        ),
                        Expanded(
                          child: Text(
                            widget.category.title,
                            textAlign: TextAlign.center,
                            style: t.textTheme.titleMedium,
                          ),
                        ),
                        Semantics(
                          label: finished
                              ? 'خلصت الجولة'
                              : 'الجولة ${game.round}',
                          excludeSemantics: true,
                          child: SizedBox(
                            width: 49,
                            child: Text(
                              finished ? '✓' : '${game.round}',
                              textAlign: TextAlign.center,
                              style: t.textTheme.titleMedium?.copyWith(
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!game.isUnlimited) ...[
                      const SizedBox(height: 9),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: finished ? 1 : game.round / game.limit!,
                          minHeight: 5,
                          backgroundColor: scheme.surfaceContainerHighest,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) => Center(
                          child: SingleChildScrollView(
                            child: AnimatedSwitcher(
                              duration: duration,
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0, .09),
                                        end: Offset.zero,
                                      ).animate(animation),
                                      child: ScaleTransition(
                                        scale: Tween<double>(begin: .94, end: 1)
                                            .animate(
                                              CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutCubic,
                                              ),
                                            ),
                                        child: child,
                                      ),
                                    ),
                                  ),
                              child: QuestionCard(
                                key: contentKey,
                                tint: widget.category.color,
                                isHandoff: handoff,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      finished
                                          ? Icons.celebration_rounded
                                          : handoff
                                          ? Icons.phone_android_rounded
                                          : isSurprise
                                          ? Icons.auto_awesome_rounded
                                          : widget.category.icon,
                                      color: widget.category.color,
                                      size: 39,
                                    ),
                                    const SizedBox(height: 19),
                                    Text(
                                      header,
                                      style: t.textTheme.titleMedium?.copyWith(
                                        color: scheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      question,
                                      textAlign: TextAlign.center,
                                      textScaler: MediaQuery.textScalerOf(
                                        context,
                                      ),
                                      style: t.textTheme.headlineMedium
                                          ?.copyWith(
                                            fontSize: 26,
                                            height: 1.56,
                                          ),
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      finished
                                          ? 'ممكن تبدأوا قعدة جديدة من الرئيسية.'
                                          : handoff
                                          ? 'اكشف السؤال لما تبقى جاهز.'
                                          : 'اختار الشخص وسلّمه الموبايل.',
                                      textAlign: TextAlign.center,
                                      style: t.textTheme.bodyMedium?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    PressScale(
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: advance,
                          icon: Icon(
                            finished
                                ? Icons.home_rounded
                                : handoff
                                ? Icons.visibility_rounded
                                : Icons.arrow_back_rounded,
                          ),
                          label: Text(
                            finished
                                ? 'الرئيسية'
                                : handoff
                                ? 'اكشف السؤال'
                                : game.handoffEnabled
                                ? 'سلّمت الموبايل'
                                : 'السؤال التالي',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
