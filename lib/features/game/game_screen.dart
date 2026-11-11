import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/models/game_category.dart';
import '../../core/services/game_session.dart';

class GameScreen extends StatefulWidget {
  final GameSession session;
  final GameCategory category;
  const GameScreen({super.key, required this.session, required this.category});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  void advance() {
    final session = widget.session;
    if (session.phase == GamePhase.finished) {
      Navigator.pop(context);
      return;
    }
    if (session.phase == GamePhase.question) {
      HapticFeedback.mediumImpact();
      setState(session.handOff);
    } else {
      HapticFeedback.lightImpact();
      setState(session.revealNext);
    }
  }

  Future<bool> confirmExit() async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('نخرج من اللعبة؟'),
          content: const Text(
            'الجولة الحالية هتنتهي، بس الأسئلة اللي اتسألت محفوظة.',
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
      ) ??
      false;

  Future<void> exitGame() async {
    if (await confirmExit() && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;
    final session = widget.session;
    final finished = session.phase == GamePhase.finished;
    final handoff = session.phase == GamePhase.handoff;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final animationDuration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 390);
    final headline = finished
        ? 'كفاية فضايح لحد كده 🎉'
        : handoff
        ? 'الموبايل معاك دلوقتي؟'
        : session.current.text;

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
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: exitGame,
                          tooltip: 'خروج',
                          icon: const Icon(Icons.close_rounded),
                        ),
                        Expanded(
                          child: Text(
                            widget.category.title,
                            textAlign: TextAlign.center,
                            style: t.textTheme.titleMedium,
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: Text(
                            finished ? '✓' : '${session.round}',
                            textAlign: TextAlign.center,
                            style: t.textTheme.titleMedium?.copyWith(
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    if (!session.isUnlimited) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: finished ? 1 : session.round / session.limit!,
                          minHeight: 5,
                          backgroundColor: scheme.surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(height: 13),
                    ],
                    Expanded(
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: animationDuration,
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(
                                    begin: 0.94,
                                    end: 1,
                                  ).animate(animation),
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.06),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                ),
                              ),
                          child: Container(
                            key: ValueKey(
                              '${session.round}_${session.phase.name}',
                            ),
                            width: double.infinity,
                            constraints: const BoxConstraints(minHeight: 330),
                            padding: const EdgeInsets.fromLTRB(28, 35, 28, 35),
                            decoration: BoxDecoration(
                              color: handoff
                                  ? scheme.secondaryContainer
                                  : t.cardTheme.color,
                              borderRadius: BorderRadius.circular(34),
                              border: Border.all(
                                color: widget.category.color.withValues(
                                  alpha: 0.3,
                                ),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: scheme.shadow.withValues(alpha: 0.06),
                                  blurRadius: 30,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  finished
                                      ? Icons.celebration_rounded
                                      : handoff
                                      ? Icons.phone_android_rounded
                                      : widget.category.icon,
                                  color: widget.category.color,
                                  size: 43,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  finished
                                      ? 'خلصت الجولة'
                                      : handoff
                                      ? 'الدور عليك'
                                      : 'مين فيكم؟',
                                  style: t.textTheme.titleMedium?.copyWith(
                                    color: scheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  headline,
                                  textAlign: TextAlign.center,
                                  style: t.textTheme.headlineMedium?.copyWith(
                                    fontSize: 27,
                                    height: 1.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  finished
                                      ? 'نفس القعدة، أسئلة جديدة المرة الجاية.'
                                      : handoff
                                      ? 'اضغط لما تكون جاهز للسؤال.'
                                      : 'اختار حد وادّيله الموبايل.',
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
                    const SizedBox(height: 16),
                    SizedBox(
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
                              : 'سلّمت الموبايل',
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
