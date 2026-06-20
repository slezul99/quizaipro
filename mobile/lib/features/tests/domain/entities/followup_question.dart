/// A fresh practice question the AI generates on the topic of a mistake, so the
/// student can reinforce understanding right after the diagnosis (mobile mirror
/// of the web `/api/followup-question`).
class FollowupQuestion {
  const FollowupQuestion({
    required this.question,
    required this.options,
    required this.correctLetter,
    required this.explanation,
  });

  final String question;
  final List<FollowupOption> options;
  final String correctLetter;
  final String explanation;

  factory FollowupQuestion.fromJson(Map<String, dynamic> json) =>
      FollowupQuestion(
        question: (json['question'] ?? '') as String,
        options: ((json['options'] ?? const []) as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(FollowupOption.fromJson)
            .toList(),
        correctLetter: (json['correct_letter'] ?? '') as String,
        explanation: (json['explanation'] ?? '') as String,
      );
}

class FollowupOption {
  const FollowupOption({required this.letter, required this.text});

  final String letter;
  final String text;

  factory FollowupOption.fromJson(Map<String, dynamic> json) => FollowupOption(
        letter: (json['letter'] ?? '') as String,
        text: (json['text'] ?? '') as String,
      );
}
