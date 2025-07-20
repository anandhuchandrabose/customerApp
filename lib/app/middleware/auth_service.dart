import 'package:get_storage/get_storage.dart';

class AuthService {
  static final _box = GetStorage();
  static const _key = 'token';

  static String? get token => _box.read<String>(_key);

  static Future<void> saveToken(String token) async =>
      _box.write(_key, token);

  static Future<void> clear() async => _box.remove(_key);
}