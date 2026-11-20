import 'package:get_it/get_it.dart';

import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/settings_repository.dart';
import 'presentation/bloc/settings_cubit.dart';

/// Registers the settings feature. Needs `SharedPreferences` registered first.
void registerSettingsDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl()),
    )
    ..registerFactory(() => SettingsCubit(sl()));
}
