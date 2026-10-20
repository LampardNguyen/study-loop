import 'package:echo_loop/services/openai/partial_json.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('完整 JSON 与 jsonDecode 一致', () {
    expect(parsePartialJson('{"a":1,"b":[true,null,"x"],"c":{"d":2.5}}'), {
      'a': 1,
      'b': [true, null, 'x'],
      'c': {'d': 2.5},
    });
  });

  test('未闭合字符串保留已到内容（用于渐显）', () {
    expect(parsePartialJson('{"translation":"Xin ch'), {
      'translation': 'Xin ch',
    });
  });

  test('未写完的键、数字、字面量被丢弃', () {
    expect(parsePartialJson('{"a":"x","b'), {'a': 'x'});
    expect(parsePartialJson('{"a":"x","b":'), {'a': 'x'});
    expect(parsePartialJson('{"a":12'), <String, dynamic>{});
    expect(parsePartialJson('{"a":tr'), <String, dynamic>{});
  });

  test('嵌套数组对象逐步出现', () {
    expect(parsePartialJson('{"grammar":[{"point":"Present","note":"us'), {
      'grammar': [
        {'point': 'Present', 'note': 'us'},
      ],
    });
  });

  test('转义：完整转义解码，末尾不完整的转义被丢弃', () {
    expect(parsePartialJson(r'{"a":"line\nnext \"q\" é"}'), {
      'a': 'line\nnext "q" é',
    });
    expect(parsePartialJson(r'{"a":"ab\'), {'a': 'ab'});
    expect(parsePartialJson(r'{"a":"ab\u00'), {'a': 'ab'});
  });

  test('空输入 / 非 JSON 返回 null 或空', () {
    expect(parsePartialJson(''), isNull);
    expect(parsePartialJson('   '), isNull);
    expect(parsePartialJson('{'), <String, dynamic>{});
  });
}
