import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/session/session_cubit.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/settings/presentation/bloc/settings_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();

  // App-lifetime cubits: created once here, so the router and the whole
  // widget tree share the same instances.
  final session = sl<SessionCubit>();
  runApp(
    // One AuthBloc for the whole app, so every auth screen sees the same
    // user. It sits above the router so pushed routes can read it too.
    BlocProvider(
      create: (_) => sl<AuthBloc>()..add(const AuthSubscriptionRequested()),
      child: HakikishaApp(
        router: createAppRouter(session),
        sessionCubit: session,
        settingsCubit: sl<SettingsCubit>(),
      ),
    ),
  );
}
