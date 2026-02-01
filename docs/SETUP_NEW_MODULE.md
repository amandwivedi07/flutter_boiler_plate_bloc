# How to Create a New Module

Step-by-step guide for adding a new feature (module) to the boilerplate.

**Example:** Products feature (list products from API).

---

## Step 1: Domain Layer

Create `lib/features/products/domain/`:

### 1.1 Entity — `entities/product_entity.dart`

```dart
import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
  });

  final String id;
  final String name;
  final double price;

  @override
  List<Object?> get props => [id, name, price];
}
```

### 1.2 Repository Contract — `repositories/product_repository.dart`

```dart
import '../../../../core/errors/result.dart';
import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<Result<List<ProductEntity>>> getProducts();
}
```

### 1.3 Use Case — `usecases/get_products_usecase.dart`

```dart
import '../../../../core/errors/result.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  GetProductsUseCase(this._repository);
  final ProductRepository _repository;

  Future<Result<List<ProductEntity>>> call() => _repository.getProducts();
}
```

---

## Step 2: Data Layer

Create `lib/features/products/data/`:

### 2.1 Model — `models/product_model.dart`

```dart
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
  });

  factory ProductModel.fromJson(JsonMap json) => ProductModel(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
  );

  ProductEntity toEntity() => ProductEntity(id: id, name: name, price: price);
}
```

### 2.2 Remote Data Source — `datasources/product_remote_datasource.dart`

```dart
import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/network/api_interceptor.dart';
import '../../../../core/network/dio_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<Result<List<ProductModel>>> getProducts();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._client);
  final DioClient _client;

  @override
  Future<Result<List<ProductModel>>> getProducts() async {
    try {
      final response = await _client.get<List<dynamic>>('/products');
      final data = response.data;
      if (data == null) return const FailureResult(UnknownFailure('Empty'));
      final list = data
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Success(list);
    } on DioException catch (e) {
      return FailureResult(mapDioExceptionToFailure(e));
    }
  }
}
```

### 2.3 Repository Implementation — `repositories/product_repository_impl.dart`

```dart
import '../../../../core/errors/result.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._remoteDataSource);
  final ProductRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<ProductEntity>>> getProducts() async {
    final result = await _remoteDataSource.getProducts();
    return switch (result) {
      Success(:final data) => Success(data.map((m) => m.toEntity()).toList()),
      FailureResult(:final failure) => FailureResult(failure),
    };
  }
}
```

---

## Step 3: Presentation Layer

Create `lib/features/products/presentation/`:

### 3.1 State — `cubit/product_state.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

sealed class ProductState extends Equatable {
  const ProductState();
  @override
  List<Object?> get props => [];
}

final class ProductInitial extends ProductState {}
final class ProductLoading extends ProductState {}
final class ProductLoaded extends ProductState {
  const ProductLoaded(this.products);
  final List<ProductEntity> products;
  @override
  List<Object?> get props => [products];
}
final class ProductError extends ProductState {
  const ProductError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
```

### 3.2 Cubit — `cubit/product_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/result.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  ProductCubit(this._getProductsUseCase) : super(const ProductInitial());
  final GetProductsUseCase _getProductsUseCase;

  Future<void> loadProducts() async {
    emit(const ProductLoading());
    final result = await _getProductsUseCase.call();
    switch (result) {
      case Success(:final data):
        emit(ProductLoaded(data));
      case FailureResult(:final failure):
        emit(ProductError(failure.message));
    }
  }
}
```

### 3.3 Page — `pages/products_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/injection.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProductCubit>()..loadProducts(),
      child: const _ProductsView(),
    );
  }
}

class _ProductsView extends StatelessWidget {
  const _ProductsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductError) {
            return Center(child: Text(state.message));
          }
          if (state is ProductLoaded) {
            return ListView.builder(
              itemCount: state.products.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(state.products[i].name),
                subtitle: Text('\$${state.products[i].price}'),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```

---

## Step 4: Dependency Injection

In `lib/di/injection.dart` add:

```dart
// Imports
import '../features/products/data/datasources/product_remote_datasource.dart';
import '../features/products/data/repositories/product_repository_impl.dart';
import '../features/products/domain/repositories/product_repository.dart';
import '../features/products/domain/usecases/get_products_usecase.dart';
import '../features/products/presentation/cubit/product_cubit.dart';

// In setupInjection():
getIt.registerLazySingleton<ProductRemoteDataSource>(
  () => ProductRemoteDataSourceImpl(getIt<DioClient>()),
);
getIt.registerLazySingleton<ProductRepository>(
  () => ProductRepositoryImpl(getIt<ProductRemoteDataSource>()),
);
getIt.registerLazySingleton<GetProductsUseCase>(
  () => GetProductsUseCase(getIt<ProductRepository>()),
);
getIt.registerFactory<ProductCubit>(
  () => ProductCubit(getIt<GetProductsUseCase>()),
);
```

---

## Step 5: Add Route

In `lib/core/router/app_router.dart`:

```dart
import '../../features/products/presentation/pages/products_page.dart';

// In routes list:
GoRoute(
  path: '/products',
  builder: (context, state) => const ProductsPage(),
),
```

---

## Quick Reference

| Layer | Files |
|-------|-------|
| **Domain** | Entity, Repository (abstract), UseCase |
| **Data** | Model, DataSource, RepositoryImpl |
| **Presentation** | State, Cubit, Page |
| **Wire-up** | injection.dart, app_router.dart |
