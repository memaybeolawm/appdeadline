import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/deadline_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/models/deadline_model.dart';
import '../../widgets/deadline_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authProvider);
    final deadlinesAsync = ref.watch(deadlinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.notifications_active,
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Deadline Alert',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Cài đặt',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: _buildBody(context, userAsync, deadlinesAsync),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) context.push('/subjects');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Môn học',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/subjects'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm deadline'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AsyncValue userAsync,
      AsyncValue<List<DeadlineModel>> deadlinesAsync) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(deadlinesProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            userAsync.when(
              data: (user) => _buildGreeting(context, user?.fullName),
              loading: () => const SizedBox(height: 60),
              error: (_, __) => const SizedBox(height: 60),
            ),
            const SizedBox(height: 20),

            // Stats summary
            deadlinesAsync.when(
              data: (deadlines) => _buildStatCards(context, deadlines),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Lỗi: $e')),
            ),
            const SizedBox(height: 24),

            // Upcoming deadlines
            Text(
              'Deadline sắp tới',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            deadlinesAsync.when(
              data: (deadlines) {
                final upcoming = deadlines
                    .where((d) =>
                        !d.isCompleted &&
                        d.dueDate.isAfter(DateTime.now()))
                    .toList()
                  ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

                if (upcoming.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: upcoming.length,
                  itemBuilder: (context, index) =>
                      DeadlineCard(deadline: upcoming[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Lỗi tải deadline: $e')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, String? name) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Chào buổi sáng';
    } else if (hour < 18) {
      greeting = 'Chào buổi chiều';
    } else {
      greeting = 'Chào buổi tối';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                Text(
                  name ?? 'Sinh viên',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  DateFormat('EEEE, d MMMM yyyy', 'vi_VN')
                      .format(DateTime.now()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.school, color: Colors.white54, size: 48),
        ],
      ),
    );
  }

  Widget _buildStatCards(
      BuildContext context, List<DeadlineModel> deadlines) {
    final total = deadlines.length;
    final completed = deadlines.where((d) => d.isCompleted).length;
    final overdue = deadlines
        .where((d) => !d.isCompleted && d.dueDate.isBefore(DateTime.now()))
        .length;
    final urgent = deadlines
        .where((d) =>
            !d.isCompleted &&
            d.dueDate.isAfter(DateTime.now()) &&
            d.dueDate.difference(DateTime.now()).inHours <= 24)
        .length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Tổng',
            value: total,
            icon: Icons.assignment,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Xong',
            value: completed,
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Gấp',
            value: urgent,
            icon: Icons.warning_amber,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Quá hạn',
            value: overdue,
            icon: Icons.error,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(Icons.check_circle_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Không có deadline nào sắp tới!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.5),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút + để thêm deadline mới',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.4),
                ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
