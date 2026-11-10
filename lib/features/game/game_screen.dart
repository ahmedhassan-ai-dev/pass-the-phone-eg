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
    HapticFeedback.selectionClick();
    setState(() {
      if (widget.session.phase == GamePhase.question) {
        widget.session.handOff();
      } else if (widget.session.phase == GamePhase.handoff) {
        widget.session.revealNext();
      } else {
        Navigator.pop(context);
      }
    });
  }

  Future<bool> confirmExit() async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('نوقف اللعبة؟'),
          content: const Text('الجولة الحالية هتتقفل.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('كمّل لعب'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('خروج'),
            ),
          ],
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = widget.session;
    final finished = session.phase == GamePhase.finished;
    final handoff = session.phase == GamePhase.handoff;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && await confirmExit() && context.mounted)
          Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.category.title),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'خروج',
            onPressed: () async {
              if (await confirmExit() && context.mounted)
                Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                child: Column(
                  children: [
                    Text(
                      finished
                          ? 'انتهت اللعبة'
                          : 'الجولة ${session.round}${session.isUnlimited ? '  •  ∞' : ' / ${session.limit}'}',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (!session.isUnlimited)
                      LinearProgressIndicator(
                        value: finished ? 1 : session.round / session.limit!,
                        minHeight: 5,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    Expanded(
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 420),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(
                                    begin: 0.88,
                                    end: 1,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: Container(
                            key: ValueKey(
                              '${session.round}_${session.phase.name}',
                            ),
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 35,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  widget.category.color.withValues(alpha: 0.14),
                                  theme.colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  finished
                                      ? Icons.celebration_rounded
                                      : handoff
                                      ? Icons.phone_android_rounded
                                      : Icons.visibility_rounded,
                                  size: 58,
                                  color: widget.category.color,
                                ),
                                const SizedBox(height: 26),
                                Text(
                                  finished
                                      ? 'يا سلام! خلصتوا الجولات 🎉'
                                      : handoff
                                      ? 'الموبايل وصل لك!\nجاهز للسؤال الجديد؟'
                                      : session.current.text,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(fontSize: 27, height: 1.5),
                                ),
                                if (!finished && !handoff) ...[
                                  const SizedBox(height: 18),
                                  Text(
                                    'اختار شخص واحد وادّيله الموبايل',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: advance,
                        icon: Icon(
                          finished
                              ? Icons.home_rounded
                              : handoff
                              ? Icons.auto_awesome_rounded
                              : Icons.arrow_forward_rounded,
                        ),
                        label: Text(
                          finished
                              ? 'الرئيسية'
                              : handoff
                              ? 'اكشف السؤال الجديد'
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
