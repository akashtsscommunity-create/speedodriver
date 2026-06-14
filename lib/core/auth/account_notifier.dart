import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../api/token_store.dart';
import 'auth_controller.dart';
import 'entity/linked_account.dart';


class AccountNotifier extends StateNotifier<List<LinkedAccount>> {
  final Ref ref;
  AccountNotifier(this.ref) : super([]) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final storage = ref.read(tokenStoreProvider);
    state = await storage.loadAccounts();
    ref.read(activeUserProvider.notifier).state = await storage.getActiveUser();
  }

  /// 🔥 Called ONLY after login API success
  Future<void> initializeFromApi(List<LinkedAccount> accounts, String activeUserId,) async {
    final storage = ref.read(tokenStoreProvider);
    state = accounts;
    await storage.saveAccounts(accounts);
    await storage.setActiveUser(activeUserId);
    ref.read(activeUserProvider.notifier).state = activeUserId;
    _loadFromStorage();
  }

  Future<void> switchAccount(int userId, String email) async {
    final storage = ref.read(tokenStoreProvider);
    final api = ref.read(apiClientProvider);
    await storage.setActiveUser(userId.toString());
    final r = await api.postJson(Endpoints.toggleActiveAccount(userId), {});
    //final dynamic data = r['data'] as dynamic;
    //final Map<dynamic,dynamic> data = r['data'] as Map<dynamic,dynamic>;
    //final dynamic user = data['user'] as dynamic;
    //await storage.setEmailId((r['user']['email']?? '') as String);
    await storage.setEmailId(jsonDecode(r['data'])['user']['email']);
    await storage.setTokens((jsonDecode(r['data'])['token'] ?? '') as String, (jsonDecode(r['data'])['refreshToken'] ?? '') as String);
    // demoes
    final auth = ref.read(authControllerProvider);
    //final db=await SqliteDb.open();
   // db.delete("cached_messages");
    //db.delete("cached_threads");
    await auth.login2222();
    ref.read(activeUserProvider.notifier).state = userId.toString();
  }

  Future<void> signOutCurrent() async {
    final storage = ref.read(tokenStoreProvider);
    await storage.clearActiveUser();
    final auth = ref.read(authControllerProvider);
    await auth.logout();
    ref.read(activeUserProvider.notifier).state = null;

  }

  Future<void> logoutAll() async {
    final storage = ref.read(tokenStoreProvider);
    await storage.clearAll();
    state = [];
    ref.read(activeUserProvider.notifier).state = null;
  }
}