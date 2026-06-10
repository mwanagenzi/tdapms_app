import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tenant_profile.dart';
import '../models/user.dart';
import '../services/api/api_client.dart';
import '../services/storage/secure_storage.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, TenantProfile>(
        ProfileController.new);

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class ProfileController extends AsyncNotifier<TenantProfile> {
  @override
  Future<TenantProfile> build() => _fetch();

  Future<TenantProfile> _fetch() async {
    final raw = await ref.read(apiClientProvider).get('/api/profile');
    return TenantProfile.fromJson(raw as Map<String, dynamic>);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Update personal info and / or emergency contact fields.
  /// Returns the updated [TenantProfile] on success, throws on failure.
  Future<TenantProfile> updateProfile({
    required String name,
    required String phone,
    required String idNumber,
    required String emergencyContactName,
    required String emergencyContactPhone,
  }) async {
    final body = <String, dynamic>{};
    if (name.isNotEmpty) body['name'] = name;
    if (phone.isNotEmpty) body['phone'] = phone;
    if (idNumber.isNotEmpty) body['id_number'] = idNumber;
    if (emergencyContactName.isNotEmpty) {
      body['emergency_contact_name'] = emergencyContactName;
    }
    if (emergencyContactPhone.isNotEmpty) {
      body['emergency_contact_phone'] = emergencyContactPhone;
    }

    final raw = await ref.read(apiClientProvider).put('/api/profile', body: body);
    final updated = TenantProfile.fromJson(raw as Map<String, dynamic>);

    // Keep local state in sync.
    state = AsyncValue.data(updated);

    // Also update the cached User so the app-bar initials refresh immediately.
    _syncAuthUser(updated);

    return updated;
  }

  /// Change password only. Uses the same PUT endpoint with password fields.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await ref.read(apiClientProvider).put('/api/profile', body: {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirmation,
    });
    // No state update needed — token stays valid after password change.
  }

  /// Persist the updated name / phone into secure storage so the auth
  /// snapshot stays consistent without forcing a full re-login.
  void _syncAuthUser(TenantProfile profile) {
    final storage = ref.read(secureStorageProvider);
    final updatedUser = User(
      id: profile.id,
      name: profile.name,
      email: profile.email,
      phone: profile.phone,
    );
    storage.saveUser(updatedUser);
  }
}
