// Basic Flutter widget test for LoginPage.
// Tests that the login form renders correctly.
// For full app tests, use integration tests with setupInjection().

import 'package:bloc_test/bloc_test.dart';
import 'package:clean_boilerplate/core/l10n/app_strings.dart';
import 'package:clean_boilerplate/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:clean_boilerplate/features/auth/presentation/cubit/auth_state.dart';
import 'package:clean_boilerplate/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
void main() {
  testWidgets('LoginPage renders email and password fields', (
    WidgetTester tester,
  ) async {
    final mockCubit = _MockAuthCubit();
    whenListen(
      mockCubit,
      Stream.value(const AuthInitial()),
      initialState: const AuthInitial(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthCubit>.value(
          value: mockCubit,
          child: const LoginPage(),
        ),
      ),
    );

    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text(AppStrings.login), findsOneWidget);
  });
}

class _MockAuthCubit extends Mock implements AuthCubit {}
