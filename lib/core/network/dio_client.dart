import 'package:dio/dio.dart';

import 'api_interceptor.dart';

/// Reusable HTTP client with base config and interceptors.
/// Only DataSources use this; UI and Cubits never touch Dio.
class DioClient {
  DioClient({
    required String baseUrl,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Future<String?> Function()? getAuthToken,
    void Function()? onAuthFailure,
    bool logEnabled = true,
  }) : _dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: connectTimeout ?? const Duration(seconds: 30),
           receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
           headers: {
             'Content-Type': 'application/json',
             'Accept': 'application/json',
           },
         ),
       ) {
    _dio.interceptors.add(
      ApiInterceptor(
        getAuthToken: getAuthToken,
        onAuthFailure: onAuthFailure,
        logEnabled: logEnabled,
      ),
    );
  }

  final Dio _dio;

  Dio get dio => _dio;

  /// GET request; throws DioException on failure (DataSource catches and maps to Failure).
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.get<T>(path, queryParameters: queryParameters, options: options);

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.post<T>(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.put<T>(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _dio.delete<T>(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );
}
