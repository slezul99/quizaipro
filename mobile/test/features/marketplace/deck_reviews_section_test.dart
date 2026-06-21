// Drives the real DeckReviewsSection: renders the aggregate + an existing
// review, then rates the deck and asserts the repository receives the stars.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/theme/aurora_tokens.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/deck_review.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/widgets/deck_reviews_section.dart';
import 'package:quizaipro_mobile/l10n/app_localizations.dart';

class _FakeRepo implements MarketplaceRepository {
  _FakeRepo(this._result);
  DeckReviewsResult _result;
  int? lastStars;
  String? lastText;

  @override
  Future<Either<Failure, DeckReviewsResult>> getDeckReviews(String deckId) async =>
      Right(_result);

  @override
  Future<Either<Failure, DeckReview>> submitDeckReview(
      String deckId, int stars, String text) async {
    lastStars = stars;
    lastText = text;
    final mine = DeckReview(
        id: 'me', author: 'You', stars: stars, text: text, createdAt: '', isMine: true);
    _result = DeckReviewsResult(
      rating: stars.toDouble(),
      ratingCount: _result.ratingCount + 1,
      myReview: mine,
      reviews: [mine, ..._result.reviews.where((r) => !r.isMine)],
    );
    return Right(mine);
  }

  @override
  Future<Either<Failure, Unit>> deleteDeckReview(String deckId) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> reportReview(String reviewId) async =>
      const Right(unit);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Widget _host(_FakeRepo repo) => ProviderScope(
      overrides: [marketplaceRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData.light().copyWith(extensions: const [AuroraTokens.light]),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Builder(
              builder: (ctx) => DeckReviewsSection(
                deckId: '1',
                tokens: ctx.aurora,
                l: AppLocalizations.of(ctx)!,
              ),
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('shows aggregate + existing review and submits a rating',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final repo = _FakeRepo(const DeckReviewsResult(
      rating: 4.5,
      ratingCount: 2,
      reviews: [
        DeckReview(
            id: '7',
            author: 'Alice',
            stars: 4,
            text: 'Solid deck',
            createdAt: '2026-01-01',
            isMine: false),
      ],
    ));

    await tester.pumpWidget(_host(repo));
    await tester.pumpAndSettle();

    // Aggregate + the existing review render.
    expect(find.text('⭐ Reviews'), findsOneWidget);
    expect(find.text('★ 4.5  ·  2'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Solid deck'), findsOneWidget);
    expect(find.text('Rate this deck'), findsOneWidget);

    // Submit is disabled until a star is picked.
    expect(repo.lastStars, isNull);

    // Tap the 5th star in the rate form (the large 28px stars), then submit.
    final formStars = find.byIcon(Icons.star_outline_rounded);
    await tester.tap(formStars.at(4));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(repo.lastStars, 5);
  });
}
