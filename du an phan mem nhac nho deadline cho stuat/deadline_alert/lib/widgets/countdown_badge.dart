import 'package:flutter/material.dart';

class CountdownBadge extends StatelessWidget {
  final DateTime dueDate;
  
  const CountdownBadge({super.key, required this.dueDate});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    String text;
    Color color;
    
    if (difference.isNegative) {
      text = 'Quá hạn';
      color = Colors.red;
    } else if (difference.inDays > 0) {
      text = 'Còn ${difference.inDays} ngày';
      color = difference.inDays <= 2 ? Colors.orange : Colors.green;
    } else if (difference.inHours > 0) {
      text = 'Còn ${difference.inHours} giờ';
      color = Colors.redAccent;
    } else {
      text = 'Còn ${difference.inMinutes} phút';
      color = Colors.red;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
