import 'package:dio/dio.dart';
import 'auth_storage.dart';
import '../constants/api_constants.dart';

class HttpClient {
  static Dio _build(String baseUrl) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshToken = await AuthStorage.getRefreshToken();
          if (refreshToken != null) {
            try {
              final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.authBaseUrl));
              final res = await refreshDio.post(
                ApiConstants.refresh,
                data: {'refresh_token': refreshToken},
              );
              final newToken = res.data['access_token'] as String;
              await AuthStorage.saveTokens(
                accessToken: newToken,
                refreshToken: refreshToken,
              );
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final retryRes = await dio.fetch(error.requestOptions);
              return handler.resolve(retryRes);
            } catch (_) {
              await AuthStorage.clear();
            }
          }
        }
        handler.next(error);
      },
    ));

    return dio;
  }

  static Dio get auth => _build(ApiConstants.authBaseUrl);
  static Dio get admin => _build(ApiConstants.adminBaseUrl);
  static Dio get feirante => _build(ApiConstants.feiranteBaseUrl);
}
