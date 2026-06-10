import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../storage/secure_storage.dart';
import 'api_interceptor.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return ApiClient(
    storage: storage,
    onUnauthorized: () {
      // Handled by AuthController listener — clears storage and triggers router redirect.
      ref.read(secureStorageProvider).clear();
    },
  );
});

class ApiClient {
  late final Dio _dio;

  ApiClient({
    required SecureStorageService storage,
    required void Function() onUnauthorized,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    _dio.interceptors.add(
      AuthInterceptor(storage, onUnauthorized: onUnauthorized),
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? params}) async {
    try {
      final res = await _dio.get(path, queryParameters: params);
      return res.data;
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<dynamic> post(String path, {dynamic body}) async {
    try {
      final res = await _dio.post(path, data: body);
      return res.data;
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<dynamic> postMultipart(String path, FormData formData) async {
    try {
      final res = await _dio.post(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return res.data;
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<dynamic> put(String path, {dynamic body}) async {
    try {
      final res = await _dio.put(path, data: body);
      return res.data;
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<dynamic> patch(String path, {dynamic body}) async {
    try {
      final res = await _dio.patch(path, data: body);
      return res.data;
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  AppException _map(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkException();
    }

    final status = e.response?.statusCode;
    final body = e.response?.data;
    final message = (body is Map ? body['message'] : null) ?? 'An error occurred';

    if (status == 401) return const UnauthorizedException();
    if (status == 404) return NotFoundException(message.toString());
    if (status == 422) {
      final raw = body is Map ? body['errors'] : null;
      final errors = (raw as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, List<String>.from(v as List)),
          ) ??
          {};
      return ValidationException(message.toString(), errors);
    }
    return ServerException(message.toString());
  }
}
