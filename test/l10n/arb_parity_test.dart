/// ARB 完整性回归：各语言文件必须与模板 app_en.arb 拥有完全相同的 key，
/// 且每条译文保留与英文相同的占位符，避免越南语等译文漏 key 或丢占位符。
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, String> _messages(String path) {
  final decoded = jsonDecode(File(path).readAsStringSync());
  final map = decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  return {
    for (final entry in map.entries)
      if (!entry.key.startsWith('@') && entry.value is String)
        entry.key: entry.value as String,
  };
}

/// 提取顶层占位符名（含 ICU plural/select 的选择变量）。
Set<String> _placeholders(String message) => RegExp(
  r'\{\s*([A-Za-z_][A-Za-z0-9_]*)\s*[,}]',
).allMatches(message).map((m) => m.group(1) ?? '').toSet();

void main() {
  final en = _messages('lib/l10n/app_en.arb');

  for (final lang in ['zh', 'vi']) {
    group('app_$lang.arb', () {
      final other = _messages('lib/l10n/app_$lang.arb');

      test('key 集合与 app_en.arb 一致', () {
        expect(other.keys.toSet().difference(en.keys.toSet()), isEmpty);
        expect(en.keys.toSet().difference(other.keys.toSet()), isEmpty);
      });

      test('占位符与英文一致', () {
        final mismatched = [
          for (final key in en.keys)
            if (other.containsKey(key) &&
                _placeholders(
                  en[key] ?? '',
                ).difference(_placeholders(other[key] ?? '')).isNotEmpty)
              key,
        ];
        expect(mismatched, isEmpty);
      });
    });
  }
}
