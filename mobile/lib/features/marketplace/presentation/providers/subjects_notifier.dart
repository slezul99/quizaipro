import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:quizaipro_mobile/core/usecase/usecase.dart';
import 'package:quizaipro_mobile/features/marketplace/domain/entities/subject.dart';
import 'package:quizaipro_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';

part 'subjects_notifier.g.dart';

@Riverpod(keepAlive: true)
class SubjectsNotifier extends _$SubjectsNotifier {
  @override
  Future<List<Subject>> build() async {
    final useCase = ref.read(getSubjectsUseCaseProvider);
    final result = await useCase(const NoParams());
    return result.fold((f) => throw f, (subjects) => subjects);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final useCase = ref.read(getSubjectsUseCaseProvider);
    final result = await useCase(const NoParams());
    state = result.fold(
      (f) => AsyncError(f, StackTrace.current),
      AsyncData.new,
    );
  }
}
