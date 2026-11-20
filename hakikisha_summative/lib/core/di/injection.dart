import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/auth_injection.dart';
import '../../features/pharmacy/pharmacy_injection.dart';
import '../../features/settings/settings_injection.dart';
import '../session/session_cubit.dart';
import '../session/session_source.dart';

/// The app's service locator.
final sl = GetIt.instance;

/// Registers every dependency once, before `runApp`.
///
/// Rules (see README "Architecture"):
/// - Firebase clients and repositories are lazy singletons.
/// - Blocs and cubits are factories, so each screen gets a fresh one and no
///   state leaks between users after logout.
///
/// Feature owners: add your `register<Feature>Dependencies(sl)` call at the
/// end, and take Firebase clients from `sl()` instead of `.instance`, so tests
/// can replace them.
Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance)
    ..registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance)
    ..registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance)
    ..registerLazySingleton<SessionSource>(() => FirebaseSessionSource(sl()))
    ..registerFactory(() => SessionCubit(sl()));

  registerAuthDependencies(sl);
  registerPharmacyDependencies(sl);
  registerSettingsDependencies(sl);
}
