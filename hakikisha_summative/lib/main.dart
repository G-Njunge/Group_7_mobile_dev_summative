import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/session/session_cubit.dart';
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
    HakikishaApp(
      router: createAppRouter(session),
      sessionCubit: session,
      settingsCubit: sl<SettingsCubit>(),
    ),
  );
}
