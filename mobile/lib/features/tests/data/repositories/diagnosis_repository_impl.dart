import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/features/tests/data/remote/diagnosis_remote_data_source.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/followup_question.dart';
import 'package:quizaipro_mobile/features/tests/domain/entities/mistake_diagnosis.dart';
import 'package:quizaipro_mobile/features/tests/domain/repositories/diagnosis_repository.dart';

class DiagnosisRepositoryImpl implements DiagnosisRepository {
  DiagnosisRepositoryImpl({required DiagnosisRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final DiagnosisRemoteDataSource _remote;

  @override
  Future<Either<Failure, MistakeDiagnosis>> diagnose({
    required String question,
    required String chosen,
    required String correct,
  }) async {
    try {
      final result = await _remote.diagnose(
        question: question,
        chosen: chosen,
        correct: correct,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FollowupQuestion>> followup({
    required String question,
    required String correct,
    String? misconception,
  }) async {
    try {
      final result = await _remote.followup(
        question: question,
        correct: correct,
        misconception: misconception,
      );
      return Right(result);
    } on DioException catch (e) {
      return Left(_fromDio(e));
    } catch (e) {
      return Left(Failure.unknown(message: e.toString()));
    }
  }

  Failure _fromDio(DioException e) {
    if (e.error is Failure) return e.error as Failure;
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionTimeout) {
      return Failure.network(message: e.message ?? 'No internet connection.');
    }
    if (e.response?.statusCode == 401) return const Failure.unauthorized();
    if (e.response?.statusCode == 429) {
      return Failure.rateLimited(message: e.message ?? 'Too many requests.');
    }
    return Failure.server(
      code: e.response?.statusCode?.toString() ?? 'unknown',
      message: e.message ?? 'Server error.',
    );
  }
}
