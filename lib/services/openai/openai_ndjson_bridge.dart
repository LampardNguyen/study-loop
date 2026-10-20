/// 把 OpenAI 的流式 JSON 文本转换成后端同款 NDJSON 事件流。
///
/// 输出事件与原后端 `stream/_shared.ts` 协议一致，可直接交给
/// `accumulateNdjsonObject` 累积：
/// - `{"ops":[{"p":[...],"v":...}]}`：新增 / 变化的叶子（含正在增长的字符串，用于渐显）；
/// - `{"done":true}`：完整 JSON 严格解析成功后才发出（调用方据此落缓存）；
/// - `{"__error":"invalid_json"}`：流结束但不是合法 JSON 对象。
///
/// 取消 / 网络错误直接向上抛，不发 done（调用方不落缓存）。
library;

import 'dart:convert';

import 'json_leaf_ops.dart';
import 'partial_json.dart';

/// 两次快照解析之间至少累积的新字符数，避免每个 token 都重新解析整段 JSON。
const _minCharsBetweenSnapshots = 24;

/// 将 [deltas]（模型输出的文本增量）转换为 NDJSON 事件流。
///
/// [transform] 可在比较前改写快照（如补默认字段），对最终结果同样生效。
Stream<Map<String, dynamic>> openAiJsonToNdjsonEvents(
  Stream<String> deltas, {
  Map<String, dynamic> Function(Map<String, dynamic>)? transform,
}) async* {
  final buffer = StringBuffer();
  Object? lastSnapshot;
  var charsSinceSnapshot = 0;

  Map<String, dynamic> apply(Map<String, dynamic> value) =>
      transform == null ? value : transform(value);

  await for (final delta in deltas) {
    buffer.write(delta);
    charsSinceSnapshot += delta.length;
    if (charsSinceSnapshot < _minCharsBetweenSnapshots) continue;
    charsSinceSnapshot = 0;
    final partial = parsePartialJson(_stripCodeFence(buffer.toString()));
    if (partial is! Map<String, dynamic>) continue;
    final snapshot = apply(partial);
    final ops = diffJsonLeafOps(lastSnapshot, snapshot);
    if (ops.isEmpty) continue;
    lastSnapshot = snapshot;
    yield {'ops': ops};
  }

  final Object? complete;
  try {
    complete = jsonDecode(_stripCodeFence(buffer.toString()));
  } on FormatException {
    yield {'__error': 'invalid_json'};
    return;
  }
  if (complete is! Map<String, dynamic>) {
    yield {'__error': 'invalid_json'};
    return;
  }
  final finalSnapshot = apply(complete);
  final ops = diffJsonLeafOps(lastSnapshot, finalSnapshot);
  if (ops.isNotEmpty) yield {'ops': ops};
  yield {'done': true};
}

/// 去掉模型偶尔包裹的 ```json 代码围栏。
String _stripCodeFence(String text) {
  var value = text.trimLeft();
  if (!value.startsWith('```')) return value;
  final firstNewline = value.indexOf('\n');
  value = firstNewline < 0 ? '' : value.substring(firstNewline + 1);
  final fenceEnd = value.lastIndexOf('```');
  return fenceEnd < 0 ? value : value.substring(0, fenceEnd);
}
