import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/deadline_repository.dart';
import '../data/models/deadline_model.dart';
import '../data/services/notification_service.dart';
import '../data/services/widget_service.dart';
import 'auth_provider.dart';

part 'deadline_provider.g.dart';

@riverpod
class Deadlines extends _$Deadlines {
  final DeadlineRepository _repository = DeadlineRepository();

  @override
  FutureOr<List<DeadlineModel>> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null) return [];
    return await _repository.getDeadlines(user.id);
  }

  Future<void> addDeadline({
    required String subjectId,
    required String userId,
    required String title,
    String? description,
    required DateTime dueDate,
    int priority = 2,
    int remindBeforeMinutes = 60,
  }) async {
    try {
      final deadline = DeadlineModel(
        id: '',
        subjectId: subjectId,
        userId: userId,
        title: title,
        description: description,
        dueDate: dueDate,
        remindBeforeMinutes: remindBeforeMinutes,
        priority: priority,
      );
      final newDeadline = await _repository.createDeadline(deadline);
      final currentList = state.value ?? [];
      state = AsyncValue.data(
        [...currentList, newDeadline]
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate)),
      );

      // Schedule notification
      await _scheduleNotification(newDeadline);

      // Update widget
      await _updateWidget(state.value ?? []);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateDeadline(DeadlineModel deadline) async {
    try {
      final updated = await _repository.updateDeadline(deadline);
      final currentList = state.value ?? [];
      state = AsyncValue.data(
        currentList.map((e) => e.id == deadline.id ? updated : e).toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate)),
      );

      // Re-schedule notification
      await _scheduleNotification(updated);
      await _updateWidget(state.value ?? []);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> toggleComplete(DeadlineModel deadline) async {
    await updateDeadline(deadline.copyWith(isCompleted: !deadline.isCompleted));
  }

  Future<void> deleteDeadline(String id) async {
    try {
      await _repository.deleteDeadline(id);
      final currentList = state.value ?? [];
      state =
          AsyncValue.data(currentList.where((e) => e.id != id).toList());
      await _updateWidget(state.value ?? []);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> _scheduleNotification(DeadlineModel deadline) async {
    if (deadline.isCompleted) return;
    final scheduleTime = deadline.dueDate
        .subtract(Duration(minutes: deadline.remindBeforeMinutes));
    if (scheduleTime.isAfter(DateTime.now())) {
      final fmt = DateFormat('HH:mm dd/MM/yyyy');
      await NotificationService().scheduleNotification(
        id: deadline.id.hashCode,
        title: '⏰ Sắp đến hạn: ${deadline.title}',
        body: 'Deadline sẽ hết hạn lúc ${fmt.format(deadline.dueDate)}',
        scheduledDate: scheduleTime,
      );
    }
  }

  Future<void> _updateWidget(List<DeadlineModel> deadlines) async {
    final upcoming = deadlines
        .where((d) => !d.isCompleted && d.dueDate.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    if (upcoming.isNotEmpty) {
      final next = upcoming.first;
      final fmt = DateFormat('HH:mm dd/MM');
      await WidgetService()
          .updateWidgetData(next.title, fmt.format(next.dueDate));
    } else {
      await WidgetService().updateWidgetData('Không có deadline', '');
    }
  }
}

/// Provider lọc deadlines theo môn học
@riverpod
Future<List<DeadlineModel>> deadlinesBySubject(
    DeadlinesBySubjectRef ref, String subjectId) async {
  final allDeadlines = await ref.watch(deadlinesProvider.future);
  return allDeadlines.where((d) => d.subjectId == subjectId).toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
}
