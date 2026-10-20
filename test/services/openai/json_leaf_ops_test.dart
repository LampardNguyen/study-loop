import 'package:echo_loop/services/ndjson_object_stream.dart';
import 'package:echo_loop/services/openai/json_leaf_ops.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('首次快照生成全部叶子，路径含数组下标', () {
    expect(
      diffJsonLeafOps(null, {
        'a': 'x',
        'list': [
          {'k': 1},
        ],
      }),
      [
        {
          'p': ['a'],
          'v': 'x',
        },
        {
          'p': ['list', 0, 'k'],
          'v': 1,
        },
      ],
    );
  });

  test('只输出新增或变化的叶子', () {
    final ops = diffJsonLeafOps(
      {'a': 'Xin', 'b': 'same'},
      {'a': 'Xin chào', 'b': 'same', 'c': true},
    );
    expect(ops, [
      {
        'p': ['a'],
        'v': 'Xin chào',
      },
      {
        'p': ['c'],
        'v': true,
      },
    ]);
  });

  test('按 ops 回放可重建原对象（与 accumulate 的 setPath 协议一致）', () {
    final target = <String, dynamic>{
      'meanings': [
        {
          'partOfSpeech': 'noun',
          'translation': ['a', 'b'],
        },
      ],
      'etymology': 'old',
    };
    final rebuilt = <String, dynamic>{};
    for (final op in diffJsonLeafOps(null, target)) {
      setPath(rebuilt, op['p']! as List<Object?>, op['v']);
    }
    expect(rebuilt, target);
  });
}
