import 'dart:math' as math;

/// Result of an FSRS scheduling step.
class FsrsResult {
  const FsrsResult({
    required this.stability,
    required this.difficulty,
    required this.interval,
    required this.repetitions,
    required this.nextReviewAt,
  });

  final double stability;
  final double difficulty;
  final int interval;
  final int repetitions;
  final DateTime nextReviewAt;
}

/// FSRS-5 spaced-repetition scheduler — the Dart twin of the backend `fsrs.py`.
///
/// Must stay byte-for-byte equivalent to the Python implementation: identical
/// weights, formulas and rating mapping, so a card scheduled offline on the
/// phone lands on exactly the same interval the server would compute. Parity is
/// pinned by a shared test-vector ([test/fsrs_parity_test.dart]).
///
/// Ratings: 1 = Again, 2 = Hard, 3 = Good, 4 = Easy.
abstract final class FsrsAlgorithm {
  static const List<double> w = [
    0.40255, 1.18385, 3.173, 15.69105, 7.1949, 0.5345, 1.4604, 0.0046,
    1.54575, 0.1192, 1.01925, 1.9395, 0.11, 0.29605, 2.2698, 0.2315,
    2.9898, 0.51655, 0.6621,
  ];
  static const double decay = -0.5;
  // 0.9^(1/decay) - 1 = 19/81 ≈ 0.2345679
  static final double factor = math.pow(0.9, 1.0 / decay).toDouble() - 1.0;
  static const double targetRetention = 0.90;
  static const double minD = 1.0;
  static const double maxD = 10.0;
  static const double minS = 0.01;
  static const int maxInterval = 36500;

  static double _clamp(double x, double lo, double hi) =>
      x < lo ? lo : (x > hi ? hi : x);

  /// Probability of recalling the card now, given days since last review.
  static double retrievability(double elapsedDays, double stability) {
    if (stability <= 0) return 0.0;
    return math
        .pow(1.0 + factor * math.max(elapsedDays, 0.0) / stability, decay)
        .toDouble();
  }

  static int _intervalFor(double stability) {
    final ivl = (stability / factor) *
        (math.pow(targetRetention, 1.0 / decay).toDouble() - 1.0);
    final r = ivl.round();
    return r < 1 ? 1 : (r > maxInterval ? maxInterval : r);
  }

  static double _initDifficulty(int rating) =>
      _clamp(w[4] - math.exp(w[5] * (rating - 1)) + 1.0, minD, maxD);

  static double _nextDifficulty(double d, int rating) {
    final delta = -w[6] * (rating - 3);
    var dNew = d + delta * (10.0 - d) / 9.0;
    dNew = w[7] * _initDifficulty(4) + (1.0 - w[7]) * dNew;
    return _clamp(dNew, minD, maxD);
  }

  static double _stabilityRecall(double d, double s, double r, int rating) {
    final hardPenalty = rating == 2 ? w[15] : 1.0;
    final easyBonus = rating == 4 ? w[16] : 1.0;
    final inc = math.exp(w[8]) *
        (11.0 - d) *
        math.pow(s, -w[9]).toDouble() *
        (math.exp(w[10] * (1.0 - r)) - 1.0) *
        hardPenalty *
        easyBonus;
    return s * (1.0 + inc);
  }

  static double _stabilityForget(double d, double s, double r) {
    final sf = w[11] *
        math.pow(d, -w[12]).toDouble() *
        (math.pow(s + 1.0, w[13]).toDouble() - 1.0) *
        math.exp(w[14] * (1.0 - r));
    return math.min(sf, s); // forgetting must not raise stability
  }

  // ef 1.3 (hard) -> D≈10 ; ef 2.5 (easy) -> D≈2.
  static double _seedDifficultyFromEf(double ef) =>
      _clamp(11.0 - ((ef - 1.3) / 1.2) * 9.0, minD, maxD);

  /// Schedule the next review. [stability]/[difficulty] are null for cards that
  /// have never been through FSRS; legacy SM-2 cards (repetitions > 0) are
  /// seeded from [easeFactor]/[interval].
  static FsrsResult calculate({
    double? stability,
    double? difficulty,
    required int repetitions,
    required double easeFactor,
    required int interval,
    required double elapsedDays,
    required int rating,
    DateTime? now,
  }) {
    final at = now ?? DateTime.now();
    double s;
    double d;

    final firstReview = repetitions == 0 && stability == null;
    if (firstReview) {
      s = math.max(w[rating - 1], minS);
      d = _initDifficulty(rating);
    } else {
      if (stability == null) {
        s = math.max(interval.toDouble(), 1.0);
        d = _seedDifficultyFromEf(easeFactor);
      } else {
        s = stability;
        d = difficulty!;
      }
      final r = retrievability(elapsedDays, s);
      d = _nextDifficulty(d, rating);
      s = rating == 1 ? _stabilityForget(d, s, r) : _stabilityRecall(d, s, r, rating);
    }

    s = math.max(s, minS);
    final ivl = rating == 1 ? 0 : _intervalFor(s);

    return FsrsResult(
      stability: s,
      difficulty: d,
      interval: ivl,
      repetitions: rating == 1 ? 0 : repetitions + 1,
      nextReviewAt: at.add(Duration(days: ivl)),
    );
  }
}
