import 'package:freezed_annotation/freezed_annotation.dart';

part 'sse_chunk.freezed.dart';

@freezed
sealed class SseChunk with _$SseChunk {
  /// A partial text delta from the AI stream.
  const factory SseChunk.delta({required String text}) = SseChunkDelta;

  /// The stream finished successfully.
  const factory SseChunk.done() = SseChunkDone;

  /// The stream terminated with an error from the server.
  const factory SseChunk.error({required String message}) = SseChunkError;
}
