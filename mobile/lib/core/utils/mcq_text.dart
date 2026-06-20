/// Matches a lettered multiple-choice option line ("A) ...", "Б. ...", "C- ...").
/// Latin and Cyrillic letters are both accepted to match the backend parser.
final RegExp _mcqOptionLine = RegExp(r'^[A-Za-zА-Яа-яЁё]\s*[)\.\:\-]\s+\S');

/// Returns the question stem of a card front, stripping any block of lettered
/// option lines that quiz/AI-generated decks inline into the front
/// ("What is X?\nA) ...\nB) ..."). Normal flashcards — which have no such
/// block — are returned unchanged.
///
/// Mirrors `_mcq_stem` in the backend (`api_v1/tests.py`) so flashcard study
/// and the test flow show the same question text for the same card.
String mcqStem(String front) {
  final lines = front.split('\n');
  final optionLines =
      lines.where((l) => _mcqOptionLine.hasMatch(l.trim())).length;
  if (optionLines < 2) return front; // not an MCQ-style front — leave as-is

  final stem = lines
      .where((l) => !_mcqOptionLine.hasMatch(l.trim()))
      .join('\n')
      .trim();
  return stem.isEmpty ? front : stem;
}

/// The lettered option lines inlined into an MCQ-style front ("A) …", "B) …"),
/// trimmed. Empty list for a normal flashcard (no inline options).
List<String> mcqOptions(String front) {
  return front
      .split('\n')
      .map((l) => l.trim())
      .where((l) => _mcqOptionLine.hasMatch(l))
      .toList();
}

/// True when a card front carries a block of ≥2 lettered options — i.e. it is
/// a test/MCQ card rather than a plain flashcard.
bool mcqHasOptions(String front) => mcqOptions(front).length >= 2;
