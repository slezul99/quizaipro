import 'package:freezed_annotation/freezed_annotation.dart';

part 'library_collection.freezed.dart';

@freezed
class LibraryCollection with _$LibraryCollection {
  const factory LibraryCollection({
    required String id,
    required String name,
    required String description,
    required String coverColorHex,
    required int deckCount,
    required DateTime createdAt,
  }) = _LibraryCollection;
}
