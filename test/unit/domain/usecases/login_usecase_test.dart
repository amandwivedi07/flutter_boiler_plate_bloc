import 'package:clean_boilerplate/core/errors/failures.dart';
import 'package:clean_boilerplate/core/errors/result.dart';
import 'package:clean_boilerplate/features/auth/domain/entities/user_entity.dart';
import 'package:clean_boilerplate/features/auth/domain/repositories/auth_repository.dart';
import 'package:clean_boilerplate/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase loginUseCase;
  late MockAuthRepository mockRepository;

  const tUser = UserEntity(
    id: '1',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    test('returns Success with UserEntity when repository succeeds', () async {
      when(() => mockRepository.loginWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Success(tUser));

      final result = await loginUseCase.call(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<Success<UserEntity>>());
      expect((result as Success).data, tUser);

      verify(() => mockRepository.loginWithEmail(
            email: 'test@example.com',
            password: 'password123',
          )).called(1);
    });

    test('returns FailureResult when repository fails', () async {
      when(() => mockRepository.loginWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const FailureResult(AuthFailure('Invalid')));

      final result = await loginUseCase.call(
        email: 'wrong@example.com',
        password: 'wrong',
      );

      expect(result, isA<FailureResult<UserEntity>>());
      expect((result as FailureResult).failure.message, 'Invalid');
    });
  });
}
