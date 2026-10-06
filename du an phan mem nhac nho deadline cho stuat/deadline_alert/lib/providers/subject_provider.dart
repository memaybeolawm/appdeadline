import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/subject_repository.dart';
import '../data/models/subject_model.dart';
import 'auth_provider.dart';

part 'subject_provider.g.dart';

@riverpod
class Subjects extends _$Subjects {
  final SubjectRepository _repository = SubjectRepository();

  @override
  FutureOr<List<SubjectModel>> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null) return [];
    return await _repository.getSubjects(user.id);
  }

  Future<void> addSubject(SubjectModel subject) async {
    try {
      final newSubject = await _repository.createSubject(subject);
      final currentList = state.value ?? [];
      state = AsyncValue.data([...currentList, newSubject]);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateSubject(SubjectModel subject) async {
    try {
      final updatedSubject = await _repository.updateSubject(subject);
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.map((e) => e.id == subject.id ? updatedSubject : e).toList());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      await _repository.deleteSubject(id);
      final currentList = state.value ?? [];
      state = AsyncValue.data(currentList.where((e) => e.id != id).toList());
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
