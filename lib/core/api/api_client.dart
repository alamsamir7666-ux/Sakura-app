import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/api_constants.dart';
import '../utils/logger.dart';

/// Holds the current Clerk session token for API authentication.
class SessionTokenHolder {
  static String? _token;
  static void setToken(String? token) => _token = token;
  static String? get token => _token;
}

class ApiClient {
  late final Dio _dio;

  ApiClient({Ref? ref}) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.apiUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) =>
      _dio.get<T>(path, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

  Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) =>
      _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

  Future<Response<T>> put<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) =>
      _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

  Future<Response<T>> delete<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) =>
      _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);

  Future<Response<T>> patch<T>(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) =>
      _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = SessionTokenHolder.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.d('🌐 ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.d('✅ ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.e('❌ ${err.response?.statusCode} ${err.requestOptions.uri}: ${err.message}');
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final message = switch (err.response?.statusCode) {
      400 => 'Bad request. Please check your input.',
      401 => 'Session expired. Please sign in again.',
      403 => 'You do not have permission to perform this action.',
      404 => 'The requested resource was not found.',
      409 => 'A conflict occurred. Please try again.',
      422 => 'Validation error. Please check your input.',
      429 => 'Too many requests. Please wait and try again.',
      500 => 'Server error. Please try again later.',
      _ => err.message ?? 'An unexpected error occurred.',
    };
    handler.next(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      error: message,
      type: err.type,
      message: message,
    ));
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref: ref));
