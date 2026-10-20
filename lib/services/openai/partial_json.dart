/// 容错的「部分 JSON」解析器：把 LLM 正在流式输出的 JSON 前缀解析成当前快照。
///
/// 规则（只为渐显服务，最终结果仍以完整 JSON 严格解析为准）：
/// - 未闭合的对象 / 数组视为已闭合；
/// - 未闭合的字符串保留已到达的内容（末尾不完整的转义序列丢弃）；
/// - 末尾未写完的数字、`true/false/null`、对象键（尚无 `:` 与值）一律丢弃；
/// - 遇到无法识别的字符即停止，返回此前已解析的部分。
library;

/// 解析 [input] 前缀；完全无法解析时返回 null。
Object? parsePartialJson(String input) {
  final parser = _PartialJsonParser(input);
  parser.skipWhitespace();
  if (parser.atEnd) return null;
  return parser.parseValue();
}

/// 解析结果中「值未完成」的哨兵，调用方据此丢弃该值。
const Object _incomplete = _Incomplete();

class _Incomplete {
  const _Incomplete();
}

class _PartialJsonParser {
  _PartialJsonParser(this.s);

  final String s;
  int i = 0;

  bool get atEnd => i >= s.length;

  void skipWhitespace() {
    while (!atEnd) {
      final c = s.codeUnitAt(i);
      if (c == 0x20 || c == 0x0A || c == 0x0D || c == 0x09) {
        i++;
      } else {
        break;
      }
    }
  }

  /// 解析一个值；未完成时返回 [_incomplete]（字符串除外，返回已到内容）。
  Object? parseValue() {
    skipWhitespace();
    if (atEnd) return _incomplete;
    final c = s[i];
    if (c == '{') return _parseObject();
    if (c == '[') return _parseArray();
    if (c == '"') return _parseString().value;
    if (c == 't' || c == 'f' || c == 'n') return _parseLiteral();
    return _parseNumber();
  }

  Map<String, dynamic> _parseObject() {
    final result = <String, dynamic>{};
    i++; // {
    while (true) {
      skipWhitespace();
      if (atEnd) return result;
      if (s[i] == '}') {
        i++;
        return result;
      }
      if (s[i] == ',') {
        i++;
        continue;
      }
      if (s[i] != '"') return result;
      final key = _parseString();
      if (!key.closed) return result; // 键还没写完
      skipWhitespace();
      if (atEnd || s[i] != ':') return result;
      i++; // :
      final value = parseValue();
      if (!identical(value, _incomplete)) result[key.value] = value;
      if (atEnd) return result;
    }
  }

  List<dynamic> _parseArray() {
    final result = <dynamic>[];
    i++; // [
    while (true) {
      skipWhitespace();
      if (atEnd) return result;
      if (s[i] == ']') {
        i++;
        return result;
      }
      if (s[i] == ',') {
        i++;
        continue;
      }
      final value = parseValue();
      if (!identical(value, _incomplete)) result.add(value);
      if (atEnd) return result;
    }
  }

  ({String value, bool closed}) _parseString() {
    final buffer = StringBuffer();
    i++; // "
    while (!atEnd) {
      final c = s[i];
      if (c == '"') {
        i++;
        return (value: buffer.toString(), closed: true);
      }
      if (c == r'\') {
        if (i + 1 >= s.length) {
          i = s.length;
          break;
        }
        final e = s[i + 1];
        switch (e) {
          case 'n':
            buffer.write('\n');
          case 't':
            buffer.write('\t');
          case 'r':
            buffer.write('\r');
          case 'b':
            buffer.write('\b');
          case 'f':
            buffer.write('\f');
          case 'u':
            if (i + 6 > s.length) {
              i = s.length; // 不完整的 \uXXXX，丢弃
              return (value: buffer.toString(), closed: false);
            }
            final code = int.tryParse(s.substring(i + 2, i + 6), radix: 16);
            if (code != null) buffer.writeCharCode(code);
            i += 6;
            continue;
          default:
            buffer.write(e); // \" \\ \/
        }
        i += 2;
        continue;
      }
      buffer.write(c);
      i++;
    }
    return (value: buffer.toString(), closed: false);
  }

  Object? _parseLiteral() {
    for (final (text, value) in const [
      ('true', true),
      ('false', false),
      ('null', null),
    ]) {
      if (s.startsWith(text, i)) {
        i += text.length;
        return value;
      }
    }
    i = s.length; // 字面量未写完
    return _incomplete;
  }

  Object? _parseNumber() {
    final start = i;
    while (!atEnd && '+-0123456789.eE'.contains(s[i])) {
      i++;
    }
    if (i == start) {
      i = s.length; // 无法识别的字符：停止解析
      return _incomplete;
    }
    if (atEnd) return _incomplete; // 数字可能还没写完
    return num.tryParse(s.substring(start, i)) ?? _incomplete;
  }
}
