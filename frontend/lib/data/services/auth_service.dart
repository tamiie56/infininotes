import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: '629844082500-4hf45oq7gdi3put6e4572rquaa62l7s2.apps.googleusercontent.com',
  );

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    return await _api.post('${ApiConstants.auth}/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _api.post('${ApiConstants.auth}/login', {
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> googleSignIn() async {
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception('Google sign in cancelled');
    final auth = await account.authentication;
    final idToken = auth.idToken ?? auth.accessToken;
    if (idToken == null) throw Exception('Failed to get ID token');
    return await _api.post('${ApiConstants.auth}/google', {'idToken': idToken});
  }

  Future<Map<String, dynamic>> getMe() async {
    return await _api.get('${ApiConstants.auth}/me');
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: AppConstants.tokenKey, value: accessToken);
    await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  Future<void> saveUser(UserModel user) async {
    await _storage.write(key: AppConstants.userKey, value: user.toJson().toString());
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  Future<void> logout() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      await _storage.delete(key: AppConstants.tokenKey);
      await _storage.delete(key: AppConstants.refreshTokenKey);
      await _storage.delete(key: AppConstants.userKey);
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: AppConstants.tokenKey);
    return token != null;
  }
}