import 'package:zedu/core/core.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor({required SecureStorageService storage}) : _storage = storage;

  final SecureStorageService _storage;
  VoidCallback? onUnauthorized;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !await _isForOldToken(err)) {
      await _storage.deleteAccessToken();
      onUnauthorized?.call();
    }
    handler.next(err);
  }

  /// A request that left with an old session's token can get its 401 after the
  /// user signed in again. That answer says nothing about the new session, so
  /// it must not delete the new token or sign the user out.
  Future<bool> _isForOldToken(DioException err) async {
    final sent = err.requestOptions.headers['Authorization'];
    if (sent is! String) return false;
    try {
      final current = await _storage.getAccessToken();
      if (current == null || current.isEmpty) return false;
      return sent != 'Bearer $current';
    } catch (_) {
      return false;
    }
  }
}
