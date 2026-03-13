import '../models/word.dart';
import '../services/database_service.dart';

/// 샘플 데이터 관리 클래스
/// 초기 데이터베이스에 샘플 단어를 추가
class SampleData {
  static final DatabaseService _dbService = DatabaseService();

  /// 초기 샘플 단어 목록 (쉬움 33 / 보통 33 / 어려움 34 = 100개)
  static final List<Word> sampleWords = [
    // ==================== 난이도 1: 쉬움 (33개) ====================
    Word(word: '사과', meaning: '빨갛고 둥근 과일', example: '나는 사과를 좋아해요.', difficulty: 1),
    Word(word: '학교', meaning: '공부하는 곳', example: '우리는 학교에 가요.', difficulty: 1),
    Word(word: '친구', meaning: '사이좋게 지내는 사람', example: '친구와 함께 놀아요.', difficulty: 1),
    Word(word: '가족', meaning: '함께 사는 식구', example: '우리 가족은 네 명이에요.', difficulty: 1),
    Word(word: '책', meaning: '글이나 그림이 담긴 것', example: '재미있는 책을 읽어요.', difficulty: 1),
    Word(word: '물', meaning: '마시는 투명한 액체', example: '목이 말라서 물을 마셔요.', difficulty: 1),
    Word(word: '집', meaning: '사람이 사는 곳', example: '우리 집은 아파트예요.', difficulty: 1),
    Word(word: '하늘', meaning: '위를 보면 보이는 공간', example: '하늘이 파랗고 예뻐요.', difficulty: 1),
    Word(word: '밥', meaning: '쌀로 지은 음식', example: '점심에 밥을 먹어요.', difficulty: 1),
    Word(word: '나무', meaning: '땅에서 자라는 큰 식물', example: '나무가 크게 자랐어요.', difficulty: 1),
    Word(word: '꽃', meaning: '예쁜 색깔을 가진 식물', example: '꽃이 활짝 피었어요.', difficulty: 1),
    Word(word: '고양이', meaning: '야옹 소리를 내는 동물', example: '고양이가 귀엽게 잠을 자요.', difficulty: 1),
    Word(word: '강아지', meaning: '멍멍 소리를 내는 동물', example: '강아지와 산책을 해요.', difficulty: 1),
    Word(word: '엄마', meaning: '나를 낳아준 여자 부모', example: '엄마가 맛있는 음식을 만들었어요.', difficulty: 1),
    Word(word: '아빠', meaning: '나를 낳아준 남자 부모', example: '아빠와 함께 놀이터에 갔어요.', difficulty: 1),
    Word(word: '손', meaning: '물건을 잡는 신체 부위', example: '손을 깨끗이 씻어요.', difficulty: 1),
    Word(word: '눈', meaning: '보는 데 사용하는 신체 부위', example: '눈으로 예쁜 꽃을 봐요.', difficulty: 1),
    Word(word: '코', meaning: '냄새를 맡는 신체 부위', example: '코로 꽃향기를 맡아요.', difficulty: 1),
    Word(word: '귀', meaning: '소리를 듣는 신체 부위', example: '귀로 음악을 들어요.', difficulty: 1),
    Word(word: '입', meaning: '음식을 먹는 신체 부위', example: '입으로 맛있는 음식을 먹어요.', difficulty: 1),
    Word(word: '공', meaning: '둥글게 생긴 장난감', example: '친구와 공을 던지며 놀아요.', difficulty: 1),
    Word(word: '버스', meaning: '많은 사람이 타는 큰 차', example: '버스를 타고 학교에 가요.', difficulty: 1),
    Word(word: '빨강', meaning: '사과나 불처럼 붉은 색깔', example: '빨간 장미가 예뻐요.', difficulty: 1),
    Word(word: '파랑', meaning: '하늘이나 바다 같은 색깔', example: '파란 하늘이 맑아요.', difficulty: 1),
    Word(word: '노랑', meaning: '바나나나 해바라기 같은 색깔', example: '노란 병아리가 귀여워요.', difficulty: 1),
    Word(word: '봄', meaning: '꽃이 피는 따뜻한 계절', example: '봄에 꽃이 피어요.', difficulty: 1),
    Word(word: '여름', meaning: '덥고 비가 많이 오는 계절', example: '여름에 수박을 먹어요.', difficulty: 1),
    Word(word: '가을', meaning: '단풍이 드는 시원한 계절', example: '가을에 낙엽이 떨어져요.', difficulty: 1),
    Word(word: '겨울', meaning: '눈이 오고 추운 계절', example: '겨울에 눈사람을 만들어요.', difficulty: 1),
    Word(word: '비', meaning: '하늘에서 내리는 물방울', example: '비가 와서 우산을 써요.', difficulty: 1),
    Word(word: '바람', meaning: '공기가 움직이는 것', example: '바람이 세게 불어요.', difficulty: 1),
    Word(word: '산', meaning: '땅이 높게 솟아오른 곳', example: '산에 올라가면 경치가 좋아요.', difficulty: 1),
    Word(word: '바다', meaning: '짠물이 넓게 펼쳐진 곳', example: '바다에서 수영을 해요.', difficulty: 1),

    // ==================== 난이도 2: 보통 (33개) ====================
    Word(word: '행복', meaning: '기쁘고 즐거운 느낌', example: '가족과 함께 있으면 행복해요.', difficulty: 2),
    Word(word: '용기', meaning: '두려움 없이 해내는 힘', example: '용기를 내서 발표했어요.', difficulty: 2),
    Word(word: '정직', meaning: '거짓말하지 않는 것', example: '정직한 사람이 되고 싶어요.', difficulty: 2),
    Word(word: '배려', meaning: '다른 사람을 생각하는 마음', example: '친구를 배려하는 것이 중요해요.', difficulty: 2),
    Word(word: '노력', meaning: '목표를 위해 힘쓰는 것', example: '노력하면 잘할 수 있어요.', difficulty: 2),
    Word(word: '협동', meaning: '함께 힘을 합치는 것', example: '협동하면 더 잘할 수 있어요.', difficulty: 2),
    Word(word: '감사', meaning: '고마운 마음', example: '부모님께 감사해요.', difficulty: 2),
    Word(word: '약속', meaning: '서로 정한 것을 지키는 것', example: '친구와 한 약속을 꼭 지켜요.', difficulty: 2),
    Word(word: '믿음', meaning: '믿고 의지하는 마음', example: '친구를 믿음으로 사귀어요.', difficulty: 2),
    Word(word: '건강', meaning: '몸이 튼튼한 상태', example: '운동을 해서 건강을 지켜요.', difficulty: 2),
    Word(word: '운동', meaning: '몸을 움직이는 활동', example: '매일 운동을 하면 좋아요.', difficulty: 2),
    Word(word: '음악', meaning: '소리로 감정을 표현하는 예술', example: '음악을 들으면 기분이 좋아요.', difficulty: 2),
    Word(word: '여행', meaning: '다른 곳에 가서 구경하는 것', example: '가족과 여행을 떠나요.', difficulty: 2),
    Word(word: '꿈', meaning: '미래에 이루고 싶은 것', example: '나의 꿈은 선생님이에요.', difficulty: 2),
    Word(word: '희망', meaning: '좋은 일이 생길 거라는 기대', example: '희망을 가지고 열심히 해요.', difficulty: 2),
    Word(word: '도움', meaning: '힘든 사람을 돕는 것', example: '친구에게 도움을 줬어요.', difficulty: 2),
    Word(word: '친절', meaning: '다른 사람에게 상냥하게 대하는 것', example: '친절하게 인사해요.', difficulty: 2),
    Word(word: '예의', meaning: '다른 사람을 존중하는 행동', example: '어른께 예의 바르게 인사해요.', difficulty: 2),
    Word(word: '연습', meaning: '잘하기 위해 반복하는 것', example: '피아노를 매일 연습해요.', difficulty: 2),
    Word(word: '실력', meaning: '잘할 수 있는 능력', example: '꾸준히 연습하면 실력이 늘어요.', difficulty: 2),
    Word(word: '환경', meaning: '우리를 둘러싼 자연과 세상', example: '환경을 깨끗이 보호해요.', difficulty: 2),
    Word(word: '자연', meaning: '사람이 만들지 않은 세계', example: '자연 속에서 신선한 공기를 마셔요.', difficulty: 2),
    Word(word: '추억', meaning: '지난 일에 대한 소중한 기억', example: '가족 여행의 추억이 소중해요.', difficulty: 2),
    Word(word: '경험', meaning: '직접 해보고 느끼는 것', example: '다양한 경험이 성장에 도움이 돼요.', difficulty: 2),
    Word(word: '계획', meaning: '앞으로 할 일을 미리 정하는 것', example: '여름 방학 계획을 세웠어요.', difficulty: 2),
    Word(word: '준비', meaning: '일이 시작되기 전에 갖추는 것', example: '발표를 위해 열심히 준비했어요.', difficulty: 2),
    Word(word: '나눔', meaning: '가진 것을 다른 사람과 함께하는 것', example: '음식을 나눔으로 함께 먹어요.', difficulty: 2),
    Word(word: '상상', meaning: '머릿속으로 그려보는 것', example: '상상력을 발휘해 그림을 그렸어요.', difficulty: 2),
    Word(word: '호기심', meaning: '모르는 것을 알고 싶어하는 마음', example: '호기심이 많은 아이가 잘 배워요.', difficulty: 2),
    Word(word: '탐구', meaning: '깊이 생각하고 조사하는 것', example: '과학 시간에 탐구 활동을 했어요.', difficulty: 2),
    Word(word: '문화', meaning: '사람들이 함께 만들어온 생활 방식', example: '우리나라의 문화를 배워요.', difficulty: 2),
    Word(word: '역할', meaning: '맡아서 해야 하는 일', example: '모둠에서 각자 역할을 나눴어요.', difficulty: 2),
    Word(word: '창작', meaning: '새로운 것을 스스로 만드는 것', example: '시를 창작해서 발표했어요.', difficulty: 2),

    // ==================== 난이도 3: 어려움 (34개) ====================
    Word(word: '존중', meaning: '다른 사람을 귀하게 여기는 것', example: '서로를 존중해야 해요.', difficulty: 3),
    Word(word: '책임', meaning: '맡은 일을 끝까지 하는 것', example: '자신의 행동에 책임을 져야 해요.', difficulty: 3),
    Word(word: '인내', meaning: '어려움을 참고 견디는 것', example: '인내심을 가지고 기다렸어요.', difficulty: 3),
    Word(word: '창의', meaning: '새로운 것을 만들어내는 능력', example: '창의적인 생각이 필요해요.', difficulty: 3),
    Word(word: '공감', meaning: '다른 사람의 마음을 이해하는 것', example: '친구의 슬픔에 공감했어요.', difficulty: 3),
    Word(word: '성실', meaning: '정성을 다해 최선을 다하는 것', example: '성실하게 공부해요.', difficulty: 3),
    Word(word: '겸손', meaning: '자신을 낮추고 남을 존중하는 태도', example: '겸손한 태도가 중요해요.', difficulty: 3),
    Word(word: '배움', meaning: '새로운 지식을 얻는 것', example: '배움은 평생 계속돼요.', difficulty: 3),
    Word(word: '지혜', meaning: '올바르게 판단하고 행동하는 능력', example: '지혜롭게 문제를 해결했어요.', difficulty: 3),
    Word(word: '평등', meaning: '모든 사람이 같은 대우를 받는 것', example: '모든 사람은 평등하게 대우받아야 해요.', difficulty: 3),
    Word(word: '자유', meaning: '스스로 결정할 수 있는 권리', example: '자유롭게 생각을 표현해요.', difficulty: 3),
    Word(word: '권리', meaning: '당연히 누릴 수 있는 자격', example: '교육받을 권리는 모두에게 있어요.', difficulty: 3),
    Word(word: '의무', meaning: '반드시 해야 하는 일', example: '학교에 다니는 것은 의무예요.', difficulty: 3),
    Word(word: '민주', meaning: '모든 사람이 함께 결정하는 방식', example: '민주주의 사회에서는 투표를 해요.', difficulty: 3),
    Word(word: '윤리', meaning: '옳고 그름을 판단하는 기준', example: '윤리적인 행동이 중요해요.', difficulty: 3),
    Word(word: '논리', meaning: '생각을 체계적으로 이어가는 방식', example: '논리적으로 설명해야 해요.', difficulty: 3),
    Word(word: '판단', meaning: '어떤 것이 맞는지 결정하는 것', example: '올바른 판단을 위해 생각해요.', difficulty: 3),
    Word(word: '분석', meaning: '자세히 살펴보고 따져보는 것', example: '자료를 분석해서 결과를 냈어요.', difficulty: 3),
    Word(word: '비교', meaning: '두 가지를 견주어 보는 것', example: '두 나라를 비교해서 발표했어요.', difficulty: 3),
    Word(word: '가치', meaning: '중요하고 의미 있다고 여기는 것', example: '건강의 가치를 소중히 여겨요.', difficulty: 3),
    Word(word: '도덕', meaning: '사람이 지켜야 할 올바른 행동', example: '도덕 시간에 배운 것을 실천해요.', difficulty: 3),
    Word(word: '정의', meaning: '옳고 공정한 것', example: '정의로운 사회를 만들어야 해요.', difficulty: 3),
    Word(word: '질서', meaning: '정해진 규칙에 따라 바르게 하는 것', example: '줄을 서서 질서를 지켜요.', difficulty: 3),
    Word(word: '규칙', meaning: '모두가 지켜야 하는 정해진 것', example: '교실의 규칙을 잘 지켜요.', difficulty: 3),
    Word(word: '전통', meaning: '오랫동안 이어온 생활 방식이나 문화', example: '우리나라 전통 음식은 김치예요.', difficulty: 3),
    Word(word: '역사', meaning: '과거에 있었던 일들의 기록', example: '역사를 배우면 과거를 알 수 있어요.', difficulty: 3),
    Word(word: '과학', meaning: '자연 현상을 연구하는 학문', example: '과학 실험이 재미있어요.', difficulty: 3),
    Word(word: '기술', meaning: '도구나 방법을 사용하는 능력', example: '새로운 기술이 생활을 편리하게 해요.', difficulty: 3),
    Word(word: '혁신', meaning: '새로운 방법으로 크게 바꾸는 것', example: '혁신적인 아이디어로 세상을 바꿔요.', difficulty: 3),
    Word(word: '생태', meaning: '생물과 환경의 관계', example: '생태계를 보호해야 해요.', difficulty: 3),
    Word(word: '경제', meaning: '물건을 만들고 사고파는 활동', example: '경제를 이해하면 세상이 보여요.', difficulty: 3),
    Word(word: '사회', meaning: '사람들이 함께 모여 사는 집단', example: '사회 구성원으로서 역할을 다해요.', difficulty: 3),
    Word(word: '소통', meaning: '생각이나 느낌을 서로 주고받는 것', example: '원활한 소통이 중요해요.', difficulty: 3),
    Word(word: '비판', meaning: '잘못된 점을 따져서 밝히는 것', example: '건전한 비판은 발전을 가져와요.', difficulty: 3),
  ];

  /// 샘플 데이터가 이미 있는지 확인
  static Future<bool> hasSampleData() async {
    final count = await _dbService.getWordsCount();
    return count > 0;
  }

  /// 샘플 데이터 추가 (DB가 비어있을 때만)
  static Future<void> addSampleData() async {
    if (await hasSampleData()) {
      return;
    }
    for (var word in sampleWords) {
      await _dbService.insertWord(word);
    }
  }

  /// 샘플 데이터 강제 추가 (기존 데이터 유지, 중복 스킵)
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
