import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'library_view_notifier.g.dart';

@Riverpod(keepAlive: true)
class LibraryViewNotifier extends _$LibraryViewNotifier {
  @override
  bool build() => true;

  void toggleView() => state = !state;

  void setGrid() => state = true;

  void setList() => state = false;
}
