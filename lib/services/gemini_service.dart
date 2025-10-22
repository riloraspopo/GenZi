import 'package:google_generative_ai/google_generative_ai.dart';
import '../constant.dart';

class GeminiService {
  static final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash',
    apiKey: GeminiConstants.API_KEY,
  );

  static ChatSession? _chat;

  static Future<void> _initializeChat() async {
    _chat ??= _model.startChat(
      history: [
        Content.text(
          'Kamu adalah asisten gizi dan kesehatan profesional yang membantu memberikan informasi tentang gizi, kesehatan, dan pola makan sehat. '
          'Berikan jawaban yang akurat, mudah dipahami, dan sesuai dengan ilmu gizi dan kesehatan terkini. '
          'Gunakan bahasa yang ramah dan mudah dimengerti. '
          'Jika ada pertanyaan di luar bidang gizi dan kesehatan, mohon ingatkan pengguna untuk fokus pada topik gizi dan kesehatan.',
        ),
      ],
    );
  }

  static Future<String> sendMessage(String message) async {
    try {
      await _initializeChat();
      final response = await _chat!.sendMessage(Content.text(message));
      return response.text ??
          'Maaf, saya tidak dapat memproses permintaan Anda saat ini.';
    } catch (e) {
      return 'Error: $e';
    }
  }
}
