import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/config/env_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'di/injection.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'firebase/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EnvConfig.init();

  // await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await setupInjection();

  final notificationService = getIt<NotificationService>();
  await notificationService.requestPermission();

  runApp(const MyApp());
}

/// App root: BlocProvider for AuthCubit, MaterialApp.router with go_router.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();
    return BlocProvider<AuthCubit>.value(
      value: authCubit,
      child: MaterialApp.router(
        title: 'Clean Boilerplate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.create(authCubit),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('es')],
      ),
    );
  }
}
