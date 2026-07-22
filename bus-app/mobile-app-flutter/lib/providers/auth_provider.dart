import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  bool _isCheckingSession = true;
  String? _errorMessage;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isCheckingSession => _isCheckingSession;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _token != null;

  // Called once when the app starts. Checks local storage for a
  // previously saved token, and if found, restores the session
  // automatically so the person skips straight past the login screen.
 Future<void> loadSavedSession() async {
    // Runs the actual session check and a minimum splash display time
    // in parallel, then waits for whichever takes longer. This
    // guarantees the splash screen's animation gets a real chance to
    // play, even when the session check itself finishes almost
    // instantly (as it usually does with local storage).
    final sessionCheck = _readSavedSession();
    final minimumDisplayTime = Future.delayed(const Duration(milliseconds: 5700));

    await Future.wait([sessionCheck, minimumDisplayTime]);

    _isCheckingSession = false;
    notifyListeners();
  }

  Future<void> _readSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');
    final savedUserId = prefs.getString('user_id');
    final savedUserName = prefs.getString('user_full_name');
    final savedUserEmail = prefs.getString('user_email');
    final savedUserRole = prefs.getString('user_role');

    if (savedToken != null && savedUserId != null) {
      _token = savedToken;
      _user = UserModel(
        id: savedUserId,
        fullName: savedUserName ?? '',
        email: savedUserEmail ?? '',
        role: savedUserRole ?? 'rider',
      );
    }
  }

  Future<void> _saveSession(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_full_name', user.fullName);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_role', user.role);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_full_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
  }

  Future<bool> signup({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.signup(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
    );

    _isLoading = false;

    if (result['success']) {
      _token = result['data']['token'];
      _user = UserModel.fromJson(result['data']['user']);
      await _saveSession(_token!, _user!);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.login(email: email, password: password);

    _isLoading = false;

    if (result['success']) {
      _token = result['data']['token'];
      _user = UserModel.fromJson(result['data']['user']);
      await _saveSession(_token!, _user!);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    await _clearSession();
    notifyListeners();
  }
}