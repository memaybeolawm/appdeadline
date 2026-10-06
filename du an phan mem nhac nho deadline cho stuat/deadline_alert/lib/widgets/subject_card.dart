import 'package:flutter/material.dart';
import '../data/models/subject_model.dart';
import '../core/utils/color_utils.dart';

class SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final int deadlineCount;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SubjectCard({
    super.key,
    required this.subject,
    this.deadlineCount = 0,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = ColorUtils.fromHex(subject.color);

    return Card(
      color: color.withOpacity(0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon + deadline count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.book, color: color, size: 22),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$deadlineCount',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: color),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  // Subject name
                  Text(
                    subject.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Subject code
                  Text(
                    subject.code,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  if (subject.lecturer != null &&
                      subject.lecturer!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subject.lecturer!,
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: color.withOpacity(0.7),
                                fontSize: 11,
                              ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Edit/Delete menu
            if (onEdit != null || onDelete != null)
              Positioned(
                top: 0,
                right: 0,
                child: PopupMenuButton<String>(
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Sửa')
                        ])),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: Colors.red))
                        ])),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
