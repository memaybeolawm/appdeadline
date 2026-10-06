import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/deadline_model.dart';
import '../../data/services/ocr_service.dart';
import '../../data/services/import_service.dart';
import '../../providers/deadline_provider.dart';
import '../../providers/auth_provider.dart';

class AddEditDeadlineScreen extends ConsumerStatefulWidget {
  final DeadlineModel? deadline;
  final String subjectId;

  const AddEditDeadlineScreen({
    super.key,
    this.deadline,
    required this.subjectId,
  });

  @override
  ConsumerState<AddEditDeadlineScreen> createState() =>
      _AddEditDeadlineScreenState();
}

class _AddEditDeadlineScreenState
    extends ConsumerState<AddEditDeadlineScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  int _priority = 2;
  int _remindBeforeMinutes = 60;
  bool _isLoading = false;

  final _remindOptions = {
    15: '15 phút trước',
    30: '30 phút trước',
    60: '1 giờ trước',
    120: '2 giờ trước',
    1440: '1 ngày trước',
    2880: '2 ngày trước',
  };

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.deadline?.title ?? '');
    _descController =
        TextEditingController(text: widget.deadline?.description ?? '');
    if (widget.deadline != null) {
      _dueDate = widget.deadline!.dueDate;
      _priority = widget.deadline!.priority;
      _remindBeforeMinutes = widget.deadline!.remindBeforeMinutes;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate.isAfter(DateTime.now())
          ? _dueDate
          : DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate),
      );
      if (time != null && mounted) {
        setState(() {
          _dueDate = DateTime(
              date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _scanFromImage() async {
    final ocrService = OcrService();
    try {
      final text = await ocrService.recognizeTextFromCamera();
      if (text != null && text.isNotEmpty && mounted) {
        // Show OCR result and let user pick text
        _showOcrResult(text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi quét ảnh: $e')),
        );
      }
    } finally {
      ocrService.dispose();
    }
  }

  void _showOcrResult(String text) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Văn bản nhận dạng được:',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(text),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _titleController.text = text.split('\n').first;
                    _descController.text = text;
                    Navigator.pop(ctx);
                  },
                  child: const Text('Dùng văn bản này'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).value;
      if (user == null) return;

      if (widget.deadline == null) {
        // Create
        await ref.read(deadlinesProvider.notifier).addDeadline(
              subjectId: widget.subjectId,
              userId: user.id,
              title: _titleController.text.trim(),
              description: _descController.text.trim().isEmpty
                  ? null
                  : _descController.text.trim(),
              dueDate: _dueDate,
              priority: _priority,
              remindBeforeMinutes: _remindBeforeMinutes,
            );
      } else {
        // Update
        await ref.read(deadlinesProvider.notifier).updateDeadline(
              widget.deadline!.copyWith(
                title: _titleController.text.trim(),
                description: _descController.text.trim().isEmpty
                    ? null
                    : _descController.text.trim(),
                dueDate: _dueDate,
                priority: _priority,
                remindBeforeMinutes: _remindBeforeMinutes,
              ),
            );
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi lưu deadline: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.deadline != null;
    final fmt = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa Deadline' : 'Thêm Deadline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: _scanFromImage,
            tooltip: 'Quét từ ảnh (OCR)',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề deadline *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Mô tả chi tiết',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Due date picker
            Card(
              child: ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Ngày giờ hết hạn'),
                subtitle: Text(
                  fmt.format(_dueDate),
                  style: TextStyle(
                    color: _dueDate.isBefore(DateTime.now())
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDateTime,
              ),
            ),
            const SizedBox(height: 16),

            // Priority
            Text('Mức độ ưu tiên',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                    value: 1,
                    label: Text('Thấp'),
                    icon: Icon(Icons.low_priority)),
                ButtonSegment(
                    value: 2,
                    label: Text('Trung bình'),
                    icon: Icon(Icons.drag_handle)),
                ButtonSegment(
                    value: 3,
                    label: Text('Cao'),
                    icon: Icon(Icons.priority_high)),
              ],
              selected: {_priority},
              onSelectionChanged: (s) =>
                  setState(() => _priority = s.first),
            ),
            const SizedBox(height: 16),

            // Remind before
            Text('Nhắc nhở trước',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _remindBeforeMinutes,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.alarm),
              ),
              items: _remindOptions.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _remindBeforeMinutes = v ?? 60),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _save,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isLoading ? 'Đang lưu...' : 'Lưu deadline',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
