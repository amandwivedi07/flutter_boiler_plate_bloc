import 'package:dio/dio.dart';

import '../../../../core/network/api_interceptor.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../models/user_model.dart';

/// Remote data source: all API calls go through here.
/// Uses [DioClient]; never used by UI or Cubits.
abstract class AuthRemoteDataSource {
  Future<Result<UserModel>> getUserProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<Result<UserModel>> getUserProfile() async {
    try {
      final response = await _client.get<Map<String, dynamic>>('/user/profile');
      final data = response.data;
      if (data == null) return const FailureResult(UnknownFailure('Empty response'));
      final model = UserModel.fromJson(data);
      return Success(model);
    } on DioException catch (e) {
      return FailureResult(mapDioExceptionToFailure(e));
    }
  }
}
