import 'package:quizaipro_mobile/features/flashcards/domain/algorithms/fsrs_algorithm.dart';
import 'package:quizaipro_mobile/features/flashcards/domain/entities/flashcard.dart';

/// Aggregate FSRS memory state for a set of cards — the Dart twin of the
/// backend `fsrs.deck_retention`. Lets the offline-first app show per-deck
/// retention without a round-trip, staying consistent with the server (parity
/// pinned by the FSRS parity test).
class DeckRetentionResult {
  const DeckRetentionResult({
    required this.now,
    required this.forecast,
    required this.fading,
    required this.studied,
  });

  /// Average recall probability across studied cards now (%, null if none).
  final int? now;

  /// Forecast in [horizonDays] with no review (%, null if none studied).
  final int? forecast;

  /// Studied cards already below the target retention.
  final int fading;

  /// How many cards have been studied at least once.
  final int studied;

  bool get hasData => studied > 0 && now != null;
}

abstract final class RetentionCalculator {
  static DeckRetentionResult forCards(
    List<Flashcard> cards, {
    DateTime? now,
    int horizonDays = 7,
  }) {
    final at = now ?? DateTime.now();
    final studied = cards.where((c) => c.repetitions > 0).toList();
    if (studied.isEmpty) {
      return const DeckRetentionResult(
          now: null, forecast: null, fading: 0, studied: 0);
    }

    var sumNow = 0.0;
    var sumFuture = 0.0;
    var fading = 0;
    for (final c in studied) {
      final elapsed = c.lastStudiedAt == null
          ? 0.0
          : at.difference(c.lastStudiedAt!).inSeconds / 86400.0;
      final rNow = FsrsAlgorithm.cardRetrievability(
        stability: c.stability,
        interval: c.interval,
        elapsedDays: elapsed,
      );
      final rFuture = FsrsAlgorithm.cardRetrievability(
        stability: c.stability,
        interval: c.interval,
        elapsedDays: elapsed + horizonDays,
      );
      sumNow += rNow;
      sumFuture += rFuture;
      if (rNow < FsrsAlgorithm.targetRetention) fading++;
    }

    final n = studied.length;
    return DeckRetentionResult(
      now: (sumNow / n * 100).round(),
      forecast: (sumFuture / n * 100).round(),
      fading: fading,
      studied: n,
    );
  }
}
