import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/task_model.dart';
import '../../logic/auth_bloc/auth_bloc.dart';
import '../../logic/auth_bloc/auth_event.dart';
import '../../logic/task_bloc/task_bloc.dart';
import '../../logic/task_bloc/task_event.dart';
import '../../logic/task_bloc/task_state.dart';
import '../widgets/floating_shapes_background.dart';
import '../widgets/task_card.dart';
import 'create_task_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(const LoadTasksEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskActionSuccess) {
          final rewardText = state.xpReward != null
              ? ' (+${state.xpReward} XP)'
              : '';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${state.message}$rewardText')),
          );

          if (state.actionType == TaskActionType.update &&
              state.xpReward != null) {
            context.read<AuthBloc>().add(const RefreshCurrentUserRequested());
          }
        } else if (state is TaskError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'DoItly',
            style: AppTextStyles.screenTitle.copyWith(fontSize: 24),
          ),
          actions: [
            _TopIconButton(
              icon: Icons.leaderboard,
              onTap: () =>
                  Navigator.of(context).pushNamed(LeaderboardScreen.routeName),
            ),
            const SizedBox(width: 12),
            _TopIconButton(
              icon: Icons.person_outline,
              onTap: () =>
                  Navigator.of(context).pushNamed(ProfileScreen.routeName),
            ),
            const SizedBox(width: 20),
          ],
        ),
        body: Stack(
          children: [
            const FloatingShapesBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    if (state is TaskLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is TaskActionSuccess) {
                      return _buildTaskList(state.tasks);
                    }

                    if (state is TaskLoaded) {
                      return _buildTaskList(state.tasks);
                    }

                    if (state is TaskError) {
                      return _ErrorView(
                        onRetry: () => context.read<TaskBloc>().add(
                          const LoadTasksEvent(),
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),

          onPressed: () =>
              Navigator.of(context).pushNamed(CreateTaskScreen.routeName),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<TaskModel> tasks) {
    if (tasks.isEmpty) {
      return RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surfaceAlt,
        onRefresh: () => _refreshTasks(context),
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          children: [
            const SizedBox(height: 80),
            Icon(
              Icons.task_alt,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Задач пока нет. Нажмите +, чтобы создать.',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surfaceAlt,
      onRefresh: () => _refreshTasks(context),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.only(bottom: 100, top: 8),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskCard(
            task: task,
            onStatusChanged: task.status == TaskStatus.done
                ? null
                : (status) => _handleStatusChange(task, status),
            onTap: () => Navigator.of(context).pushNamed(
              TaskDetailScreen.routeName,
              arguments: task,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 16),
      ),
    );
  }

  Future<void> _refreshTasks(BuildContext context) async {
    final bloc = context.read<TaskBloc>();
    bloc.add(const RefreshTasksEvent());
    await bloc.stream.firstWhere(
      (state) => state is TaskLoaded || state is TaskError,
    );
  }

  void _handleStatusChange(TaskModel task, TaskStatus status) {
    context.read<TaskBloc>().add(
      UpdateTaskStatusEvent(taskId: task.id, status: status),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 52, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'Не удалось загрузить задачи.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Повторить')),
        ],
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: IconButton(icon: Icon(icon), onPressed: onTap),
    );
  }
}
