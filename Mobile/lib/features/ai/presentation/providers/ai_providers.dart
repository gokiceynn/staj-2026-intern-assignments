import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/ai_api_client.dart';
import '../../domain/entities/chat_message.dart';

final aiApiClientProvider = Provider<AiApiClient>((ref) => AiApiClient());

final aiStatusProvider = FutureProvider<bool>(
  (ref) => ref.watch(aiApiClientProvider).status(),
);

/// Asistanın yanıt beklediği süre boyunca `true`; giriş kutusu ve gönder
/// butonu bunu izleyip devre dışı bırakılır.
final aiSendingProvider = StateProvider<bool>((ref) => false);

final aiChatControllerProvider =
    NotifierProvider<AiChatController, List<ChatMessage>>(
  AiChatController.new,
);

class AiChatController extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() => const [
        ChatMessage(
          role: ChatRole.assistant,
          text: 'Merhaba! Ben VBShop asistanı. Ürünler, sepet, sipariş ve '
              'site kullanımı hakkında sorularını yanıtlayabilirim.',
        ),
      ];

  Future<void> send(String text) async {
    if (text.trim().isEmpty || ref.read(aiSendingProvider)) return;
    state = [...state, ChatMessage(role: ChatRole.user, text: text.trim())];
    ref.read(aiSendingProvider.notifier).state = true;
    try {
      final reply = await ref.read(aiApiClientProvider).chat(text.trim());
      state = [...state, ChatMessage(role: ChatRole.assistant, text: reply)];
    } catch (e) {
      state = [
        ...state,
        ChatMessage(
          role: ChatRole.assistant,
          text: e.toString().replaceFirst('Exception: ', ''),
          isError: true,
        ),
      ];
    } finally {
      ref.read(aiSendingProvider.notifier).state = false;
    }
  }
}
