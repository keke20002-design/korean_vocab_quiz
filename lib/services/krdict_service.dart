import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/word.dart';

/// 국립국어원 한국어기초사전 API 서비스
/// https://krdict.korean.go.kr/api/search
class KrDictService {
  static const String _apiKey = '5D99AD9751DEE350B4FCC92189A70302';
  static const String _baseUrl = 'https://krdict.korean.go.kr/api/search';

  // 최대 뜻풀이 길이 (초등학생 수준 필터링)
  static const int _maxDefinitionLength = 60;
  // 최대 단어 길이
  static const int _maxWordLength = 10;

  /// API에서 단어 검색
  /// [query]: 검색어 (예: '가족', '학교', '동물')
  /// [defaultDifficulty]: 앱 내 난이도 태그 (1=쉬움, 2=보통, 3=어려움)
  ///   - API 레벨 필터(lv)는 중급·고급에서 결과가 0이 되는 문제로 사용하지 않음
  ///   - 대신 다운로드한 단어에 이 값을 기본 난이도로 지정
  /// [num]: 가져올 단어 수 (최대 100)
  static Future<List<Word>> fetchWords({
    required String query,
    int defaultDifficulty = 1,
    int num = 100,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'key': _apiKey,
      'part': 'word',
      'q': query,
      'sort': 'popular',
      'num': num.toString(),
      // advanced/lv/pos 필터 제거:
      // lv=2(중급) 필터 시 대부분 주제어가 0건 반환되는 KRDict DB 특성
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('API 호출 실패 (${response.statusCode})');
    }

    return _parseXml(response.body, defaultDifficulty);
  }

  static List<Word> _parseXml(String xmlString, int defaultDifficulty) {
    final XmlDocument document;
    try {
      document = XmlDocument.parse(xmlString);
    } catch (_) {
      throw Exception('XML 파싱 실패');
    }

    final items = document.findAllElements('item');
    final now = DateTime.now();
    final words = <Word>[];

    for (final item in items) {
      // 단어 추출
      final wordEls = item.findElements('word');
      if (wordEls.isEmpty) continue;
      final wordText = wordEls.first.innerText.trim();

      // 너무 길거나 비어있는 단어 제외
      if (wordText.isEmpty || wordText.length > _maxWordLength) continue;

      // 첫 번째 뜻 추출 (sense > definition)
      final senseEls = item.findAllElements('sense');
      if (senseEls.isEmpty) continue;
      final defEls = senseEls.first.findElements('definition');
      if (defEls.isEmpty) continue;
      final definition = defEls.first.innerText.trim();

      // 너무 길거나 빈 뜻 제외
      if (definition.isEmpty || definition.length > _maxDefinitionLength) continue;

      words.add(Word(
        word: wordText,
        meaning: definition,
        // 사용자가 선택한 수준을 기본 난이도로 사용
        // (어려운 키워드가 있으면 3으로 올림)
        difficulty: _classifyDifficulty(wordText, definition, defaultDifficulty),
        createdAt: now,
        updatedAt: now,
      ));
    }

    return words;
  }

  /// 단어와 뜻을 기반으로 난이도 분류
  /// [base]: 사용자가 선택한 수준 (기본값으로 사용)
  static int _classifyDifficulty(String word, String definition, int base) {
    // 어려움 키워드 → 항상 3
    const hardKeywords = [
      '관념', '이데올로기', '메커니즘', '추상적', '체계적', '이념', '논리',
      '철학', '개념', '원리', '현상', '구조', '제도', '사회적', '문화적',
    ];
    for (final kw in hardKeywords) {
      if (definition.contains(kw)) return 3;
    }

    // 보통 키워드/길이 → base==1 이면 2로 올림
    const mediumKeywords = [
      '관계', '상태', '활동', '행동', '방법', '과정', '결과', '영향',
      '목적', '종류', '특징', '역할', '기능', '의미', '내용',
    ];
    if (base == 1) {
      if (word.length >= 3) return 2;          // 3음절+ 단어
      if (definition.length >= 30) return 2;  // 긴 정의
      for (final kw in mediumKeywords) {
        if (definition.contains(kw)) return 2;
      }
    }

    return base;
  }
}
