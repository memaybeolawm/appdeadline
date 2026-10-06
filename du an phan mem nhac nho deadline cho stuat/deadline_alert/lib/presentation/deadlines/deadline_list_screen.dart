import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/subject_model.dart';
import '../../data/models/deadline_model.dart';
import '../../providers/deadline_provider.dart';
import '../../widgets/deadline_card.dart';

class DeadlineListScreen extends ConsumerWidget {
  final String subjectId;
  final SubjectModel subject;

  const DeadlineListScreen({
    super.key,
    required this.subjectId,
    required this.subject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deadlinesAsync = ref.watch(deadlinesBySubjectProvider(subjectId));
    final subjectColor = Color(int.parse(subject.color));

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.name),
        backgroundColor: subjectColor.withOpacity(0.1),
        foregroundColor: subjectColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Sửa môn học',
            onPressed: () => context.push('/subjects/edit', extra: subject),
          ),
        ],
      ),
      body: deadlinesAsync.when(
        data: (deadlines) {
          if (deadlines.isEmpty) {
            return _buildEmpty(context, subjectColor);
          }

          final pending = deadlines.where((d) => !d.isCompleted).toList()
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
          final completed = deadlines.where((d) => d.isCompleted).toList();

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(deadlinesBySubjectProvider(subjectId)),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (pending.isNotEmpty) ...[
                  Text('Chưa hoàn thành (${pending.length})',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...pending.map((d) => DeadlineCard(
                        deadline: d,
                        onTap: () => context.push(
                          '/subjects/$subjectId/deadlines/edit',
                          extra: d,
                        ),
                        onComplete: () => ref
                            .read(deadlinesProvider.notifier)
                            .toggleComplete(d),
                        onDelete: () => ref
                            .read(deadlinesProvider.notifier)
                            .deleteDeadline(d.id),
                      )),
                ],
                if (completed.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Đã hoàn thành (${completed.length})',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                  const SizedBox(height: 8),
                  ...completed.map((d) => DeadlineCard(
                        deadline: d,
                        onComplete: () => ref
                            .read(deadlinesProvider.notifier)
                            .toggleComplete(d),
                        onDelete: () => ref
                            .read(deadlinesProvider.notifier)
                            .deleteDeadline(d.id),
                      )),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            context.push('/subjects/$subjectId/deadlines/add'),
        backgroundColor: subjectColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Thêm deadline'),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined,
              size: 80, color: color.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('Chưa có deadline nào',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Nhấn nút + để thêm deadline đầu tiên',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  )),
        ],
      ),
    );
  }
}
