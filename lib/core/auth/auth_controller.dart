import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'user_provider.dart';

class AuthController extends ChangeNotifier {
  final Ref _ref;
  final GoTrueClient _auth = Supabase.instance.client.auth;
  final SupabaseClient _client = Supabase.instance.client;

  AuthController(this._ref);

  bool _loggedIn = false;
  bool _otpVerify = false;
  bool _busy = false;

  bool _otpSent = false;
  bool _otpVerified = false;

  String? _loginOtpPhone;
  String? _registerOtpPhone;

  bool get isLoggedIn => _loggedIn || _auth.currentSession != null;
  bool get otpVerify => _otpVerify;
  bool get isBusy => _busy;

  bool get isOtpSent => _otpSent;
  bool get isOtpVerified => _otpVerified;

  String? get loginOtpPhone => _loginOtpPhone;
  String? get registerOtpPhone => _registerOtpPhone;

  Future<void> bootstrap() async {
    final session = _auth.currentSession;
    if (session != null && session.user != null) {
      final isDriver = await _checkIfDriver(session.user!);
      if (!isDriver) {
        await _auth.signOut();
        _loggedIn = false;
      } else {
        _loggedIn = true;
      }
    } else {
      _loggedIn = false;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password, String s) async {
    _busy = true;
    notifyListeners();

    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user != null) {
        final isDriver = await _checkIfDriver(user);
        if (!isDriver) {
          await _auth.signOut();
          throw Exception('Access denied. Only drivers can login to this app.');
        }
      }

      _loggedIn = response.session != null;
      _busy = false;
      _ref.invalidate(userProvider);
      notifyListeners();
    } catch (e) {
      _busy = false;
      notifyListeners();
      throw Exception(_cleanError(e));
    }
  }

  Future<void> login2222() async {
    _loggedIn = true;
    notifyListeners();
  }

  Future<String> sendLoginOtp(String phone) async {
    _busy = true;
    _otpSent = false;
    _otpVerified = false;
    
    // Ensure phone has a leading country code (+91 by default if 10 digits)
    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';
    _loginOtpPhone = formattedPhone;
    notifyListeners();

    try {
      await _auth.signInWithOtp(
        phone: formattedPhone,
      );

      _otpSent = true;
      _otpVerified = false;
      _busy = false;
      notifyListeners();

      return 'OTP sent successfully';
    } catch (e) {
      _busy = false;
      _otpSent = false;
      _otpVerified = false;
      _loginOtpPhone = null;
      notifyListeners();
      throw Exception(_cleanError(e));
    }
  }

  Future<String> verifyLoginOtp({
    required String phone,
    required String otp,
  }) async {
    _busy = true;
    notifyListeners();

    try {
      final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';
      final response = await _auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms,
      );

      final user = response.user;
      if (user != null) {
        final isDriver = await _checkIfDriver(user);
        if (!isDriver) {
          await _auth.signOut();
          throw Exception('Access denied. Only drivers can login to this app.');
        }
      }

      _loggedIn = response.session != null;
      _otpVerify = true;
      _otpVerified = response.session != null;
      _busy = false;
      _ref.invalidate(userProvider);
      notifyListeners();

      if (response.session == null) {
        throw Exception('Verification failed. Session is null.');
      }

      return 'OTP verified successfully';
    } catch (e) {
      _busy = false;
      _otpVerified = false;
      notifyListeners();
      throw Exception(_cleanError(e));
    }
  }

  Future<String> sendRegisterOtp({
    required String fullName,
    required String dob,
    required String phone,
  }) async {
    // Forwarding to standard signup or signInWithOtp to keep signature compatible
    return signup(
      fullName: fullName,
      dob: dob,
      phone: phone,
      email: '',
      password: '',
      termsAccepted: true,
    );
  }

  Future<String> verifyRegisterOtp({
    required String otp,
  }) async {
    _busy = true;
    notifyListeners();

    try {
      if (_registerOtpPhone == null) {
        throw Exception('Registration phone number not found. Please try again.');
      }

      final response = await _auth.verifyOTP(
        phone: _registerOtpPhone!,
        token: otp,
        type: OtpType.sms,
      );

      _otpVerified = response.session != null;
      _loggedIn = response.session != null;
      _busy = false;
      _ref.invalidate(userProvider);
      notifyListeners();

      if (response.session == null) {
        throw Exception('OTP verification failed.');
      }

      return 'OTP verified successfully';
    } catch (e) {
      _busy = false;
      _otpVerified = false;
      notifyListeners();
      throw Exception(_cleanError(e));
    }
  }

  Future<void> sendOTp(String email, String password) async {
    await _auth.signInWithOtp(email: email);
  }

  Future<void> verifyOTp() async {
    _otpVerify = true;
    notifyListeners();
  }

  Future<void> forgotPassword(String email) async {
    _busy = true;
    notifyListeners();
    try {
      await _auth.resetPasswordForEmail(email);
      _busy = false;
      notifyListeners();
    } catch (e) {
      _busy = false;
      notifyListeners();
      throw Exception(_cleanError(e));
    }
  }

  Future<String> signup({
    required String fullName,
    required String dob,
    required String phone,
    required String email,
    required String password,
    required bool termsAccepted,
    String role = 'driver', // default to driver for this app
  }) async {
    _busy = true;
    notifyListeners();

    try {
      if (email.isNotEmpty) {
        // Email signup with password
        final response = await _auth.signUp(
          email: email,
          password: password,
          data: {
            'full_name': fullName,
            'role': role,
            'date_of_birth': dob,
          },
        );

        // Also insert/upsert into profile table
        try {
          if (response.user != null) {
            await _client.from('profiles').upsert({
              'id': response.user!.id,
              'full_name': fullName,
              'role': role,
              'date_of_birth': dob,
              'email_address': email,
              'mobile_number': phone.isNotEmpty ? phone : null,
            });
          }
        } catch (_) {
          // profiles table might not exist or lacks RLS insert
        }

        _busy = false;
        _ref.invalidate(userProvider);
        notifyListeners();
        return 'Registration successful! Verification required.';
      } else {
        // Phone signup (OTP flow)
        final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';
        _registerOtpPhone = formattedPhone;
        
        await _auth.signInWithOtp(
          phone: formattedPhone,
          data: {
            'full_name': fullName,
            'role': role,
            'date_of_birth': dob,
          },
        );

        _otpSent = true;
        _busy = false;
        notifyListeners();
        return 'OTP sent successfully';
      }
    } catch (e) {
      _busy = false;
      notifyListeners();
      throw Exception(_cleanError(e));
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String phone,
    String? dob,
    String? password,
  }) async {
    _busy = true;
    notifyListeners();

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      await _auth.updateUser(
        UserAttributes(
          email: email != user.email && email.isNotEmpty ? email : null,
          phone: phone != user.phone && phone.isNotEmpty ? phone : null,
          password: password,
          data: {
            'full_name': fullName,
            if (dob != null) 'date_of_birth': dob,
          },
        ),
      );

      try {
        await _client.from('profiles').upsert({
          'id': user.id,
          'full_name': fullName,
          'role': user.userMetadata?['role'] ?? 'driver',
          'date_of_birth': dob ?? user.userMetadata?['date_of_birth'],
          'email_address': email,
          'mobile_number': phone,
        });
      } catch (_) {
        // profiles table lookup error
      }

      _ref.invalidate(userProvider);
      _busy = false;
      notifyListeners();
    } catch (e) {
      _busy = false;
      notifyListeners();
      throw Exception(_cleanError(e));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _loggedIn = false;
    _otpVerify = false;
    resetOtpState(notify: false);
    _ref.invalidate(userProvider);
    notifyListeners();
  }

  void resetOtpState({bool notify = true}) {
    if (!_otpSent && !_otpVerified && _loginOtpPhone == null && _registerOtpPhone == null) {
      return;
    }

    _otpSent = false;
    _otpVerified = false;
    _loginOtpPhone = null;
    _registerOtpPhone = null;

    if (notify) {
      notifyListeners();
    }
  }

  String _cleanError(Object error) {
    return error.toString()
        .replaceAll('Exception: ', '')
        .replaceAll('AuthException: ', '')
        .trim();
  }

  Future<bool> _checkIfDriver(User user) async {
    // 1. Check user metadata first (fastest)
    String? role = user.userMetadata?['role'];

    // 2. If not in metadata, or we want to be sure, check the profiles table
    if (role != 'driver') {
      try {
        final data = await _client
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();
        if (data != null) {
          role = data['role'] as String?;
        }
      } catch (e) {
        // Table might not exist or RLS might prevent access before full session is active
        // But for login verification, we usually have a session now.
      }
    }

    return role == 'driver';
  }
}

final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  final controller = AuthController(ref);
  controller.bootstrap();
  return controller;
});