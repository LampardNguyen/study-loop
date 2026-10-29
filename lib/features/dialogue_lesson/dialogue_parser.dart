/// 对话文本解析：`说话人: 台词` 每行一句。
library;

/// 对话中的一句台词。
class DialogueLine {
  const DialogueLine({required this.speaker, required this.text});

  final String speaker;
  final String text;

  @override
  bool operator ==(Object other) =>
      other is DialogueLine && other.speaker == speaker && other.text == text;

  @override
  int get hashCode => Object.hash(speaker, text);

  @override
  String toString() => '$speaker: $text';
}

final _linePattern = RegExp(r'^([^:：]{1,30})[:：]\s*(.+)$');

/// 解析 [input] 为台词列表。
///
/// 不符合 `说话人: 台词` 的非空行视为上一句的续行；首句之前的续行被忽略。
List<DialogueLine> parseDialogue(String input) {
  final lines = <DialogueLine>[];
  for (final raw in input.split(RegExp(r'\r?\n'))) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    final match = _linePattern.firstMatch(line);
    if (match != null) {
      lines.add(
        DialogueLine(
          speaker: match.group(1)!.trim(),
          text: match.group(2)!.trim(),
        ),
      );
    } else if (lines.isNotEmpty) {
      final last = lines.removeLast();
      lines.add(
        DialogueLine(speaker: last.speaker, text: '${last.text} $line'),
      );
    }
  }
  return lines;
}

/// 按首次出现顺序返回说话人列表。
List<String> dialogueSpeakers(List<DialogueLine> lines) =>
    lines.map((l) => l.speaker).toSet().toList();
