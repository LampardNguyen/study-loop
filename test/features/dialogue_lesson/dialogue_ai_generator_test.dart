import 'package:echo_loop/features/dialogue_lesson/dialogue_ai_generator.dart';
import 'package:echo_loop/features/dialogue_lesson/dialogue_lesson_service.dart';
import 'package:echo_loop/features/dialogue_lesson/dialogue_parser.dart';
import 'package:echo_loop/services/openai/ai_prompts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseGeneratedDialogue', () {
    test('chuyển JSON thành văn bản Tên: câu nói, parse lại được', () {
      final d = parseGeneratedDialogue(
        '{"title":"At the café","lines":['
        '{"speaker":"Mark","text":"Hi, a latte please."},'
        '{"speaker":"Anna","text":"Sure.\\nAnything else?"}]}',
      );
      expect(d.title, 'At the café');
      expect(parseDialogue(d.text), const [
        DialogueLine(speaker: 'Mark', text: 'Hi, a latte please.'),
        DialogueLine(speaker: 'Anna', text: 'Sure. Anything else?'),
      ]);
    });

    test('bỏ dấu : trong tên, bỏ dòng rỗng', () {
      final d = parseGeneratedDialogue(
        '{"lines":[{"speaker":"Dr: Lee","text":"Hello"},'
        '{"speaker":"","text":"x"},{"speaker":"Bo","text":" "}]}',
      );
      expect(d.title, '');
      expect(d.text, 'Dr  Lee: Hello');
    });

    test('nội dung hỏng → DialogueGenerateFormatException', () {
      for (final raw in ['not json', '[]', '{"lines":[]}']) {
        expect(
          () => parseGeneratedDialogue(raw),
          throwsA(isA<DialogueGenerateFormatException>()),
        );
      }
    });
  });

  test('prompt: có chủ đề / ngẫu nhiên', () {
    final withTopic = dialogueGeneratePrompt(
      topic: 'Hỏi đường',
      language: 'English',
      level: 'B1',
      speakers: 2,
      lines: 30,
    );
    expect(withTopic.first.content, contains('B1'));
    expect(withTopic.first.content, contains('about 30 lines'));
    expect(withTopic.last.content, contains('Hỏi đường'));
    final random = dialogueGeneratePrompt(
      topic: null,
      language: 'English',
      level: 'C1+',
      speakers: 3,
      lines: 50,
    );
    expect(random.last.content, contains('Choose an everyday topic'));
  });

  test('trình độ gợi ý cấp độ giọng đọc tương ứng', () {
    expect(
      DialogueCefrLevel.values.map((l) => l.suggestedSpeech),
      DialogueSpeechLevel.values,
    );
  });
}
