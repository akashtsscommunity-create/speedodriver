import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user_model.dart';

final userProvider = FutureProvider<UserModel?>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  if (user == null) return null;

  try {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data != null) {
      return UserModel(
        id: user.id,
        fullName: data['full_name'] as String? ?? user.userMetadata?['full_name'] as String? ?? '',
        mobileNumber: data['mobile_number']?.toString() ?? user.phone,
        emailAddress: data['email_address']?.toString() ?? user.email,
        role: data['role'] as String? ?? user.userMetadata?['role'] as String? ?? 'driver',
        isVerified: user.phoneConfirmedAt != null || user.emailConfirmedAt != null,
      );
    }
  } catch (_) {
    // Fallback to metadata if DB table does not exist yet or request fails
  }

  return UserModel(
    id: user.id,
    fullName: user.userMetadata?['full_name'] as String? ?? '',
    mobileNumber: user.phone,
    emailAddress: user.email,
    role: user.userMetadata?['role'] as String? ?? 'driver',
    isVerified: user.phoneConfirmedAt != null || user.emailConfirmedAt != null,
  );
});
