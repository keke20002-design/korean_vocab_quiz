/// 단어 모델 클래스
/// 한국어 단어와 그 의미를 저장하는 데이터 모델
class Word {
  final int? id; // 데이터베이스 ID (자동 생성)
  final String word; // 한국어 단어
  final String meaning; // 단어의 의미/뜻
  final String? example; // 예문 (선택사항)
  final int difficulty; // 난이도 (1: 쉬움, 2: 보통, 3: 어려움)
  final DateTime createdAt; // 생성 날짜
  final DateTime updatedAt; // 수정 날짜

  /// 생성자
  Word({
    this.id,
    required this.word,
    required this.meaning,
    this.example,
    this.difficulty = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// 데이터베이스에서 읽어온 Map을 Word 객체로 변환
  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as int?,
      word: map['word'] as String,
      meaning: map['meaning'] as String,
      example: map['example'] as String?,
      difficulty: map['difficulty'] as int? ?? 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// Word 객체를 데이터베이스에 저장할 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'example': example,
      'difficulty': difficulty,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Word 객체 복사 (일부 필드만 변경)
  Word copyWith({
    int? id,
    String? word,
    String? meaning,
    String? example,
    int? difficulty,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Word(
      id: id ?? this.id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 난이도를 문자열로 반환
  String get difficultyText {
    switch (difficulty) {
      case 1:
        return '쉬움';
      case 2:
        return '보통';
      case 3:
        return '어려움';
      default:
        return '보통';
    }
  }

  /// 디버깅용 문자열 표현
  @override
  String toString() {
    return 'Word{id: $id, word: $word, meaning: $meaning, difficulty: $difficulty}';
  }

  /// 동등성 비교
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Word &&
        other.id == id &&
        other.word == word &&
        other.meaning == meaning &&
        other.example == example &&
        other.difficulty == difficulty;
  }

  /// 해시코드
  @override
  int get hashCode {
    return id.hashCode ^
        word.hashCode ^
        meaning.hashCode ^
        example.hashCode ^
        difficulty.hashCode;
  }
}
