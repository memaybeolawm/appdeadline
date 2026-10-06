import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subject_model.dart';
import '../services/supabase_service.dart';

class SubjectRepository {
  final SupabaseClient _client = SupabaseService().client;

  Future<List<SubjectModel>> getSubjects(String userId) async {
    final data = await _client.from('subjects').select().eq('user_id', userId);
    return (data as List).map((e) => SubjectModel.fromJson(e)).toList();
  }

  Future<SubjectModel> createSubject(SubjectModel subject) async {
    final data = await _client.from('subjects').insert(subject.toJson()).select().single();
    return SubjectModel.fromJson(data);
  }

  Future<SubjectModel> updateSubject(SubjectModel subject) async {
    final data = await _client.from('subjects').update(subject.toJson()).eq('id', subject.id).select().single();
    return SubjectModel.fromJson(data);
  }

  Future<void> deleteSubject(String id) async {
    await _client.from('subjects').delete().eq('id', id);
  }
}
