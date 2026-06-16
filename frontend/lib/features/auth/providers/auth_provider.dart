import 'package:flutter/material.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/models/user_model.dart';
import '../../../core/services/auth_storage.dart';
import '../../../core/services/http_client.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _error;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;

  Future<void> checkAuth() async {
    final token = await AuthStorage.getAccessToken();
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      final res = await HttpClient.auth.get(ApiConstants.me);
      _user = UserModel.fromJson(res.data as Map<String, dynamic>);
      _status = AuthStatus.authenticated;
    } catch (_) {
      await AuthStorage.clear();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _error = null;
    try {
      final res = await HttpClient.auth.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      await AuthStorage.saveTokens(
        accessToken: res.data['access_token'] as String,
        refreshToken: res.data['refresh_token'] as String,
      );
      final meRes = await HttpClient.auth.get(ApiConstants.me);
      _user = UserModel.fromJson(meRes.data as Map<String, dynamic>);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Email ou senha inválidos';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await AuthStorage.clear();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
