/// 퀴즈 결과 모델 클래스
/// 완료된 퀴즈의 결과를 저장하는 데이터 모델
class QuizResult {
  final int? id; // 데이터베이스 ID (자동 생성)
  final int totalQuestions; // 전체 문제 수
  final int correctAnswers; // 정답 개수
  final int wrongAnswers; // 오답 개수
  final double score; // 점수 (백분율)
  final int timeTaken; // 소요 시간 (초)
  final DateTime completedAt; // 완료 시간
  final String? quizType; // 퀴즈 타입 (선택사항)

  /// 생성자
  QuizResult({
    this.id,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.score,
    required this.timeTaken,
    DateTime? completedAt,
    this.quizType,
  }) : completedAt = completedAt ?? DateTime.now();

  /// 정답률 계산 (0.0 ~ 1.0)
  double get accuracy {
    if (totalQuestions == 0) return 0.0;
    return correctAnswers / totalQuestions;
  }

  /// 정답률을 백분율로 반환 (0 ~ 100)
  int get accuracyPercentage {
    return (accuracy * 100).round();
  }

  /// 등급 반환 (S, A, B, C, D, F)
  String get grade {
    if (accuracyPercentage >= 95) return 'S';
    if (accuracyPercentage >= 90) return 'A';
    if (accuracyPercentage >= 80) return 'B';
    if (accuracyPercentage >= 70) return 'C';
    if (accuracyPercentage >= 60) return 'D';
    return 'F';
  }

  /// 등급에 따른 메시지
  String get gradeMessage {
    switch (grade) {
      case 'S':
        return '완벽해요! 🌟';
      case 'A':
        return '훌륭해요! 🎉';
      case 'B':
        return '잘했어요! 👍';
      case 'C':
        return '괜찮아요! 😊';
      case 'D':
        return '조금만 더 힘내요! 💪';
      case 'F':
        return '다시 도전해봐요! 📚';
      default:
        return '수고했어요!';
    }
  }

  /// 소요 시간을 분:초 형식으로 반환
  String get formattedTime {
    final minutes = timeTaken ~/ 60;
    final seconds = timeTaken % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 데이터베이스에서 읽어온 Map을 QuizResult 객체로 변환
  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'] as int?,
      totalQuestions: map['totalQuestions'] as int,
      correctAnswers: map['correctAnswers'] as int,
      wrongAnswers: map['wrongAnswers'] as int,
      score: map['score'] as double,
      timeTaken: map['timeTaken'] as int,
      completedAt: DateTime.parse(map['completedAt'] as String),
      quizType: map['quizType'] as String?,
    );
  }

  /// QuizResult 객체를 데이터베이스에 저장할 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'score': score,
      'timeTaken': timeTaken,
      'completedAt': completedAt.toIso8601String(),
      'quizType': quizType,
    };
  }

  /// QuizResult 객체 복사
  QuizResult copyWith({
    int? id,
    int? totalQuestions,
    int? correctAnswers,
    int? wrongAnswers,
    double? score,
    int? timeTaken,
    DateTime? completedAt,
    String? quizType,
  }) {
    return QuizResult(
      id: id ?? this.id,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      score: score ?? this.score,
      timeTaken: timeTaken ?? this.timeTaken,
      completedAt: completedAt ?? this.completedAt,
      quizType: quizType ?? this.quizType,
    );
  }

  /// 디버깅용 문자열 표현
  @override
  String toString() {
    return 'QuizResult{id: $id, score: $score%, correct: $correctAnswers/$totalQuestions, grade: $grade}';
  }

  /// 동등성 비교
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuizResult &&
        other.id == id &&
        other.totalQuestions == totalQuestions &&
        other.correctAnswers == correctAnswers &&
        other.score == score;
  }

  /// 해시코드
  @override
  int get hashCode {
    return id.hashCode ^
        totalQuestions.hashCode ^
        correctAnswers.hashCode ^
        score.hashCode;
  }
}
