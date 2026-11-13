import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'dio_exception.dart';

/// HTTP client terpusat: base URL DummyJSON, timeout 15 detik, dan log debug.
class DioClient {
  final Dio _dio;

  DioClient({Dio? dio}) : _dio = dio ?? Dio() {
    _configureOptions();
    _configureInterceptors();
  }

  void _configureOptions() {
    _dio.options
      ..baseUrl = 'https://dummyjson.com'
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 15)
      ..sendTimeout = const Duration(seconds: 15)
      ..headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  void _configureInterceptors() {
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          responseHeader: false,
          logPrint: (object) => debugPrint('[DIO CLIENT] $object'),
        ),
      );
    }
  }

  Future<Response<dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _request(() => _dio.get(path, queryParameters: queryParameters));
  }

  Future<Response<T>> _request<T>(Future<Response<T>> Function() requestCall) async {
    try {
      return await requestCall();
    } catch (e) {
      throw ErrorHandler.handle(e).failure;
    }
  }
}
