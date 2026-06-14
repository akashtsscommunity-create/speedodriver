import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class AppInstallStore {
  final FlutterSecureStorage _s = const FlutterSecureStorage();
  Future<String> getOrCreateAppInstallId() async {
    final ex = await _s.read(key:'app_install_id');
    if(ex!=null && ex.isNotEmpty) return ex;
    final id = const Uuid().v4();
    await _s.write(key:'app_install_id', value: id);
    return id;
  }
}