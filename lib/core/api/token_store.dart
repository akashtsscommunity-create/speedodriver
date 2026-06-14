import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../app/constant.dart';
import '../auth/account_notifier.dart';
import '../auth/entity/linked_account.dart';
import 'api_client.dart';
import 'endpoints.dart';

class TokenStore {
  final FlutterSecureStorage _s = const FlutterSecureStorage();
  static const _accountsKey = 'linked_accounts';
  static const _activeUserKey = 'active_user_id';
  static const _userDataKey = 'user_data';

  Future<String?> getAccessToken() => _s.read(key: 'access_token');

  Future<String?> getRefreshToken() => _s.read(key: 'refresh_token');


  Future<void> setTokens(String access, String refresh) async {
    await _s.write(key: 'access_token', value: access);
    await _s.write(key: 'refresh_token', value: refresh);
  }
  Future<void> clear() async {
    await _s.delete(key: 'access_token');
    await _s.delete(key: 'refresh_token');
  }

  Future<bool> tryRefresh(Ref ref) async {
    final rtk = await getRefreshToken();
    final tk = await getAccessToken();
    if (rtk == null || rtk.isEmpty) return false;
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: Constant.baseUrl,
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
        ),
      );
      final res = await dio.post(Endpoints.refresh, data: {"accessToken": tk, "refreshToken": rtk});
      final r = res.data;
      if(r is! Map<String,dynamic>){
      //  await clear();
        return false;
      }
      await setTokens((r['accessToken'] ?? '') as String, (r['refreshToken'] ?? rtk) as String,);
      return true;
    } catch (e) {
      //await clear();
      return false;
    }
  }
  Future<String?> getEmailId() => _s.read(key: 'EmailId');

  Future<void> setEmailId(String access) async {
    await _s.write(key: 'EmailId', value: access);
  }
  Future<void> setLinkedAccount(String linkedAccount) async {
    await _s.write(key: 'LinkedAccount', value: linkedAccount);
  }

  Future<String?> getLinkedAccount() => _s.read(key: 'LinkedAccount');

  Future<void> setOTPData(String oTPData) async {
    await _s.write(key: 'OTPData', value: oTPData);
  }

  Future<String?> getOTPData() => _s.read(key: 'OTPData');

  Future<void> saveAccounts(List<LinkedAccount> accounts) async {
    final jsonData = jsonEncode(accounts.map((e) => e.toJson()).toList());
    await _s.write(key: _accountsKey, value: jsonData);
  }

  Future<List<LinkedAccount>> loadAccounts() async {
    final data = await _s.read(key: _accountsKey);
    if (data == null) return [];
    final decoded = jsonDecode(data) as List;
    return decoded.map((e) => LinkedAccount.fromJson(e)).toList();
  }

  Future<void> setActiveUser(String userId) async {
    await _s.write(key: _activeUserKey, value: userId);
  }

  Future<String?> getActiveUser() async {
    return await _s.read(key: _activeUserKey);
  }

  Future<void> clearActiveUser() async {
    await _s.delete(key: _activeUserKey);
  }

  Future<void> clearAll() async {
    await _s.deleteAll();
  }

  Future<void> setUserData(String userDataJson) async {
    await _s.write(key: _userDataKey, value: userDataJson);
  }

  Future<String?> getUserData() async {
    return await _s.read(key: _userDataKey);
  }
}

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());
final activeUserProvider = StateProvider<String?>((ref) => null);
final linkedAccountsProvider = StateNotifierProvider<AccountNotifier, List<LinkedAccount>>((ref) => AccountNotifier(ref),);