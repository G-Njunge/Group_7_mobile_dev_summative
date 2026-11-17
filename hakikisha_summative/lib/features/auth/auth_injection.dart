import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/bloc/forgot_password_cubit.dart';
import 'presentation/bloc/login_cubit.dart';
import 'presentation/bloc/register_cubit.dart';
import 'presentation/bloc/verify_email_cubit.dart';

/// Registers the auth feature's dependencies in get_it.
///
/// M5's app-wide DI setup in `lib/core/di/` calls this once at start-up
/// (until then, `main.dart` does).
void registerAuthDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      ),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
    );
  registerAuthPresentation(sl);
}

/// Blocs and cubits only. They're **factories**: every screen gets a fresh
/// instance that's closed when the screen goes away, so no form state
/// survives a logout. Tests call this after registering a mock
/// [AuthRepository].
void registerAuthPresentation(GetIt sl) {
  sl
    ..registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepository>()))
    ..registerFactory<LoginCubit>(() => LoginCubit(sl<AuthRepository>()))
    ..registerFactory<RegisterCubit>(() => RegisterCubit(sl<AuthRepository>()))
    ..registerFactory<ForgotPasswordCubit>(
      () => ForgotPasswordCubit(sl<AuthRepository>()),
    )
    ..registerFactory<VerifyEmailCubit>(
      () => VerifyEmailCubit(sl<AuthRepository>()),
    );
}
