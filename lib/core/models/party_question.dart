class PartyQuestion {
  final String id;
  final String category;
  final String text;
  final bool isCustom;

  const PartyQuestion({
    required this.id,
    required this.category,
    required this.text,
    this.isCustom = false,
  });

  factory PartyQuestion.fromJson(Map<String, dynamic> data) => PartyQuestion(
    id: data['id'] as String,
    category: data['category'] as String,
    text: data['text'] as String,
    isCustom: data['isCustom'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'text': text,
    'isCustom': isCustom,
  };
}
