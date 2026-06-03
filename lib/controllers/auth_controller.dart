import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../models/user.dart';
import '../services/api/api_client.dart';
import '../services/storage/secure_storage.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class AuthState {
  final User? user;
  final String? token;

  const AuthState({this.user, this.token});
  const AuthState.unauthenticated() : user = null, token = null;

  bool get isAuthenticated => token != null && user != null;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.getToken();
    final user = await storage.getUser();
    if (token != null && user != null) {
      return AuthState(user: user, token: token);
    }
    return const AuthState.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    final api = ref.read(apiClientProvider);
    state = await AsyncValue.guard(() async {
      final data = await api.post('/api/auth/login', body: {
        'email': email.trim(),
        'password': password,
        'device_name': AppConstants.deviceName,
      }) as Map<String, dynamic>;

      final user = User.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;

      final storage = ref.read(secureStorageProvider);
      await storage.saveToken(token);
      await storage.saveUser(user);

      return AuthState(user: user, token: token);
    });
  }

  Future<void> logout() async {
    // Best-effort: call the logout endpoint to revoke the Sanctum token.
    try {
      await ref.read(apiClientProvider).post('/api/auth/logout');
    } catch (_) {}

    await ref.read(secureStorageProvider).clear();
    state = const AsyncValue.data(AuthState.unauthenticated());
  }
}
