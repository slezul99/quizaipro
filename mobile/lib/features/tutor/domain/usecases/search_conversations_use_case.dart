import 'package:fpdart/fpdart.dart';

import 'package:quizaipro_mobile/core/error/failures.dart';
import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/tutor/domain/entities/conversation.dart';
import 'package:quizaipro_mobile/features/tutor/domain/repositories/tutor_repository.dart';

class SearchConversationsUseCase
    implements UseCase<List<Conversation>, String> {
  const SearchConversationsUseCase(this._repository);

  final TutorRepository _repository;

  @override
  Future<Either<Failure, List<Conversation>>> call(String query) =>
      _repository.searchConversations(query);
}
