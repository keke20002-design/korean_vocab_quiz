/// 퀴즈 문제 모델 클래스
/// 퀴즈 진행 중 사용되는 개별 문제 데이터
class Quiz {
  final int wordId; // 정답 단어의 ID
  final String question; // 문제 (단어 또는 의미)
  final String correctAnswer; // 정답
  final List<String> options; // 선택지 (정답 포함)
  final QuizType type; // 퀴즈 타입 (단어→의미 또는 의미→단어)
  String? userAnswer; // 사용자가 선택한 답
  bool? isCorrect; // 정답 여부

  /// 생성자
  Quiz({
    required this.wordId,
    required this.question,
    required this.correctAnswer,
    required this.options,
    required this.type,
    this.userAnswer,
    this.isCorrect,
  });

  /// 사용자 답변 설정 및 정답 여부 확인
  void submitAnswer(String answer) {
    userAnswer = answer;
    isCorrect = answer == correctAnswer;
  }

  /// 답변 초기화
  void resetAnswer() {
    userAnswer = null;
    isCorrect = null;
  }

  /// 퀴즈가 답변되었는지 확인
  bool get isAnswered => userAnswer != null;

  /// Map으로 변환 (저장용)
  Map<String, dynamic> toMap() {
    return {
      'wordId': wordId,
      'question': question,
      'correctAnswer': correctAnswer,
      'options': options,
      'type': type.toString(),
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
    };
  }

  /// Map에서 Quiz 객체 생성
  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      wordId: map['wordId'] as int,
      question: map['question'] as String,
      correctAnswer: map['correctAnswer'] as String,
      options: List<String>.from(map['options'] as List),
      type: QuizType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => QuizType.wordToMeaning,
      ),
      userAnswer: map['userAnswer'] as String?,
      isCorrect: map['isCorrect'] as bool?,
    );
  }

  /// 복사
  Quiz copyWith({
    int? wordId,
    String? question,
    String? correctAnswer,
    List<String>? options,
    QuizType? type,
    String? userAnswer,
    bool? isCorrect,
  }) {
    return Quiz(
      wordId: wordId ?? this.wordId,
      question: question ?? this.question,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      options: options ?? this.options,
      type: type ?? this.type,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  @override
  String toString() {
    return 'Quiz{wordId: $wordId, question: $question, type: $type, isCorrect: $isCorrect}';
  }
}

/// 퀴즈 타입 열거형
enum QuizType {
  wordToMeaning, // 단어를 보고 의미 맞추기
  meaningToWord, // 의미를 보고 단어 맞추기
}

/// QuizType 확장 메서드
extension QuizTypeExtension on QuizType {
  /// 퀴즈 타입을 한글로 반환
  String get displayName {
    switch (this) {
      case QuizType.wordToMeaning:
        return '단어 → 의미';
      case QuizType.meaningToWord:
        return '의미 → 단어';
    }
  }

  /// 퀴즈 타입 설명
  String get description {
    switch (this) {
      case QuizType.wordToMeaning:
        return '단어를 보고 알맞은 의미를 선택하세요';
      case QuizType.meaningToWord:
        return '의미를 보고 알맞은 단어를 선택하세요';
    }
  }
}
