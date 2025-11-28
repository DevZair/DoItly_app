import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../logic/auth_bloc/auth_bloc.dart';
import '../../logic/auth_bloc/auth_event.dart';
import '../../logic/auth_bloc/auth_state.dart';
import '../../logic/task_bloc/task_bloc.dart';
import '../../logic/task_bloc/task_event.dart';
import '../widgets/floating_shapes_background.dart';
import 'home_screen.dart';

class ReScreen extends StatefulWidget {
  const ReScreen({super.key});

  static const routeName = '/register';

  @override
  State<ReScreen> createState() => _ReScreenState();
}

class _ReScreenState extends State<ReScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const FloatingShapesBackground(),
          SafeArea(
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthAuthenticated) {
                  context.read<TaskBloc>().add(const LoadTasksEvent());
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(HomeScreen.routeName);
                } else if (state is AuthError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                final isLoading = state is AuthLoading;
                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      physics: const BouncingScrollPhysics(),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 48),
                            Text('DoItly', style: AppTextStyles.screenTitle),
                            const SizedBox(height: 24),
                            _buildTextField(
                              label: 'Имя',
                              controller: _nameController,
                              hintText: 'Как вас зовут?',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Введите имя';
                                }
                                if (value.trim().length < 2) {
                                  return 'Минимум 2 символа';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Фамилия',
                              controller: _surnameController,
                              hintText: 'Введите фамилию',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Введите фамилию';
                                }
                                if (value.trim().length < 2) {
                                  return 'Минимум 2 символа';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Никнейм',
                              controller: _nicknameController,
                              hintText: 'Уникальное имя пользователя',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Введите никнейм';
                                }
                                if (value.trim().length < 3) {
                                  return 'Минимум 3 символа';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'E-mail',
                              controller: _emailController,
                              hintText: 'Введите e-mail',
                              keyboardType: TextInputType.emailAddress,

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Введите e-mail';
                                }
                                final emailRegex = RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Некорректный e-mail';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Пароль',
                              controller: _passwordController,
                              hintText: "Введите пароль",
                              obscureText: !_obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  !_obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Введите пароль';
                                }
                                if (value.length < 8) {
                                  return 'Минимум 8 символов';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            _buildTextField(
                              label: 'Подтвердите пароль',
                              controller: _confirmPasswordController,
                              hintText: "Повторите пароль",
                              obscureText: !_obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  !_obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Повторите пароль';
                                }
                                if (value.length < 8) {
                                  return 'Минимум 8 символов';
                                }
                                if (value != _passwordController.text) {
                                  return 'Пароли не совпадают';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _register,
                                child: const Text('Зарегистрироваться'),
                              ),
                            ),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(
                                    context,
                                  ).pushReplacementNamed('/login');
                                },
                                child: const Text('Уже есть аккаунт? Войдите'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isLoading)
                      Positioned.fill(
                        child: ColoredBox(
                          color: AppColors.background.withValues(alpha: 0.6),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppColors.surfaceAlt,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        RegisterRequested(
          name: _nameController.text.trim(),
          surname: _surnameController.text.trim(),
          nickname: _nicknameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }
}
