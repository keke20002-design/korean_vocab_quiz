/// 단어 모델 클래스
class Word {
  final int? id;
  final String word;
  final String meaning;
  final String? example;
  final int difficulty;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int tryCount;
  final int correctCount;
  final DateTime? lastTested;
  final bool isFavorite;

  Word({
    this.id,
    required this.word,
    required this.meaning,
    this.example,
    this.difficulty = 1,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.tryCount = 0,
    this.correctCount = 0,
    this.lastTested,
    this.isFavorite = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as int?,
      word: map['word'] as String,
      meaning: map['meaning'] as String,
      example: map['example'] as String?,
      difficulty: map['difficulty'] as int? ?? 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      tryCount: map['try_count'] as int? ?? 0,
      correctCount: map['correct_count'] as int? ?? 0,
      lastTested: map['last_tested'] != null
          ? DateTime.tryParse(map['last_tested'] as String)
          : null,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'example': example,
      'difficulty': difficulty,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'try_count': tryCount,
      'correct_count': correctCount,
      'last_tested': lastTested?.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  Word copyWith({
    int? id,
    String? word,
    String? meaning,
    String? example,
    int? difficulty,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? tryCount,
    int? correctCount,
    DateTime? lastTested,
    bool? isFavorite,
  }) {
    return Word(
      id: id ?? this.id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tryCount: tryCount ?? this.tryCount,
      correctCount: correctCount ?? this.correctCount,
      lastTested: lastTested ?? this.lastTested,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get difficultyText {
    switch (difficulty) {
      case 1: return '쉬움';
      case 2: return '보통';
      case 3: return '어려움';
      default: return '보통';
    }
  }

  @override
  String toString() {
    return 'Word{id: $id, word: $word, meaning: $meaning, difficulty: $difficulty}';
  }

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

  @override
  int get hashCode {
    return id.hashCode ^
        word.hashCode ^
        meaning.hashCode ^
        example.hashCode ^
        difficulty.hashCode;
  }
}
