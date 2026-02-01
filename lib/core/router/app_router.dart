import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../theme/app_theme.dart';

/// Notifies GoRouter to re-run redirect when auth state changes (e.g. sign out).
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// App router with go_router. Handles deep linking, auth guards, and declarative routes.
class AppRouter {
  AppRouter._();

  static const String loginPath = '/login';
  static const String homePath = '/home';
  static const String initialPath = '/';

  /// Builds GoRouter. Pass [authCubit] for redirect logic.
  static GoRouter create(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: initialPath,
      debugLogDiagnostics: true,
      refreshListenable: _GoRouterRefreshStream(authCubit.stream),
      redirect: (context, state) {
        final authState = authCubit.state;
        final isLoggingIn = state.matchedLocation == loginPath;
        final isInitial = state.matchedLocation == initialPath;

        if (isInitial) return null;

        if (authState is AuthSuccess && isLoggingIn) {
          return homePath;
        }

        if (authState is AuthInitial || authState is AuthError) {
          if (!isLoggingIn) return loginPath;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: initialPath,
          builder: (context, state) => const _SplashScreen(),
        ),
        GoRoute(
          path: loginPath,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: homePath,
          builder: (context, state) => const HomePage(),
        ),
      ],
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().checkCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go(AppRouter.homePath);
        } else if (state is AuthInitial || state is AuthError) {
          context.go(AppRouter.loginPath);
        }
      },
      child: Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}
