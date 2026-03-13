import '../models/word.dart';
import '../services/database_service.dart';

/// 샘플 데이터 관리 클래스
/// 초기 데이터베이스에 샘플 단어를 추가
class SampleData {
  static final DatabaseService _dbService = DatabaseService();

  /// 초기 샘플 단어 목록
  static final List<Word> sampleWords = [
    // 난이도 1: 쉬움 (초등학교 저학년)
    Word(
      word: '사과',
      meaning: '빨갛고 둥근 과일',
      example: '나는 사과를 좋아해요.',
      difficulty: 1,
    ),
    Word(
      word: '학교',
      meaning: '공부하는 곳',
      example: '우리는 학교에 가요.',
      difficulty: 1,
    ),
    Word(
      word: '친구',
      meaning: '사이좋게 지내는 사람',
      example: '친구와 함께 놀아요.',
      difficulty: 1,
    ),
    Word(
      word: '가족',
      meaning: '함께 사는 식구',
      example: '우리 가족은 네 명이에요.',
      difficulty: 1,
    ),
    Word(
      word: '책',
      meaning: '글이나 그림이 있는 것',
      example: '재미있는 책을 읽어요.',
      difficulty: 1,
    ),
    Word(
      word: '물',
      meaning: '마시는 투명한 액체',
      example: '목이 말라서 물을 마셔요.',
      difficulty: 1,
    ),
    Word(
      word: '집',
      meaning: '사람이 사는 곳',
      example: '우리 집은 아파트예요.',
      difficulty: 1,
    ),
    Word(
      word: '하늘',
      meaning: '위를 보면 보이는 공간',
      example: '하늘이 파랗고 예뻐요.',
      difficulty: 1,
    ),

    // 난이도 2: 보통 (초등학교 중학년)
    Word(
      word: '행복',
      meaning: '기쁘고 즐거운 느낌',
      example: '가족과 함께 있으면 행복해요.',
      difficulty: 2,
    ),
    Word(
      word: '용기',
      meaning: '두려움 없이 해내는 힘',
      example: '용기를 내서 발표했어요.',
      difficulty: 2,
    ),
    Word(
      word: '정직',
      meaning: '거짓말하지 않는 것',
      example: '정직한 사람이 되고 싶어요.',
      difficulty: 2,
    ),
    Word(
      word: '배려',
      meaning: '다른 사람을 생각하는 마음',
      example: '친구를 배려하는 것이 중요해요.',
      difficulty: 2,
    ),
    Word(
      word: '노력',
      meaning: '목표를 위해 힘쓰는 것',
      example: '노력하면 잘할 수 있어요.',
      difficulty: 2,
    ),
    Word(
      word: '협동',
      meaning: '함께 힘을 합치는 것',
      example: '협동하면 더 잘할 수 있어요.',
      difficulty: 2,
    ),
    Word(
      word: '감사',
      meaning: '고마운 마음',
      example: '부모님께 감사해요.',
      difficulty: 2,
    ),

    // 난이도 3: 어려움 (초등학교 고학년)
    Word(
      word: '존중',
      meaning: '다른 사람을 귀하게 여기는 것',
      example: '서로를 존중해야 해요.',
      difficulty: 3,
    ),
    Word(
      word: '책임',
      meaning: '맡은 일을 끝까지 하는 것',
      example: '자신의 행동에 책임을 져야 해요.',
      difficulty: 3,
    ),
    Word(
      word: '인내',
      meaning: '어려움을 참고 견디는 것',
      example: '인내심을 가지고 기다렸어요.',
      difficulty: 3,
    ),
    Word(
      word: '창의',
      meaning: '새로운 것을 만들어내는 능력',
      example: '창의적인 생각이 필요해요.',
      difficulty: 3,
    ),
    Word(
      word: '공감',
      meaning: '다른 사람의 마음을 이해하는 것',
      example: '친구의 슬픔에 공감했어요.',
      difficulty: 3,
    ),
    Word(
      word: '성실',
      meaning: '정성을 다해 최선을 다하는 것',
      example: '성실하게 공부해요.',
      difficulty: 3,
    ),
    Word(
      word: '겸손',
      meaning: '자신을 낮추고 남을 존중하는 태도',
      example: '겸손한 태도가 중요해요.',
      difficulty: 3,
    ),
    Word(
      word: '배움',
      meaning: '새로운 지식을 얻는 것',
      example: '배움은 평생 계속돼요.',
      difficulty: 3,
    ),
  ];

  /// 샘플 데이터가 이미 있는지 확인
  static Future<bool> hasSampleData() async {
    final count = await _dbService.getWordsCount();
    return count > 0;
  }

  /// 샘플 데이터 추가
  static Future<void> addSampleData() async {
    // 이미 데이터가 있으면 추가하지 않음
    if (await hasSampleData()) {
      return;
    }

    // 샘플 단어 추가
    for (var word in sampleWords) {
      await _dbService.insertWord(word);
    }
  }

  /// 샘플 데이터 강제 추가 (기존 데이터 유지)
  static Future<void> addMoreSampleData() async {
    for (var word in sampleWords) {
      await _dbService.insertWord(word);
    }
  }

  /// 모든 데이터 삭제 후 샘플 데이터 재추가
  static Future<void> resetToSampleData() async {
    await _dbService.clearAllData();
    await addSampleData();
  }
}
