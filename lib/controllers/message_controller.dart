import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import '../services/api/api_client.dart';
import '../services/api/response_parser.dart';

// ---------------------------------------------------------------------------
// Conversations list  —  GET /api/messages
// ---------------------------------------------------------------------------

final conversationsControllerProvider =
    AsyncNotifierProvider<ConversationsController, List<Conversation>>(
        ConversationsController.new);

class ConversationsController extends AsyncNotifier<List<Conversation>> {
  @override
  Future<List<Conversation>> build() => _fetch();

  Future<List<Conversation>> _fetch() async {
    final raw = await ref.read(apiClientProvider).get('/api/messages');
    return extractList(raw)
        .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }
}

// ---------------------------------------------------------------------------
// Message thread  —  GET /api/messages/{id}
// Returns a LIST of messages, auto-marks them as read on fetch.
// ---------------------------------------------------------------------------

final threadControllerProvider = AsyncNotifierProvider.family<ThreadController,
    List<Message>, int>(ThreadController.new);

class ThreadController extends FamilyAsyncNotifier<List<Message>, int> {
  @override
  Future<List<Message>> build(int arg) => _fetch(arg);

  Future<List<Message>> _fetch(int id) async {
    final raw =
        await ref.read(apiClientProvider).get('/api/messages/$id');
    // Response: {"data": [...messages...]}
    return extractList(raw)
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }

  /// Reply to an existing thread, optionally with file attachments.
  Future<void> sendReply(String body, {List<PlatformFile>? attachments}) async {
    final api = ref.read(apiClientProvider);

    if (attachments != null && attachments.isNotEmpty) {
      final files = await Future.wait(
        attachments.map(
          (f) => MultipartFile.fromFile(f.path!, filename: f.name),
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

    // Refresh thread and invalidate the conversations list to update previews.
    state = await AsyncValue.guard(() => _fetch(arg));
    ref.invalidate(conversationsControllerProvider);
  }
}
