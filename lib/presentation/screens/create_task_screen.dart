import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../injection_container.dart';
import '../../logic/task_bloc/task_bloc.dart';
import '../../logic/task_bloc/task_event.dart';
import '../../logic/task_bloc/task_state.dart';
import '../widgets/floating_shapes_background.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  static const routeName = '/create-task';

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController();
  DateTime? _deadline;
  bool _isSubmitting = false;
  bool _isLoadingUsers = true;
  String? _userLoadError;
  List<UserModel> _availableUsers = [];
  final List<UserModel> _selectedUsers = [];
  final TaskRepository _taskRepository = sl<TaskRepository>();

  @override
  void initState() {
    super.initState();
    _loadAssignableUsers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listenWhen: (previous, current) =>
          current is TaskActionSuccess &&
              current.actionType == TaskActionType.create ||
          current is TaskError,
      listener: (context, state) {
        if (state is TaskActionSuccess &&
            state.actionType == TaskActionType.create) {
          setState(() => _isSubmitting = false);
          Navigator.of(context).pop();
        } else if (state is TaskError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Новая задача')),
        body: Stack(
          children: [
            const FloatingShapesBackground(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: _titleController,
                        label: 'Название',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Введите название'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Описание',
                        maxLines: 4,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Добавьте описание'
                            : null
                      ),
                      //Сколько очков
                      _buildTextField(
                        controller: _pointsController,
                        label: 'Сколько очков',
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Укажите количество очков';
                          }
                          final parsed = int.tryParse(value);
                          if (parsed == null) {
                            return 'Введите число';
                          }
                          if (parsed <= 0) {
                            return 'Количество должно быть больше 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text('Назначить', style: AppTextStyles.caption),
                      const SizedBox(height: 8),
                      _buildAssigneePicker(),
                      const SizedBox(height: 20),
                      Text('Дедлайн', style: AppTextStyles.caption),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickDeadline,
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Text(
                            _deadline == null
                                ? 'Выберите дату и время'
                                : DateFormat(
                                    'd MMM, HH:mm',
                                    'ru_RU',
                                  ).format(_deadline!),
                            style: AppTextStyles.caption.copyWith(
                              color: _deadline == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _createTask,
                          child: Text(
                            _isSubmitting ? 'Сохраняем...' : 'Создать задачу',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceAlt,
          ),
        ),
      ],
    );
  }

  Widget _buildAssigneePicker() {
    if (_isLoadingUsers) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: CircularProgressIndicator(),
      );
    }

    if (_userLoadError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _userLoadError!,
            style: AppTextStyles.caption.copyWith(color: Colors.redAccent),
          ),
          TextButton(
            onPressed: _loadAssignableUsers,
            child: const Text('Повторить'),
          ),
        ],
      );
    }

    if (_availableUsers.isEmpty) {
      return Text('Пока нет участников.', style: AppTextStyles.caption);
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _availableUsers
          .map(
            (user) => FilterChip(
              label: Text(user.displayName),
              avatar: CircleAvatar(
                backgroundColor: Color(user.avatarColor),
                child: Text(
                  user.displayName.isNotEmpty
                      ? user.displayName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              selectedColor: AppColors.primary.withValues(alpha: 0.25),
              backgroundColor: AppColors.surfaceAlt,
              checkmarkColor: AppColors.textPrimary,
              selected: _selectedUsers.any((element) => element.id == user.id),
              onSelected: (_) => _toggleUser(user),
            ),
          )
          .toList(),
    );
  }

  void _toggleUser(UserModel user) {
    setState(() {
      final exists = _selectedUsers.any((element) => element.id == user.id);
      if (exists) {
        _selectedUsers.removeWhere((element) => element.id == user.id);
      } else {
        _selectedUsers.add(user);
      }
    });
  }

  Future<void> _loadAssignableUsers() async {
    setState(() {
      _isLoadingUsers = true;
      _userLoadError = null;
    });
    try {
      final users = await _taskRepository.fetchAssignableUsers();
      if (!mounted) return;
      setState(() {
        _availableUsers = users;
        _isLoadingUsers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingUsers = false;
        _userLoadError = 'Не удалось загрузить участников.';
      });
    }
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (!mounted) return;
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (!mounted) return;
    if (time == null) return;

    setState(
      () => _deadline = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  void _createTask() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_deadline == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите дедлайн')));
      return;
    }

    if (_selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите хотя бы одного участника')),
      );
      return;
    }

    if (!_deadline!.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Дедлайн должен быть в будущем')),
      );
      return;
    }

    final xpReward = int.tryParse(_pointsController.text.trim());
    if (xpReward == null || xpReward <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректное количество очков')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    context.read<TaskBloc>().add(
      CreateTaskEvent(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        deadline: _deadline!,
        assigneeIds: _selectedUsers.map((user) => user.id).toList(),
        xpReward: xpReward,
      ),
    );
  }
}
