import 'package:firebase_core/firebase_core.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'features/auth/auth_injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/auth_gate.dart';
import 'features/pharmacy/pharmacy_injection.dart';
import 'firebase_options.dart';

// go_router and the app-wide DI file are added once M5's core lands.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  registerAuthDependencies(GetIt.instance);
  registerPharmacyDependencies(GetIt.instance);

  runApp(
    // One AuthBloc for the whole app, so every screen sees the same session.
    BlocProvider(
      create: (_) =>
          GetIt.instance<AuthBloc>()..add(const AuthSubscriptionRequested()),
      child: const HakikishaApp(),
    ),
  );
}

class HakikishaApp extends StatelessWidget {
  const HakikishaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hakikisha',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F3D1E)),
      ),
      // Temporary: M5's go_router takes over with the same auth redirect.
      home: const AuthGate(),
    );
  }
}
