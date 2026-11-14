import 'package:flutter/material.dart';
import '../../core/models/game_category.dart';
import '../../core/services/app_store.dart';

class CustomQuestionsScreen extends StatefulWidget {
  final AppStore store;
  const CustomQuestionsScreen({super.key, required this.store});
  @override
  State<CustomQuestionsScreen> createState() => _CustomQuestionsScreenState();
}

class _CustomQuestionsScreenState extends State<CustomQuestionsScreen> {
  final controller = TextEditingController();
  String category = 'friends';
  bool saving = false;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> add() async {
    if (saving) return;
    setState(() => saving = true);
    try {
      await widget.store.addQuestion(controller.text, category);
      if (!mounted) return;
      controller.clear();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('السؤال اتضاف للقعدة ✨')));
      setState(() {});
    } on ArgumentError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${e.message}')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر حفظ السؤال. النص لسه موجود؛ حاول مرة تانية.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('أسئلتي')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(22),
              children: [
                Text('اسأل بطريقتك', style: t.textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text(
                  'أسئلتك هتظهر وسط أسئلة المود بشكل عشوائي.',
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: t.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 180,
                  decoration: const InputDecoration(
                    hintText: 'ادّي الموبايل لأكتر واحد...',
                  ),
                ),
                const SizedBox(height: 9),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'الفئة'),
                  items: gameCategories
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.title)),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => category = value ?? 'friends'),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: saving ? null : add,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('ضيف السؤال'),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'الأسئلة المضافة (${widget.store.customQuestions.length})',
                  style: t.textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (widget.store.customQuestions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('لسه مفيش أسئلة. إيه أول سؤال عندك؟'),
                  ),
                ...widget.store.customQuestions.reversed.map((q) {
                  final categoryId = q.category == 'savage'
                      ? 'friends'
                      : q.category;
                  final categoryName = gameCategories
                      .firstWhere(
                        (c) => c.id == categoryId,
                        orElse: () => gameCategories.first,
                      )
                      .title;
                  return Card(
                    child: ListTile(
                      title: Text(q.text),
                      subtitle: Text(categoryName),
                      trailing: IconButton(
                        tooltip: 'حذف',
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () async {
                          final approved = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('تحذف السؤال؟'),
                              content: Text(q.text),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('إلغاء'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('حذف'),
                                ),
                              ],
                            ),
                          );
                          if (approved == true) {
                            try {
                              await widget.store.removeQuestion(q.id);
                              if (mounted) setState(() {});
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'تعذر حذف السؤال. حاول مرة تانية.',
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
