import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_review.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';

part 'deck_reviews_notifier.g.dart';

/// Loads and mutates the reviews for one marketplace deck. Each mutation
/// re-fetches so the aggregate (rating/count) and the list stay consistent.
@riverpod
class DeckReviewsNotifier extends _$DeckReviewsNotifier {
  late String _deckId;

  @override
  Future<DeckReviewsResult> build(String deckId) async {
    _deckId = deckId;
    final res = await ref.read(marketplaceRepositoryProvider).getDeckReviews(deckId);
    return res.fold((f) => throw f, (r) => r);
  }

  /// Returns true on success so the UI can clear/keep the form.
  Future<bool> submit(int stars, String text) async {
    final res = await ref
        .read(marketplaceRepositoryProvider)
        .submitDeckReview(_deckId, stars, text);
    if (res.isRight()) {
      ref.invalidateSelf();
      await future;
      return true;
    }
    return false;
  }

  Future<void> deleteMine() async {
    await ref.read(marketplaceRepositoryProvider).deleteDeckReview(_deckId);
    ref.invalidateSelf();
    await future;
  }

  Future<void> report(String reviewId) async {
    await ref.read(marketplaceRepositoryProvider).reportReview(reviewId);
    ref.invalidateSelf();
    await future;
  }
}
