import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkAuth() async {
    _isLoggedIn = await _authService.isLoggedIn();
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _authService.register(name, email, password);
      if (response['success'] == true) {
        await _authService.saveTokens(
          response['accessToken'],
          response['refreshToken'],
        );
        _user = UserModel.fromJson(response['user']);
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = response['message'] ?? 'Registration failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _authService.login(email, password);
      if (response['success'] == true) {
        await _authService.saveTokens(
          response['accessToken'],
          response['refreshToken'],
        );
        _user = UserModel.fromJson(response['user']);
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = response['message'] ?? 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> googleSignIn() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _authService.googleSignIn();
      if (response['success'] == true) {
        await _authService.saveTokens(
          response['accessToken'],
          response['refreshToken'],
        );
        _user = UserModel.fromJson(response['user']);
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _error = response['message'] ?? 'Google sign in failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
