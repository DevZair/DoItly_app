import 'package:flutter/material.dart';

import '../../data/models/task_model.dart';
import '../screens/auth_screen.dart';
import '../screens/create_task_screen.dart';
import '../screens/home_screen.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/task_detail_screen.dart';

class AppRouter {
  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case HomeScreen.routeName:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case ReScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ReScreen());
      case CreateTaskScreen.routeName:
        return MaterialPageRoute(builder: (_) => const CreateTaskScreen());
      case LeaderboardScreen.routeName:
        return MaterialPageRoute(builder: (_) => const LeaderboardScreen());
      case ProfileScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case TaskDetailScreen.routeName:
        final args = settings.arguments;
        if (args is TaskModel) {
          return MaterialPageRoute(
            builder: (_) => TaskDetailScreen(task: args),
          );
        }
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
