# BLoC & Clean Architecture Guide for Beginners

A beginner-friendly guide to **BLoC**, **Cubit**, and **Clean Architecture** in Flutter, with examples from this project.

---

## Table of Contents

1. [What is BLoC?](#1-what-is-bloc)
2. [BLoC vs Cubit](#2-bloc-vs-cubit)
3. [Key Concepts](#3-key-concepts)
4. [Clean Architecture in 3 Layers](#4-clean-architecture-in-3-layers)
5. [How Data Flows](#5-how-data-flows)
6. [Step-by-Step Example: Auth Feature](#6-step-by-step-example-auth-feature)
7. [BLoC Widgets Cheat Sheet](#7-bloc-widgets-cheat-sheet)
8. [Common Patterns](#8-common-patterns)
9. [Tips for Beginners](#9-tips-for-beginners)

---

## 1. What is BLoC?

**BLoC** = **B**usiness **L**ogic **C**omponent

BLoC is a **state management** pattern. It separates your **business logic** from your **UI**.

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│     UI      │  ────►  │    BLoC     │  ────►  │   Data      │
│  (Widgets)  │  events │  (Logic)    │  states │  (API/DB)   │
└─────────────┘         └─────────────┘         └─────────────┘
      ▲                        │
      │                        ▼
      └────────────────────────┘
           UI rebuilds when state changes
```

**Why use BLoC?**
- **Testable** — Logic is separate from UI, easy to unit test
- **Predictable** — One place for all state changes
- **Reusable** — Same logic for mobile, web, desktop

---

## 2. BLoC vs Cubit

| | **Cubit** | **BLoC** |
|---|-----------|----------|
| **Input** | Methods (e.g. `login()`) | Events (e.g. `LoginRequested`) |
| **Boilerplate** | Less | More |
| **Traceability** | Good | Better (every action is an event) |
| **Best for** | Simple flows, most apps | Complex flows, event-heavy apps |

**This project uses Cubit** — it's simpler and sufficient for most use cases.

### Cubit Example

```dart
// Cubit: UI calls methods directly
context.read<AuthCubit>().login(email: email, password: password);

// Inside Cubit:
Future<void> login({required String email, required String password}) async {
  emit(AuthLoading());           // 1. Emit loading
  final result = await _loginUseCase.call(...);  // 2. Call use case
  switch (result) {
    case Success(:final data):
      emit(AuthSuccess(data));   // 3. Emit success
    case FailureResult(:final failure):
      emit(AuthError(failure.message));  // 4. Emit error
  }
}
```

### BLoC Example (for comparison)

```dart
// BLoC: UI dispatches events
context.read<AuthBloc>().add(LoginRequested(email: email, password: password));

// Inside BLoC:
on<LoginRequested>(_onLoginRequested);

Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
  emit(AuthLoading());
  final result = await _loginUseCase.call(email: event.email, password: event.password);
  // ... same as Cubit
}
```

---

## 3. Key Concepts

### State

**State** = What the UI should show at any moment.

```dart
sealed class AuthState extends Equatable {
  const AuthState();
}

final class AuthInitial extends AuthState {}   // Not logged in yet
final class AuthLoading extends AuthState {}   // Loading (show spinner)
final class AuthSuccess extends AuthState {    // Logged in (show user)
  const AuthSuccess(this.user);
  final UserEntity user;
}
final class AuthError extends AuthState {      // Error (show message)
  const AuthError(this.message);
  final String message;
}
```

**Rule:** Every possible UI situation = one state class.

---

### Emit

**Emit** = Tell the UI "I have a new state, rebuild yourself."

```dart
emit(const AuthLoading());      // UI shows loading
emit(AuthSuccess(user));       // UI shows user
emit(AuthError('Invalid credentials'));  // UI shows error
```

---

### BlocProvider

**BlocProvider** = Gives the Cubit/Bloc to the widget tree (dependency injection).

```dart
// At app level (main.dart):
BlocProvider<AuthCubit>.value(
  value: getIt<AuthCubit>(),
  child: MaterialApp.router(...),
)

// Or for a single screen:
BlocProvider(
  create: (_) => getIt<ProductCubit>()..loadProducts(),
  child: const ProductsPage(),
)
```

---

### BlocBuilder

**BlocBuilder** = Rebuilds the widget when state changes.

```dart
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return const CircularProgressIndicator();
    }
    if (state is AuthSuccess) {
      return Text('Hello, ${state.user.email}');
    }
    if (state is AuthError) {
      return Text(state.message, style: TextStyle(color: Colors.red));
    }
    return const SizedBox.shrink();
  },
)
```

---

### BlocListener

**BlocListener** = Runs side effects (navigation, snackbars) when state changes. Does NOT rebuild.

```dart
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) {
      context.go('/home');  // Navigate on success
    }
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  child: YourWidget(),
)
```

---

### BlocConsumer

**BlocConsumer** = BlocBuilder + BlocListener combined.

```dart
BlocConsumer<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) context.go('/home');
  },
  builder: (context, state) {
    final isLoading = state is AuthLoading;
    return ElevatedButton(
      onPressed: isLoading ? null : () => context.read<AuthCubit>().login(...),
      child: Text(isLoading ? 'Loading...' : 'Login'),
    );
  },
)
```

---

### context.read\<Cubit\>()

**read** = Get the Cubit to call methods (trigger actions).

```dart
context.read<AuthCubit>().login(email: email, password: password);
context.read<AuthCubit>().signOut();
```

---

## 4. Clean Architecture in 3 Layers

```
┌──────────────────────────────────────────────────────────────┐
│                    PRESENTATION                               │
│   Pages, Widgets, Cubit, State                                │
│   • UI reacts to state                                        │
│   • Cubit calls UseCases only                                 │
├──────────────────────────────────────────────────────────────┤
│                      DOMAIN                                   │
│   Entities, Repository (abstract), Use Cases                  │
│   • Pure Dart, NO Flutter, NO Dio, NO Firebase                │
│   • Business rules only                                       │
├──────────────────────────────────────────────────────────────┤
│                       DATA                                    │
│   Models, DataSources, Repository Implementation              │
│   • API calls, Firebase, Local DB                             │
│   • Maps DTOs → Entities                                      │
└──────────────────────────────────────────────────────────────┘
```

| Layer | Contains | Depends On |
|-------|----------|------------|
| **Presentation** | Cubit, State, Pages | Domain |
| **Domain** | Entity, Repository (abstract), UseCase | Nothing |
| **Data** | Model, DataSource, RepositoryImpl | Domain |

**Dependency Rule:** Inner layers don't know outer layers. Domain knows nothing about Flutter or Dio.

---

## 5. How Data Flows

Example: **User taps Login button**

```
1. LoginPage
   context.read<AuthCubit>().login(email, password)
        │
        ▼
2. AuthCubit
   emit(AuthLoading())
   result = await _loginUseCase.call(...)
        │
        ▼
3. LoginUseCase
   return _repository.loginWithEmail(...)
        │
        ▼
4. AuthRepository (interface in Domain)
   Implemented by AuthRepositoryImpl (Data)
        │
        ▼
5. AuthRepositoryImpl
   _firebaseService.signInWithEmailAndPassword(...)
        │
        ▼
6. FirebaseService
   Firebase Auth API call
        │
        ▼
7. Result flows back up
   Success(UserEntity) or FailureResult(AuthFailure)
        │
        ▼
8. AuthCubit
   emit(AuthSuccess(data)) or emit(AuthError(failure.message))
        │
        ▼
9. BlocConsumer rebuilds
   UI shows success → navigate, or shows error message
```

---

## 6. Step-by-Step Example: Auth Feature

### 6.1 Domain — Entity

```dart
// lib/features/auth/domain/entities/user_entity.dart
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  @override
  List<Object?> get props => [id, email, displayName, photoUrl];
}
```

**Entity** = Pure business object. No `fromJson`, no Flutter.

---

### 6.2 Domain — Repository Contract

```dart
// lib/features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Result<UserEntity>> loginWithEmail({
    required String email,
    required String password,
  });
  Future<Result<UserEntity?>> getCurrentUser();
  Future<Result<void>> signOut();
}
```

**Repository** = Contract (interface). "What can we do?" Not "how."

---

### 6.3 Domain — Use Case

```dart
// lib/features/auth/domain/usecases/login_usecase.dart
class LoginUseCase {
  LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<Result<UserEntity>> call({
    required String email,
    required String password,
  }) {
    return _repository.loginWithEmail(email: email, password: password);
  }
}
```

**Use Case** = One business action. Cubit calls this, not the repository directly.

---

### 6.4 Data — Model

```dart
// lib/features/auth/data/models/user_model.dart
class UserModel extends UserEntity {
  const UserModel({...}) : super(...);

  factory UserModel.fromJson(JsonMap json) => UserModel(...);
  JsonMap toJson() => {...};
  UserEntity toEntity() => UserEntity(...);
}
```

**Model** = DTO from API. Has `fromJson`, `toJson`, `toEntity()`.

---

### 6.5 Data — DataSource & Repository Impl

```dart
// DataSource: raw API/DB access
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  Future<Result<UserModel>> getUserProfile() async {
    final response = await _client.get('/user/profile');
    return Success(UserModel.fromJson(response.data));
  }
}

// Repository Impl: orchestrates, maps Model → Entity
class AuthRepositoryImpl implements AuthRepository {
  Future<Result<UserEntity>> getUserProfile() async {
    final result = await _remoteDataSource.getUserProfile();
    return switch (result) {
      Success(:final data) => Success(data.toEntity()),
      FailureResult(:final failure) => FailureResult(failure),
    };
  }
}
```

---

### 6.6 Presentation — State

```dart
// lib/features/auth/presentation/cubit/auth_state.dart
sealed class AuthState extends Equatable {
  const AuthState();
}

final class AuthInitial extends AuthState {}
final class AuthLoading extends AuthState {}
final class AuthSuccess extends AuthState {
  const AuthSuccess(this.user);
  final UserEntity user;
}
final class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}
```

---

### 6.7 Presentation — Cubit

```dart
// lib/features/auth/presentation/cubit/auth_cubit.dart
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._loginUseCase, ...) : super(const AuthInitial());
  final LoginUseCase _loginUseCase;

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    final result = await _loginUseCase.call(email: email, password: password);
    switch (result) {
      case Success(:final data):
        emit(AuthSuccess(data));
      case FailureResult(:final failure):
        emit(AuthError(failure.message));
    }
  }
}
```

---

### 6.8 Presentation — Page (UI)

```dart
// lib/features/auth/presentation/pages/login_page.dart
BlocConsumer<AuthCubit, AuthState>(
  listener: (context, state) {
    if (state is AuthSuccess) context.go('/home');
  },
  builder: (context, state) {
    final isLoading = state is AuthLoading;
    return Column(
      children: [
        TextField(controller: _emailController, ...),
        TextField(controller: _passwordController, ...),
        if (state is AuthError) Text(state.message),
        ElevatedButton(
          onPressed: isLoading ? null : () => context.read<AuthCubit>().login(
            email: _emailController.text,
            password: _passwordController.text,
          ),
          child: Text(isLoading ? 'Loading...' : 'Login'),
        ),
      ],
    );
  },
)
```

---

## 7. BLoC Widgets Cheat Sheet

| Widget | Use When |
|--------|----------|
| `BlocProvider` | Provide a Cubit to the tree |
| `BlocBuilder` | Rebuild UI when state changes |
| `BlocListener` | Navigate, show SnackBar, etc. (no rebuild) |
| `BlocConsumer` | Both listener + builder |
| `context.read<Cubit>()` | Call Cubit methods |
| `context.watch<Cubit>()` | Rebuild when state changes (rare, prefer BlocBuilder) |

---

## 8. Common Patterns

### Pattern 1: Loading → Success/Error

```dart
Future<void> loadData() async {
  emit(Loading());
  final result = await _useCase.call();
  switch (result) {
    case Success(:final data):
      emit(Loaded(data));
    case FailureResult(:final failure):
      emit(Error(failure.message));
  }
}
```

### Pattern 2: Optimistic UI (emit before API)

```dart
Future<void> like(id) async {
  emit(Liked(id));  // Show liked immediately
  final result = await _useCase.like(id);
  if (result is FailureResult) {
    emit(Unliked(id));  // Revert on failure
  }
}
```

### Pattern 3: Listener for Navigation

```dart
BlocListener<AuthCubit, AuthState>(
  listenWhen: (prev, curr) => curr is AuthSuccess,  // Only when success
  listener: (context, state) => context.go('/home'),
  child: ...,
)
```

---

## 9. Tips for Beginners

1. **One Cubit per feature** (e.g. `AuthCubit`, `ProductCubit`), not per screen.
2. **State should cover all UI cases** — Loading, Success, Error, Initial.
3. **Cubit never touches UI** — No `BuildContext`, no `Navigator`.
4. **Use `sealed class` for State** — Exhaustive switch, no missing cases.
5. **Use `Result<T>`** — Avoid try-catch in UseCases; map to Success/Failure.
6. **Test UseCases and Cubits** — Mock repository, assert emissions.

---

## Quick Reference: File Locations

| What | Where |
|------|-------|
| Entity | `features/<feature>/domain/entities/` |
| Repository (abstract) | `features/<feature>/domain/repositories/` |
| Use Case | `features/<feature>/domain/usecases/` |
| Model | `features/<feature>/data/models/` |
| DataSource | `features/<feature>/data/datasources/` |
| Repository Impl | `features/<feature>/data/repositories/` |
| State | `features/<feature>/presentation/cubit/` |
| Cubit | `features/<feature>/presentation/cubit/` |
| Pages | `features/<feature>/presentation/pages/` |
| DI registration | `di/injection.dart` |

---

For creating a new module, see the main [README.md](../README.md#how-to-create-a-new-module).
