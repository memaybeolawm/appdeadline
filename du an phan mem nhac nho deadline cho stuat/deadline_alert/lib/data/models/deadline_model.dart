import 'package:freezed_annotation/freezed_annotation.dart';

part 'deadline_model.freezed.dart';
part 'deadline_model.g.dart';

@freezed
class DeadlineModel with _$DeadlineModel {
  const factory DeadlineModel({
    required String id,
    required String subjectId,
    required String userId,
    required String title,
    String? description,
    required DateTime dueDate,
    @Default(60) int remindBeforeMinutes,
    @Default(false) bool isCompleted,
    @Default(1) int priority, // 1: Low, 2: Medium, 3: High
  }) = _DeadlineModel;

  factory DeadlineModel.fromJson(Map<String, dynamic> json) => _$DeadlineModelFromJson(json);
}
