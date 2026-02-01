import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/connectivity/connectivity_service.dart';
import '../core/network/dio_client.dart';
import '../core/storage/local_storage.dart';
import '../core/storage/shared_prefs_storage.dart';
import '../core/utils/constants.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_local_datasource_impl.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/auth/domain/usecases/get_user_profile_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/sign_out_usecase.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../firebase/firebase_service.dart';
import '../firebase/notification_service.dart';

/// Centralized dependency injection with get_it.
/// Lazy singletons where appropriate; Cubits can be factory if per-screen.
final GetIt getIt = GetIt.instance;

Future<void> setupInjection() async {
  // Storage (SharedPreferences must be initialized async)
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<LocalStorage>(
    () => SharedPrefsStorage(prefs),
  );

  // Connectivity
  getIt.registerLazySingleton<ConnectivityService>(
    () => ConnectivityServiceImpl(Connectivity()),
  );

  // Firebase
  final auth = FirebaseAuth.instance;
  getIt.registerLazySingleton<FirebaseService>(() => FirebaseService(auth));
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(FirebaseMessaging.instance),
  );

  // Network: DioClient uses FirebaseService for auth token in interceptor
  getIt.registerLazySingleton<DioClient>(() {
    final firebase = getIt<FirebaseService>();
    return DioClient(
      baseUrl: AppConstants.apiBaseUrl,
      getAuthToken: () => firebase.getIdToken(),
      onAuthFailure: () {
        // Auth redirect handled by go_router
      },
      logEnabled: true,
    );
  });

  // Auth feature: data
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt<LocalStorage>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<FirebaseService>(),
      getIt<AuthRemoteDataSource>(),
      getIt<AuthLocalDataSource>(),
    ),
  );

  // Auth feature: domain (use cases)
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<GetUserProfileUseCase>(
    () => GetUserProfileUseCase(getIt<AuthRepository>()),
  );
  getIt.registerLazySingleton<SignOutUseCase>(
    () => SignOutUseCase(getIt<AuthRepository>()),
  );

  // Auth feature: presentation — one Cubit per feature; shared across auth screens
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      getIt<LoginUseCase>(),
      getIt<GetCurrentUserUseCase>(),
      getIt<GetUserProfileUseCase>(),
      getIt<SignOutUseCase>(),
    ),
  );
}
