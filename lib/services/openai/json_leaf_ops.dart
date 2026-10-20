/// 把两个 JSON 快照之间的差异转换成后端同款「按路径设叶子」增量批（ops）。
///
/// 输出格式与 `accumulateNdjsonObject` 消费的协议一致：
/// `[{"p": ["meanings", 0, "definition"], "v": "..."}, ...]`。
/// 只对标量叶子（字符串 / 数字 / 布尔 / null）生成 op；空容器不生成（累积端
/// 缺字段即回退空值）。
library;

/// 展平 [value] 为「路径 → 标量叶子」映射（保持文档顺序）。
List<(List<Object>, Object?)> flattenJsonLeaves(Object? value) {
  final out = <(List<Object>, Object?)>[];
  void walk(Object? node, List<Object> path) {
    if (node is Map) {
      for (final entry in node.entries) {
        final key = entry.key;
        if (key is String) walk(entry.value, [...path, key]);
      }
    } else if (node is List) {
      for (var index = 0; index < node.length; index++) {
        walk(node[index], [...path, index]);
      }
    } else if (path.isNotEmpty) {
      out.add((path, node));
    }
  }

  walk(value, const []);
  return out;
}

/// 生成从 [previous] 到 [next] 需要设置的叶子 op（新增或值变化的叶子）。
List<Map<String, Object?>> diffJsonLeafOps(Object? previous, Object? next) {
  final before = <String, Object?>{
    for (final (path, value) in flattenJsonLeaves(previous))
      path.join('\u0000'): value,
  };
  final ops = <Map<String, Object?>>[];
  for (final (path, value) in flattenJsonLeaves(next)) {
    final key = path.join('\u0000');
    if (!before.containsKey(key) || before[key] != value) {
      ops.add({'p': path, 'v': value});
    }
  }
  return ops;
}
