import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/conversation.dart';
import '../services/api/api_client.dart';

// ---------------------------------------------------------------------------
// Conversations list
// ---------------------------------------------------------------------------

final conversationsControllerProvider =
    AsyncNotifierProvider<ConversationsController, List<Conversation>>(
        ConversationsController.new);

class ConversationsController extends AsyncNotifier<List<Conversation>> {
  @override
  Future<List<Conversation>> build() => _fetch();

  Future<List<Conversation>> _fetch() async {
    final data =
        await ref.read(apiClientProvider).get('/api/messages') as List;
    return data
        .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

// ---------------------------------------------------------------------------
// Thread (single conversation — auto-marks messages as read on GET)
// ---------------------------------------------------------------------------

final threadControllerProvider = AsyncNotifierProvider.family<ThreadController,
    Conversation, int>(ThreadController.new);

class ThreadController extends FamilyAsyncNotifier<Conversation, int> {
  @override
  Future<Conversation> build(int arg) => _fetch(arg);

  Future<Conversation> _fetch(int id) async {
    final data = await ref
        .read(apiClientProvider)
        .get('/api/messages/$id') as Map<String, dynamic>;
    return Conversation.fromJson(data);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }

  /// Send a text reply, optionally with file attachments.
  Future<void> sendReply(String body, {List<PlatformFile>? attachments}) async {
    final api = ref.read(apiClientProvider);

    if (attachments != null && attachments.isNotEmpty) {
      final files = await Future.wait(
        attachments.map(
          (file) => MultipartFile.fromFile(file.path!, filename: file.name),
        ),
      );
      final formData = FormData.fromMap({
        'body': body.trim(),
        'attachments[]': files,
      });
      await api.postMultipart('/api/messages/$arg', formData);
    } else {
      await api.post('/api/messages/$arg', body: {'body': body.trim()});
    }

    // Reload thread to surface the new message.
    state = await AsyncValue.guard(() => _fetch(arg));

    // Keep conversation list current.
    ref.invalidate(conversationsControllerProvider);
  }
}
