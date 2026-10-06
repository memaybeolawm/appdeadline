import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/subjects/subject_list_screen.dart';
import '../../presentation/subjects/add_edit_subject_screen.dart';
import '../../presentation/deadlines/deadline_list_screen.dart';
import '../../presentation/deadlines/add_edit_deadline_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../data/models/subject_model.dart';
import '../../data/models/deadline_model.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final goingToAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (session == null && !goingToAuth) {
        return '/login';
      }

      if (session != null && goingToAuth) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/subjects',
        builder: (context, state) => const SubjectListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddEditSubjectScreen(),
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final subject = state.extra as SubjectModel;
              return AddEditSubjectScreen(subject: subject);
            },
          ),
          GoRoute(
            path: ':subjectId/deadlines',
            builder: (context, state) {
              final subjectId = state.pathParameters['subjectId']!;
              final subject = state.extra as SubjectModel;
              return DeadlineListScreen(subjectId: subjectId, subject: subject);
            },
            routes: [
              GoRoute(
                path: 'add',
                builder: (context, state) {
                  final subjectId = state.pathParameters['subjectId']!;
                  return AddEditDeadlineScreen(subjectId: subjectId);
                },
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final subjectId = state.pathParameters['subjectId']!;
                  final deadline = state.extra as DeadlineModel;
                  return AddEditDeadlineScreen(
                      subjectId: subjectId, deadline: deadline);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
