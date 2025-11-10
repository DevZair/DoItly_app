import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/task_model.dart';
import '../../data/models/user_model.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.onStatusChanged});

  final TaskModel task;
  final ValueChanged<TaskStatus>? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.surfaceAlt],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(task.description, style: AppTextStyles.caption),
                  ],
                ),
              ),
              _StatusChip(task: task, onStatusChanged: onStatusChanged),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text('Дедлайн · $_deadlineLabel', style: AppTextStyles.caption),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.bolt, size: 18, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '+${task.xpReward} XP',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.cardBorder.withValues(alpha: 0.5)),
          if (task.assignees.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('Исполнители', style: AppTextStyles.caption),
            const SizedBox(height: 8),
            _AssigneeStrip(assignees: task.assignees),
          ],
        ],
      ),
    );
  }

  String get _deadlineLabel =>
      DateFormat('d MMM, HH:mm', 'ru_RU').format(task.deadline);
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.task, this.onStatusChanged});

  final TaskModel task;
  final ValueChanged<TaskStatus>? onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final color = _chipColor(task.status);
    return PopupMenuButton<TaskStatus>(
      onSelected: onStatusChanged,
      itemBuilder: (context) => TaskStatus.values
          .map(
            (status) => PopupMenuItem(value: status, child: Text(status.label)),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle, size: 10, color: color),
            const SizedBox(width: 6),
            Text(
              task.status.label,
              style: AppTextStyles.chip.copyWith(color: color),
            ),
            if (onStatusChanged != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, color: color),
            ],
          ],
        ),
      ),
    );
  }

  Color _chipColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.newTask:
        return AppColors.primary;
      case TaskStatus.inProgress:
        return AppColors.warning;
      case TaskStatus.done:
        return AppColors.success;
    }
  }
}

class _AssigneeStrip extends StatelessWidget {
  const _AssigneeStrip({required this.assignees});

  final List<UserModel> assignees;

  @override
  Widget build(BuildContext context) {
    final displayUsers = assignees.take(3).toList();
    final remaining = assignees.length - displayUsers.length;

    return Row(
      children: [
        SizedBox(
          height: 32,
          width: (displayUsers.length * 20) + 12,
          child: Stack(
            children: [
              for (int i = 0; i < displayUsers.length; i++)
                Positioned(
                  left: i * 20,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.surface,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(displayUsers[i].avatarColor),
                      child: Text(
                        displayUsers[i].name.isNotEmpty
                            ? displayUsers[i].name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            assignees.map((user) => user.name.split(' ').first).join(', '),
            style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (remaining > 0) Text('+$remaining', style: AppTextStyles.caption),
      ],
    );
  }
}
