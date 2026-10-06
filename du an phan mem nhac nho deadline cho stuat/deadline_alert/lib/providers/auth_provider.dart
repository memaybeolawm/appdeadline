import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  final AuthRepository _repository = AuthRepository();

  @override
  FutureOr<UserModel?> build() async {
    final user = _repository.getCurrentUser();
    if (user != null) {
      return await _repository.getUserProfile(user.id);
    }
    return null;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.signIn(email: email, password: password);
      if (response.user != null) {
        final profile = await _repository.getUserProfile(response.user!.id);
        state = AsyncValue.data(profile);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? studentId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        studentId: studentId,
      );
      if (response.user != null) {
        final profile = await _repository.getUserProfile(response.user!.id);
        state = AsyncValue.data(profile);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _repository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
