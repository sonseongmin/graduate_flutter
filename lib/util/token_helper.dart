import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenHelper {
  static const _storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'access_token');
  }
}
