import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/deadline_model.dart';
import '../services/supabase_service.dart';

class DeadlineRepository {
  final SupabaseClient _client = SupabaseService().client;

  Future<List<DeadlineModel>> getDeadlines(String userId) async {
    final data = await _client.from('deadlines').select().eq('user_id', userId).order('due_date', ascending: true);
    return (data as List).map((e) => DeadlineModel.fromJson(e)).toList();
  }
  
  Future<List<DeadlineModel>> getDeadlinesBySubject(String subjectId) async {
    final data = await _client.from('deadlines').select().eq('subject_id', subjectId).order('due_date', ascending: true);
    return (data as List).map((e) => DeadlineModel.fromJson(e)).toList();
  }

  Future<DeadlineModel> createDeadline(DeadlineModel deadline) async {
    final data = await _client.from('deadlines').insert(deadline.toJson()).select().single();
    return DeadlineModel.fromJson(data);
  }

  Future<DeadlineModel> updateDeadline(DeadlineModel deadline) async {
    final data = await _client.from('deadlines').update(deadline.toJson()).eq('id', deadline.id).select().single();
    return DeadlineModel.fromJson(data);
  }

  Future<void> deleteDeadline(String id) async {
    await _client.from('deadlines').delete().eq('id', id);
  }
}
