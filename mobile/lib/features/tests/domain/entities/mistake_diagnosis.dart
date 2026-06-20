/// AI diagnosis of a SPECIFIC wrong answer on a test (mobile mirror of the web
/// `/api/diagnose-answer`). Unlike a generic explanation, it is built from the
/// option the student actually chose, so it can name the misconception.
class MistakeDiagnosis {
  const MistakeDiagnosis({
    required this.whyWrong,
    required this.whyCorrect,
    required this.misconception,
    required this.tip,
  });

  final String whyWrong;
  final String whyCorrect;
  final String misconception;
  final String tip;

  factory MistakeDiagnosis.fromJson(Map<String, dynamic> json) =>
      MistakeDiagnosis(
        whyWrong: (json['why_wrong'] ?? '') as String,
        whyCorrect: (json['why_correct'] ?? '') as String,
        misconception: (json['misconception'] ?? '') as String,
        tip: (json['tip'] ?? '') as String,
      );
}
