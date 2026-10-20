import 'package:echo_loop/models/sentence_ai_result.dart';
import 'package:echo_loop/services/ndjson_object_stream.dart';
import 'package:echo_loop/services/openai/openai_ndjson_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

/// 按固定大小切块，模拟模型逐 token 输出。
Stream<String> _chunks(String text, {int size = 5}) async* {
  for (var i = 0; i < text.length; i += size) {
    yield text.substring(i, i + size > text.length ? text.length : i + size);
  }
}

void main() {
  test('完整 JSON → 渐显帧 + 末帧 done，累积结果正确', () async {
    const json =
        '{"translation":"Đây là một câu khá dài dùng để kiểm tra hiển thị dần."}';
    final frames = await accumulateNdjsonObject<SentenceTranslation>(
      openAiJsonToNdjsonEvents(_chunks(json)),
      fromJson: SentenceTranslation.fromJson,
    ).toList();

    expect(frames.length, greaterThan(1), reason: '应有中间渐显帧');
    expect(frames.where((f) => f.isFinal), hasLength(1));
    expect(frames.last.isFinal, isTrue);
    expect(
      frames.last.value.translation,
      'Đây là một câu khá dài dùng để kiểm tra hiển thị dần.',
    );
    // 中间帧是最终译文的前缀（渐显而不是跳变）。
    for (final f in frames.where((f) => !f.isFinal)) {
      expect(frames.last.value.translation, startsWith(f.value.translation));
    }
  });

  test('模型包裹 ```json 代码围栏也能解析', () async {
    final events = await openAiJsonToNdjsonEvents(
      _chunks('```json\n{"translation":"ok"}\n```'),
    ).toList();
    expect(events.last, {'done': true});
  });

  test('流结束仍不是合法 JSON → __error，不发 done', () async {
    final events = await openAiJsonToNdjsonEvents(
      _chunks('{"translation":"cut off'),
    ).toList();
    expect(events.last, {'__error': 'invalid_json'});
    expect(events.any((e) => e['done'] == true), isFalse);

    expect(
      accumulateNdjsonObject<SentenceTranslation>(
        openAiJsonToNdjsonEvents(_chunks('not json at all')),
        fromJson: SentenceTranslation.fromJson,
      ).toList(),
      throwsA(isA<NdjsonStreamException>()),
    );
  });

  test('上游出错直接透传，不发 done', () async {
    Stream<String> failing() async* {
      yield '{"translation":"partial';
      throw StateError('network');
    }

    expect(
      openAiJsonToNdjsonEvents(failing()).toList(),
      throwsA(isA<StateError>()),
    );
  });

  test('transform 改写对最终结果生效', () async {
    final events = await openAiJsonToNdjsonEvents(
      _chunks('{"a":"x"}'),
      transform: (m) => {...m, 'extra': 'y'},
    ).toList();
    final ops = events
        .where((e) => e['ops'] != null)
        .expand((e) => e['ops'] as List)
        .toList();
    expect(
      ops,
      anyElement(
        equals({
          'p': ['extra'],
          'v': 'y',
        }),
      ),
    );
    expect(events.last, {'done': true});
  });
}
