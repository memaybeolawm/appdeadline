import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/models/deadline_model.dart';

class DeadlineCard extends StatelessWidget {
  final DeadlineModel deadline;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;

  const DeadlineCard({
    super.key,
    required this.deadline,
    this.onTap,
    this.onComplete,
    this.onDelete,
  });

  Color get _priorityColor {
    if (deadline.isCompleted) return Colors.grey;
    switch (deadline.priority) {
      case 3:
        return Colors.red;
      case 2:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String get _priorityLabel {
    switch (deadline.priority) {
      case 3:
        return 'Cao';
      case 2:
        return 'TB';
      default:
        return 'Thấp';
    }
  }

  String get _timeRemaining {
    if (deadline.isCompleted) return 'Đã hoàn thành';
    final now = DateTime.now();
    final diff = deadline.dueDate.difference(now);
    if (diff.isNegative) return 'Quá hạn ${_formatDuration(diff.abs())}';
    return 'Còn ${_formatDuration(diff)}';
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) return '${d.inDays} ngày';
    if (d.inHours > 0) return '${d.inHours} giờ';
    return '${d.inMinutes} phút';
  }

  Color get _timeColor {
    if (deadline.isCompleted) return Colors.grey;
    final diff = deadline.dueDate.difference(DateTime.now());
    if (diff.isNegative) return Colors.red;
    if (diff.inHours <= 24) return Colors.orange;
    if (diff.inDays <= 3) return Colors.amber.shade700;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('HH:mm, dd/MM/yyyy');
    final priorityColor = _priorityColor;

    return Dismissible(
      key: Key(deadline.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xóa deadline?'),
            content: Text('Bạn có chắc muốn xóa "${deadline.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child:
                    const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      child: Card(
        elevation: deadline.isCompleted ? 0 : 2,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: priorityColor.withOpacity(deadline.isCompleted ? 0.3 : 1),
              width: 2),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Priority indicator
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              deadline.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    decoration: deadline.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: deadline.isCompleted
                                        ? Colors.grey
                                        : null,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color:
                                  priorityColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _priorityLabel,
                              style: TextStyle(
                                  fontSize: 11, color: priorityColor),
                            ),
                          ),
                        ],
                      ),
                      if (deadline.description != null &&
                          deadline.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          deadline.description!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.event, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            fmt.format(deadline.dueDate),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                          const Spacer(),
                          Text(
                            _timeRemaining,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _timeColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Complete checkbox
                Checkbox(
                  value: deadline.isCompleted,
                  onChanged: (_) => onComplete?.call(),
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
