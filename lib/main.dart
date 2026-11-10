import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PassThePhoneApp());
}

class PartyQuestion {
  final String id;
  final String category;
  final String text;
  const PartyQuestion({required this.id, required this.category, required this.text});

  factory PartyQuestion.fromJson(Map<String, dynamic> json) => PartyQuestion(
        id: json['id'] as String,
        category: json['category'] as String,
        text: json['text'] as String,
      );
}

class QuestionRepository {
  static Future<List<PartyQuestion>> load() async {
    final source = await rootBundle.loadString('assets/data/questions.json');
    final parsed = jsonDecode(source) as List<dynamic>;
    return parsed
        .map((item) => PartyQuestion.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}

class GameDeck {
  final List<PartyQuestion> _questions;
  int _index = 0;

  GameDeck(List<PartyQuestion> questions, String category)
      : _questions = questions.where((q) => q.category == category).toList()
          ..shuffle(Random());

  int get count => _questions.length;
  int get index => _index;
  bool get finished => _index >= _questions.length;
  PartyQuestion get current => _questions[_index];
  void next() { if (!finished) _index++; }
}

class PassThePhoneApp extends StatelessWidget {
  const PassThePhoneApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ادّي الموبايل',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF11111E),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B6CFF),
            brightness: Brightness.dark,
          ),
        ),
        home: const HomeScreen(),
      );
}

const categories = <String, ({String title, String subtitle, IconData icon})>{
  'friends': (title: 'الصحاب 😂', subtitle: 'ضحك ورخامة خفيفة', icon: Icons.people_alt_rounded),
  'love': (title: 'الحب ❤️', subtitle: 'كراشات ومواقف', icon: Icons.favorite_rounded),
  'savage': (title: 'الجريء 🔥', subtitle: 'للشلة القريبة', icon: Icons.local_fire_department_rounded),
  'family': (title: 'العيلة 🏠', subtitle: 'للجمعات العائلية', icon: Icons.home_rounded),
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selected = 'friends';
  late final Future<List<PartyQuestion>> questionFuture = QuestionRepository.load();

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: FutureBuilder<List<PartyQuestion>>(
                future: questionFuture,
                builder: (context, snapshot) {
                  final available = snapshot.data?.where((q) => q.category == selected).length ?? 0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      const Icon(Icons.phone_android_rounded, size: 66, color: Color(0xFFB09AFF)),
                      const SizedBox(height: 18),
                      const Text('ادّي الموبايل 📱',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      const Text('اختاروا المود وخلي الموبايل يلف على الشلة!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 15)),
                      const Spacer(),
                      ...categories.entries.map((entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              color: selected == entry.key ? const Color(0xFF383052) : const Color(0xFF202030),
                              child: ListTile(
                                onTap: () => setState(() => selected = entry.key),
                                leading: Icon(entry.value.icon, color: const Color(0xFFB09AFF)),
                                title: Text(entry.value.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(entry.value.subtitle),
                                trailing: Icon(selected == entry.key
                                    ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                              ),
                            ),
                          )),
                      const SizedBox(height: 20),
                      if (snapshot.hasError)
                        const Text('حصلت مشكلة في تحميل الأسئلة.', textAlign: TextAlign.center),
                      FilledButton(
                        onPressed: snapshot.hasData && available > 0
                            ? () => Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => GameScreen(
                                    deck: GameDeck(snapshot.data!, selected),
                                    categoryTitle: categories[selected]!.title,
                                  ),
                                ))
                            : null,
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(60)),
                        child: Text(snapshot.connectionState == ConnectionState.waiting
                            ? 'بنجهز الأسئلة...' : 'ابدأ اللعب ($available سؤال)'),
                      ),
                      const SizedBox(height: 18),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      );
}

class GameScreen extends StatefulWidget {
  final GameDeck deck;
  final String categoryTitle;
  const GameScreen({required this.deck, required this.categoryTitle, super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool handoff = false;

  void advance() {
    HapticFeedback.selectionClick();
    if (!handoff) {
      setState(() => handoff = true);
    } else {
      setState(() {
        widget.deck.next();
        handoff = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deck = widget.deck;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(widget.categoryTitle),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(deck.finished ? 'خلصت الأسئلة!' : 'السؤال ${deck.index + 1} من ${deck.count}',
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 14),
                LinearProgressIndicator(value: deck.count == 0 ? 0 : deck.index / deck.count,
                    minHeight: 6, borderRadius: BorderRadius.circular(8)),
                Expanded(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Column(
                        key: ValueKey('${deck.index}-$handoff'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(deck.finished ? '🎉' : handoff ? '📱' : '👀',
                              style: const TextStyle(fontSize: 64)),
                          const SizedBox(height: 24),
                          Text(
                            deck.finished
                                ? 'خلصت أسئلة المود ده! جربوا مود تاني.'
                                : handoff
                                    ? 'الدور عليك!\nدوس عشان تكشف السؤال الجديد'
                                    : deck.current.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 29, height: 1.5,
                                fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: deck.finished ? () => Navigator.of(context).pop() : advance,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(62)),
                  child: Text(deck.finished ? 'القائمة الرئيسية' : handoff
                      ? 'اكشف السؤال الجديد 👀' : 'سلّمت الموبايل ✅'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
