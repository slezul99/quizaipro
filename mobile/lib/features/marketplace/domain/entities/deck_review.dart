/// A single marketplace deck review (star rating + optional text).
class DeckReview {
  const DeckReview({
    required this.id,
    required this.author,
    required this.stars,
    required this.text,
    required this.createdAt,
    required this.isMine,
  });

  final String id;
  final String author;
  final int stars;
  final String text;
  final String createdAt;
  final bool isMine;

  factory DeckReview.fromJson(Map<String, dynamic> json) => DeckReview(
        id: (json['id'] ?? '').toString(),
        author: (json['author'] ?? '') as String,
        stars: (json['stars'] ?? 0) as int,
        text: (json['text'] ?? '') as String,
        createdAt: (json['created_at'] ?? '') as String,
        isMine: (json['is_mine'] ?? false) as bool,
      );
}

/// Aggregate + list of reviews for one deck (mirrors GET .../reviews).
class DeckReviewsResult {
  const DeckReviewsResult({
    required this.rating,
    required this.ratingCount,
    required this.reviews,
    this.myReview,
  });

  final double rating;
  final int ratingCount;
  final List<DeckReview> reviews;
  final DeckReview? myReview;

  factory DeckReviewsResult.fromJson(Map<String, dynamic> json) =>
      DeckReviewsResult(
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        ratingCount: (json['rating_count'] ?? 0) as int,
        myReview: json['my_review'] != null
            ? DeckReview.fromJson(json['my_review'] as Map<String, dynamic>)
            : null,
        reviews: ((json['reviews'] ?? const []) as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(DeckReview.fromJson)
            .toList(),
      );
}
