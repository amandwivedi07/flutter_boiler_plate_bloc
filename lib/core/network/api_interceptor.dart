import 'package:dio/dio.dart';

import '../errors/failures.dart';
import '../logging/app_logger.dart';

/// Single interceptor that handles:
/// - Auth token attachment
/// - Request/response logging
/// - Error mapping to [Failure]-friendly format
/// Keeps DioClient lean and interceptors testable.
class ApiInterceptor extends Interceptor {
  ApiInterceptor({
    this.getAuthToken,
    this.onAuthFailure,
    this.logEnabled = true,
  });

  /// Provide current auth token; inject via DI (e.g. from FirebaseService).
  final Future<String?> Function()? getAuthToken;

  /// Called when response is 401; e.g. clear session and navigate to login.
  final void Function()? onAuthFailure;

  final bool logEnabled;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (getAuthToken != null) {
      final token = await getAuthToken!();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    if (logEnabled) {
      AppLogger.debug('[API] ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (logEnabled) {
      AppLogger.debug('[API] ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (logEnabled) {
      AppLogger.warning('[API] ERROR ${err.requestOptions.uri}: ${err.message}');
    }
    if (err.response?.statusCode == 401 && onAuthFailure != null) {
      onAuthFailure!();
    }
    handler.next(err);
  }
}

/// Maps DioException to [Failure] so data layer can return `Result<Failure>`.
Failure mapDioExceptionToFailure(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return NetworkFailure(e.message ?? 'Network error');
    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;
      final message = _getMessageFromResponse(e.response);
      if (statusCode == 401) {
        return AuthFailure(message ?? 'Unauthorized', code: '401');
      }
      if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        return ValidationFailure(message ?? 'Client error');
      }
      return ServerFailure(
        message ?? 'Server error',
        code: statusCode?.toString(),
      );
    case DioExceptionType.cancel:
      return const UnknownFailure('Request cancelled');
    default:
      return UnknownFailure(e.message ?? 'Request failed');
  }
}

String? _getMessageFromResponse(Response? response) {
  final data = response?.data;
  if (data is Map<String, dynamic>) {
    return data['message'] as String? ?? data['error'] as String?;
  }
  return null;
}
