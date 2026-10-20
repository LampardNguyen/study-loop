/// 自托管版各 AI 功能的 prompt 与输出 JSON 结构。
///
/// 结构必须与客户端模型的 `fromJson` 完全对齐（字段名即协议），原后端的
/// 结构说明见各模型文件：`sentence_ai_result.dart`、`dictionary_entry.dart`、
/// `sense_group_result.dart`、`retell_review_evaluation.dart`。
library;

import 'openai_chat_client.dart';

/// BCP 47 母语代码 → 给模型看的语言名。
String aiLanguageName(String? code) => switch (code) {
  'zh-CN' || 'zh' => 'Simplified Chinese (简体中文)',
  'zh-TW' => 'Traditional Chinese (繁體中文)',
  'vi' || 'vi-VN' => 'Vietnamese (Tiếng Việt)',
  'en' => 'English',
  null || '' => 'Simplified Chinese (简体中文)',
  _ => code,
};

const _jsonOnly =
    'Respond with ONE valid JSON object only — no markdown, no code fences, '
    'no commentary. Use exactly the field names given.';

/// 句子翻译：`{"translation": string}`。
List<OpenAiMessage> translationPrompt(
  String text, {
  String? previous,
  String? next,
  String? targetLanguage,
}) {
  final lang = aiLanguageName(targetLanguage);
  return [
    OpenAiMessage.system(
      'You translate English sentences from listening material into $lang '
      'for language learners. Translate ONLY the target sentence, naturally '
      'and faithfully; use the surrounding sentences only as context. '
      '$_jsonOnly Schema: {"translation": string}',
    ),
    OpenAiMessage.user(
      [
        if (previous != null) 'Previous sentence (context): $previous',
        'Target sentence: $text',
        if (next != null) 'Next sentence (context): $next',
      ].join('\n'),
    ),
  ];
}

/// 句子解析：语法 / 词汇 / 听力要点。
List<OpenAiMessage> analysisPrompt(String text, {String? targetLanguage}) {
  final lang = aiLanguageName(targetLanguage);
  return [
    OpenAiMessage.system(
      'You are an English teacher explaining one sentence to a learner whose '
      'native language is $lang. Give 1-4 items per list, most useful first. '
      '"point", "term" and "phrase" quote the English text; every "note" is '
      'written in $lang and is concise. "listening" covers connected speech, '
      'weak forms, linking, reductions or stress that make the sentence hard '
      'to hear. $_jsonOnly Schema: {"grammar":[{"point":string,"note":string}],'
      '"vocabulary":[{"term":string,"note":string}],'
      '"listening":[{"phrase":string,"note":string}]}',
    ),
    OpenAiMessage.user('Sentence: $text'),
  ];
}

/// 单词词典条目（DictionaryEntry）。
List<OpenAiMessage> wordLookupPrompt(String word, {String? targetLanguage}) {
  final lang = aiLanguageName(targetLanguage);
  return [
    OpenAiMessage.system(
      'You are a learner\'s English–$lang dictionary. Explain the English '
      'word for a learner whose native language is $lang. "translation" lists '
      'short $lang equivalents; "definition" is a simple English definition; '
      '"usageNote", "meaning", "etymology" and "learnerTips" are in $lang; '
      'example "sentence" is natural English and its "translation" is $lang. '
      'Pronunciation uses IPA with slashes. Order meanings by frequency '
      '(max 5). commonExpressions "type" is one of: collocation, phrasal verb, '
      'idiom, phrase. forms "label" names the form (e.g. "plural", '
      '"past tense"). Omit nothing in the schema; use [] or "" when empty. '
      '$_jsonOnly Schema: {"headword":string,'
      '"pronunciation":{"uk":string,"us":string},'
      '"meanings":[{"partOfSpeech":string,"translation":[string],'
      '"definition":string,"usageNote":string,'
      '"examples":[{"sentence":string,"translation":string}],'
      '"synonyms":[string],"antonyms":[string]}],'
      '"commonExpressions":[{"expression":string,"type":string,'
      '"meaning":string,"example":{"sentence":string,"translation":string}}],'
      '"wordFamily":[{"word":string,"partOfSpeech":string,"meaning":string,'
      '"example":{"sentence":string,"translation":string}}],'
      '"forms":[{"form":string,"label":string}],'
      '"etymology":string,"learnerTips":[string]}',
    ),
    OpenAiMessage.user('Word: $word'),
  ];
}

/// 词组 / 多词表达条目（MultiWordDictionaryEntry）。
List<OpenAiMessage> phraseLookupPrompt(
  String phrase, {
  String? targetLanguage,
}) {
  final lang = aiLanguageName(targetLanguage);
  return [
    OpenAiMessage.system(
      'You are a learner\'s English–$lang dictionary for multi-word '
      'expressions. Explain the English expression for a learner whose native '
      'language is $lang. "originalExpression" repeats the expression; '
      '"category" is a short label (e.g. idiom, phrasal verb, collocation, '
      'sentence pattern) in $lang; "naturalness" says in $lang how natural / '
      'common it is and in what register; "pronunciationTips" explain linking '
      'or stress in $lang; "keyPoints" explain usage in $lang with an English '
      '"sentence" and its $lang "translation"; "meanings" list $lang '
      '"translation" equivalents with English examples; "similarExpressions" '
      'compare alternatives ("difference" in $lang); "background" (in $lang) '
      'gives origin or cultural notes, or "". $_jsonOnly Schema: '
      '{"originalExpression":string,"category":string,"naturalness":string,'
      '"pronunciationTips":[string],'
      '"keyPoints":[{"point":string,"sentence":string,"translation":string}],'
      '"meanings":[{"translation":[string],'
      '"examples":[{"sentence":string,"translation":string}]}],'
      '"similarExpressions":[{"expression":string,"difference":string,'
      '"sentence":string,"translation":string}],"background":string}',
    ),
    OpenAiMessage.user('Expression: $phrase'),
  ];
}

/// 意群拆分：两种粒度，拼接后必须原样还原原句。
List<OpenAiMessage> senseGroupsPrompt(String text) => [
  const OpenAiMessage.system(
    'You split an English sentence into sense groups (thought groups) for '
    'listening and shadowing practice. "medium" follows natural spoken rhythm '
    '(typically 3-7 words per chunk); "fine" splits further so structure is '
    'clear. Each chunk is a contiguous substring of the original sentence, '
    'copied character-for-character (keep punctuation, keep the space that '
    'follows a chunk at the END of that chunk), so that joining the chunks '
    'with no separator reproduces the original sentence exactly. Never '
    'rewrite, fix or translate the text. '
    '$_jsonOnly Schema: {"medium":[string],"fine":[string]}',
  ),
  OpenAiMessage.user(text),
];

/// 复述评估：对照原文评价学习者的复述转录。
List<OpenAiMessage> retellReviewPrompt({
  required String originalText,
  required String transcript,
  String? targetLanguage,
}) {
  final lang = aiLanguageName(targetLanguage);
  return [
    OpenAiMessage.system(
      'You evaluate a language learner\'s spoken retelling of an English '
      'passage. Compare the learner\'s transcript with the original. Write '
      '"summary", "feedback", "suggestion" and "explanation" in $lang; quote '
      'English for "keyPoint", "original", "transcript" and "correction". '
      '"rating" is one of: poor, fair, good, excellent, perfect. Each key point '
      '"status" is one of: covered, partial, missed, distorted, added. Each '
      'correction "type" is one of: grammar, wordChoice, redundancy, phrasing, '
      'cohesion; list at most 6 corrections, most important first. Copy the '
      'learner transcript unchanged into "transcript". $_jsonOnly Schema: '
      '{"transcript":string,"summary":string,"rating":string,'
      '"keyPoints":[{"keyPoint":string,"original":string,"transcript":string,'
      '"status":string,"feedback":string}],"suggestion":string,'
      '"corrections":[{"type":string,"transcript":string,"correction":string,'
      '"explanation":string}]}',
    ),
    OpenAiMessage.user(
      'Original passage:\n$originalText\n\nLearner transcript:\n$transcript',
    ),
  ];
}
