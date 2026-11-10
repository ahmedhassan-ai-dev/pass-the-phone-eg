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
  String category = 'custom';
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
      ).showSnackBar(const SnackBar(content: Text('اتضاف السؤال ✅')));
    } on ArgumentError catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${e.message}')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('أسئلتك الخاصة')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'اسأل شلتك بطريقتك ✍️',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'اختار المود. الأسئلة بتتحفظ على الجهاز وتظهر في المود المختار.',
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                minLines: 2,
                maxLines: 4,
                maxLength: 180,
                decoration: const InputDecoration(
                  hintText: 'ادّي الموبايل لأكتر واحد...',
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'تظهر في مود'),
                items: gameCategories
                    .map(
                      (c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.title)),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => category = value ?? 'custom'),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: saving ? null : add,
                icon: const Icon(Icons.add_rounded),
                label: const Text('إضافة السؤال'),
              ),
              const SizedBox(height: 26),
              Text(
                'أسئلتي (${widget.store.customQuestions.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (widget.store.customQuestions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('لسه مفيش أسئلة مضافة. ابدأ بأول سؤال!'),
                ),
              ...widget.store.customQuestions.reversed.map((q) {
                final categoryName = gameCategories
                    .firstWhere((c) => c.id == q.category)
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
                            title: const Text('حذف السؤال؟'),
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
                          await widget.store.removeQuestion(q.id);
                          if (mounted) setState(() {});
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
