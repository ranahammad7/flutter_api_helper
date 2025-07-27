import 'package:flutter_api_helper/flutter_api_helper.dart';
import 'token_storage.dart';

class AuthService {
  static Future<bool> login(String username, String password) async {
    try {
      // Mock login - in real app, use your auth endpoint
      final response = await ApiHelper.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response['token'] != null) {
        await TokenStorage.saveToken(response['token']);
        if (response['refreshToken'] != null) {
          await TokenStorage.saveRefreshToken(response['refreshToken']);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> logout() async {
    try {
      await ApiHelper.post('/auth/logout');
    } catch (e) {
      // Handle logout error
    } finally {
      await TokenStorage.clearTokens();
    }
  }

  static Future<bool> refreshToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await ApiHelper.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      if (response['token'] != null) {
        await TokenStorage.saveToken(response['token']);
        return true;
      }
      return false;
    } catch (e) {
      await TokenStorage.clearTokens();
      return false;
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getToken();
    return token != null;
  }
}
