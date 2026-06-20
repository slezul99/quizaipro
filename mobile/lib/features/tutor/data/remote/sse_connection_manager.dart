import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:quizaipro_mobile/features/tutor/domain/entities/sse_chunk.dart';

/// Manages a single SSE connection lifecycle.
///
/// Parses the raw `text/event-stream` byte stream and emits [SseChunk]
/// values. The caller owns the returned [Stream] and must cancel its
/// subscription to abort the connection.
class SseConnectionManager {
  SseConnectionManager(this._sseDio);

  final Dio _sseDio;

  /// Opens an SSE stream to [path] with [body] and yields parsed chunks.
  ///
  /// The stream is single-subscription. Cancel the subscription to close
  /// the underlying HTTP connection via [CancelToken].
  Stream<SseChunk> connect({
    required String path,
    required Map<String, dynamic> body,
  }) async* {
    final cancelToken = CancelToken();
    final controller = StreamController<SseChunk>();

    _sseDio
        .post<ResponseBody>(
      path,
      data: jsonEncode(body),
      cancelToken: cancelToken,
      options: Options(responseType: ResponseType.stream),
    )
        .then((response) async {
      final stream = response.data!.stream;
      final buffer = StringBuffer();

      await for (final chunk in stream) {
        buffer.write(utf8.decode(chunk, allowMalformed: true));
        final raw = buffer.toString();
        buffer.clear();

        for (final line in _splitLines(raw)) {
          final parsed = _parseLine(line);
          if (parsed != null && !controller.isClosed) {
            controller.add(parsed);
            if (parsed is SseChunkDone) {
              await controller.close();
              return;
            }
          }
        }
      }

      if (!controller.isClosed) {
        controller.add(const SseChunk.done());
        await controller.close();
      }
    }).catchError((Object e) {
      if (!controller.isClosed) {
        if (e is DioException && CancelToken.isCancel(e)) {
          controller.add(const SseChunk.done());
        } else {
          controller.add(
            SseChunk.error(message: e.toString()),
          );
        }
        controller.close();
      }
    });

    yield* controller.stream.transform(
      StreamTransformer.fromHandlers(
        handleDone: (sink) {
          if (!cancelToken.isCancelled) cancelToken.cancel();
          sink.close();
        },
        handleError: (e, st, sink) {
          cancelToken.cancel();
          sink.addError(e, st);
        },
      ),
    );
  }

  List<String> _splitLines(String raw) {
    // SSE events are separated by double newlines; lines within an event
    // by single newlines.
    return raw.split('\n');
  }

  SseChunk? _parseLine(String line) {
    line = line.trim();
    if (line.isEmpty) return null;

    if (line.startsWith('data: ')) {
      final payload = line.substring(6).trim();
      if (payload == '[DONE]') return const SseChunk.done();

      try {
        final json = jsonDecode(payload) as Map<String, dynamic>;

        // Handle error events sent as data payloads.
        if (json.containsKey('error')) {
          return SseChunk.error(
            message: json['error']?.toString() ?? 'Stream error',
          );
        }

        // Delta: { "delta": "text" } or { "content": "text" }
        final delta =
            json['delta']?.toString() ?? json['content']?.toString();
        if (delta != null) return SseChunk.delta(text: delta);
      } catch (_) {
        // Malformed JSON line — ignore and continue
      }
    }

    if (line.startsWith('event: error')) return null;

    return null;
  }
}
