import 'package:get_it/get_it.dart';

import 'data/repositories/task_repository.dart';
import 'logic/auth_bloc/auth_bloc.dart';
import 'logic/task_bloc/task_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl
    ..registerLazySingleton<TaskRepository>(() => TaskRepository())
    ..registerFactory<AuthBloc>(() => AuthBloc(sl<TaskRepository>()))
    ..registerFactory<TaskBloc>(() => TaskBloc(sl<TaskRepository>()));
}
