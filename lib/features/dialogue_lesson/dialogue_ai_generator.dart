/// Tạo hội thoại bằng AI (T15.8): gọi Chat Completions, trả về tên bài + văn bản `Tên: câu nói`.
library;

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/openai/ai_prompts.dart';
import '../../services/openai/openai_chat_client.dart';
import '../ai_settings/models/ai_provider_config.dart';
import 'dialogue_lesson_service.dart';

/// Trình độ CEFR của hội thoại, kèm cấp độ giọng đọc gợi ý tương ứng (T15.7).
enum DialogueCefrLevel {
  a2('A1-A2', DialogueSpeechLevel.clear),
  b1('B1', DialogueSpeechLevel.standard),
  b2('B2', DialogueSpeechLevel.fluent),
  c1('C1+', DialogueSpeechLevel.native);

  const DialogueCefrLevel(this.label, this.suggestedSpeech);

  final String label;
  final DialogueSpeechLevel suggestedSpeech;
}

/// Ngôn ngữ hội thoại: mã → tên gửi cho AI.
const dialogueAiLanguages = {
  'en': 'English',
  'zh': 'Simplified Chinese',
  'ja': 'Japanese',
  'ko': 'Korean',
  'fr': 'French',
  'de': 'German',
  'es': 'Spanish',
  'vi': 'Vietnamese',
};

/// Số câu theo độ dài: ngắn / vừa / dài / rất dài.
const dialogueAiLengths = [8, 16, 30, 50];

/// Kết quả: tên bài + văn bản hội thoại (mỗi dòng `Tên: câu nói`).
class GeneratedDialogue {
  const GeneratedDialogue({required this.title, required this.text});

  final String title;
  final String text;
}

/// AI trả về nội dung không dùng được.
class DialogueGenerateFormatException implements Exception {
  const DialogueGenerateFormatException();
}

class DialogueAiGenerator {
  DialogueAiGenerator({OpenAiChatClient? chat})
    : _chat = chat ?? OpenAiChatClient();

  final OpenAiChatClient _chat;

  Future<GeneratedDialogue> generate(
    AiProviderConfig config, {
    required String? topic,
    required String languageCode,
    required DialogueCefrLevel level,
    required int speakers,
    required int lines,
    CancelToken? cancelToken,
  }) async {
    final buffer = StringBuffer();
    await for (final delta in _chat.streamCompletion(
      config,
      dialogueGeneratePrompt(
        topic: topic,
        language: dialogueAiLanguages[languageCode] ?? 'English',
        level: level.label,
        speakers: speakers,
        lines: lines,
      ),
      jsonMode: true,
      temperature: 0.9,
      cancelToken: cancelToken,
    )) {
      buffer.write(delta);
    }
    return parseGeneratedDialogue(buffer.toString());
  }
}

/// Đọc JSON AI trả về thành [GeneratedDialogue]; bỏ dấu `:` trong tên để parser không hiểu nhầm.
GeneratedDialogue parseGeneratedDialogue(String raw) {
  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException {
    throw const DialogueGenerateFormatException();
  }
  if (decoded is! Map) throw const DialogueGenerateFormatException();
  final out = <String>[];
  final lines = decoded['lines'];
  if (lines is List) {
    for (final l in lines) {
      if (l is! Map) continue;
      final speaker = '${l['speaker'] ?? ''}'
          .replaceAll(RegExp('[:：\n]'), ' ')
          .trim();
      final text = '${l['text'] ?? ''}'.replaceAll('\n', ' ').trim();
      if (speaker.isEmpty || text.isEmpty) continue;
      out.add('$speaker: $text');
    }
  }
  if (out.isEmpty) throw const DialogueGenerateFormatException();
  final title = decoded['title'];
  return GeneratedDialogue(
    title: title is String ? title.trim() : '',
    text: out.join('\n'),
  );
}

final dialogueAiGeneratorProvider = Provider<DialogueAiGenerator>(
  (ref) => DialogueAiGenerator(),
);
