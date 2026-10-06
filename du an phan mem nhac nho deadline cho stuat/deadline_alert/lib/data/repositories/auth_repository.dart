import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AuthRepository {
  final SupabaseClient _client = SupabaseService().client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? studentId,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'student_id': studentId,
      },
    );
    
    if (response.user != null) {
      await _client.from('profiles').insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'student_id': studentId,
      });
    }
    
    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  Future<UserModel?> getUserProfile(String userId) async {
    final data = await _client.from('profiles').select().eq('id', userId).single();
    return UserModel.fromJson(data);
  }
}
