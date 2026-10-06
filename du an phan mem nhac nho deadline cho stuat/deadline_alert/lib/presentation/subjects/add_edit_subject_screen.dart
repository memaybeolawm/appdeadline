import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/subject_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subject_provider.dart';

class AddEditSubjectScreen extends ConsumerStatefulWidget {
  final SubjectModel? subject;

  const AddEditSubjectScreen({super.key, this.subject});

  @override
  ConsumerState<AddEditSubjectScreen> createState() =>
      _AddEditSubjectScreenState();
}

class _AddEditSubjectScreenState
    extends ConsumerState<AddEditSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _lecturerController;
  Color _selectedColor = const Color(0xFF1976D2);
  bool _isLoading = false;

  final List<Color> _presetColors = [
    const Color(0xFF1976D2), // Blue
    const Color(0xFF388E3C), // Green
    const Color(0xFFD32F2F), // Red
    const Color(0xFFF57C00), // Orange
    const Color(0xFF7B1FA2), // Purple
    const Color(0xFF00796B), // Teal
    const Color(0xFFC62828), // Dark red
    const Color(0xFF1565C0), // Dark blue
    const Color(0xFF2E7D32), // Dark green
    const Color(0xFF6A1B9A), // Deep purple
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.subject?.name ?? '');
    _codeController =
        TextEditingController(text: widget.subject?.code ?? '');
    _lecturerController =
        TextEditingController(text: widget.subject?.lecturer ?? '');

    if (widget.subject != null) {
      try {
        _selectedColor = Color(int.parse(widget.subject!.color));
      } catch (_) {
        _selectedColor = const Color(0xFF1976D2);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _lecturerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authProvider).value;
      if (user == null) return;

      final colorHex = '0x${_selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';

      if (widget.subject == null) {
        // Create new
        final subject = SubjectModel(
          id: const Uuid().v4(),
          userId: user.id,
          name: _nameController.text.trim(),
          code: _codeController.text.trim(),
          lecturer: _lecturerController.text.trim().isEmpty
              ? null
              : _lecturerController.text.trim(),
          color: colorHex,
        );
        await ref.read(subjectsProvider.notifier).addSubject(subject);
      } else {
        // Update
        final updated = widget.subject!.copyWith(
          name: _nameController.text.trim(),
          code: _codeController.text.trim(),
          lecturer: _lecturerController.text.trim().isEmpty
              ? null
              : _lecturerController.text.trim(),
          color: colorHex,
        );
        await ref.read(subjectsProvider.notifier).updateSubject(updated);
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi lưu môn học: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chọn màu sắc'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) =>
                setState(() => _selectedColor = color),
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.subject != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa môn học' : 'Thêm môn học'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Color preview banner
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _nameController.text.isEmpty
                      ? 'Tên môn học'
                      : _nameController.text,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Subject name
            TextFormField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Tên môn học *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Vui lòng nhập tên môn' : null,
            ),
            const SizedBox(height: 16),

            // Subject code
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Mã môn *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Vui lòng nhập mã môn' : null,
            ),
            const SizedBox(height: 16),

            // Lecturer
            TextFormField(
              controller: _lecturerController,
              decoration: const InputDecoration(
                labelText: 'Giảng viên',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),

            // Color picker
            Text('Màu sắc',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._presetColors.map((color) => GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: _selectedColor == color
                              ? Border.all(
                                  color: Colors.black, width: 3)
                              : null,
                          boxShadow: _selectedColor == color
                              ? [
                                  BoxShadow(
                                      color: color.withOpacity(0.5),
                                      blurRadius: 6)
                                ]
                              : null,
                        ),
                      ),
                    )),
                // Custom color button
                GestureDetector(
                  onTap: _showColorPicker,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                      gradient: const LinearGradient(
                        colors: [
                          Colors.red,
                          Colors.yellow,
                          Colors.green,
                          Colors.blue
                        ],
                      ),
                    ),
                    child: const Icon(Icons.colorize,
                        size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedColor,
                  foregroundColor: Colors.white,
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isLoading ? 'Đang lưu...' : 'Lưu môn học',
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
