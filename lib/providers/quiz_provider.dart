import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../models/quiz.dart';
import '../models/quiz_result.dart';
import '../services/database_service.dart';

/// 퀴즈 관리 Provider
/// 퀴즈 진행 상태를 관리하고 UI에 알림
class QuizProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  // 퀴즈 목록
  final List<Quiz> _quizzes = [];
  
  // 현재 퀴즈 인덱스
  int _currentQuizIndex = 0;
  
  // 퀴즈 진행 상태
  bool _isQuizActive = false;
  
  // 퀴즈 시작 시간
  DateTime? _startTime;
  
  // 퀴즈 결과 목록
  List<QuizResult> _quizResults = [];
  
  // 로딩 상태
  bool _isLoading = false;
  
  // 에러 메시지
  String? _errorMessage;

  // Getters
  List<Quiz> get quizzes => _quizzes;
  int get currentQuizIndex => _currentQuizIndex;
  bool get isQuizActive => _isQuizActive;
  List<QuizResult> get quizResults => _quizResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// 현재 퀴즈
  Quiz? get currentQuiz {
    if (_quizzes.isEmpty || _currentQuizIndex >= _quizzes.length) {
      return null;
    }
    return _quizzes[_currentQuizIndex];
  }
  
  /// 전체 퀴즈 개수
  int get totalQuizzes => _quizzes.length;
  
  /// 답변한 퀴즈 개수
  int get answeredCount => _quizzes.where((q) => q.isAnswered).length;
  
  /// 정답 개수
  int get correctCount => _quizzes.where((q) => q.isCorrect == true).length;
  
  /// 오답 개수
  int get wrongCount => _quizzes.where((q) => q.isCorrect == false).length;
  
  /// 진행률 (0.0 ~ 1.0)
  double get progress {
    if (_quizzes.isEmpty) return 0.0;
    return _currentQuizIndex / _quizzes.length;
  }
  
  /// 퀴즈가 완료되었는지
  bool get isQuizCompleted => _currentQuizIndex >= _quizzes.length;
  
  /// 다음 퀴즈가 있는지
  bool get hasNextQuiz => _currentQuizIndex < _quizzes.length - 1;
  
  /// 이전 퀴즈가 있는지
  bool get hasPreviousQuiz => _currentQuizIndex > 0;

  /// 퀴즈 생성
  Future<bool> generateQuiz({
    required List<Word> words,
    required int questionCount,
    required QuizType quizType,
  }) async {
    if (words.length < 4) {
      _errorMessage = '퀴즈를 만들려면 최소 4개의 단어가 필요합니다.';
      notifyListeners();
      return false;
    }

    try {
      _quizzes.clear();
      _currentQuizIndex = 0;
      
      // 단어 섞기
      final shuffledWords = List<Word>.from(words)..shuffle();
      final selectedWords = shuffledWords.take(questionCount).toList();

      for (var word in selectedWords) {
        // 정답과 오답 선택지 생성
        final quiz = _createQuizFromWord(word, words, quizType);
        _quizzes.add(quiz);
      }

      _isQuizActive = true;
      _startTime = DateTime.now();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = '퀴즈를 생성하는 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 단어로부터 퀴즈 생성
  Quiz _createQuizFromWord(Word word, List<Word> allWords, QuizType type) {
    final random = Random();
    final options = <String>[];
    
    // 정답 설정
    final correctAnswer = type == QuizType.wordToMeaning ? word.meaning : word.word;
    final question = type == QuizType.wordToMeaning ? word.word : word.meaning;
    
    // 정답 추가
    options.add(correctAnswer);
    
    // 오답 3개 추가
    final otherWords = allWords.where((w) => w.id != word.id).toList()..shuffle();
    for (var i = 0; i < 3 && i < otherWords.length; i++) {
      final wrongAnswer = type == QuizType.wordToMeaning 
          ? otherWords[i].meaning 
          : otherWords[i].word;
      
      // 중복 방지
      if (!options.contains(wrongAnswer)) {
        options.add(wrongAnswer);
      }
    }
    
    // 선택지가 4개 미만이면 더미 데이터 추가
    while (options.length < 4) {
      options.add('선택지 ${options.length + 1}');
    }
    
    // 선택지 섞기
    options.shuffle(random);
    
    return Quiz(
      wordId: word.id!,
      question: question,
      correctAnswer: correctAnswer,
      options: options,
      type: type,
    );
  }

  /// 답변 제출
  void submitAnswer(String answer) {
    if (currentQuiz == null) return;
    
    currentQuiz!.submitAnswer(answer);
    notifyListeners();
  }

  /// 다음 퀴즈로 이동
  void nextQuiz() {
    if (hasNextQuiz) {
      _currentQuizIndex++;
      notifyListeners();
    }
  }

  /// 이전 퀴즈로 이동
  void previousQuiz() {
    if (hasPreviousQuiz) {
      _currentQuizIndex--;
      notifyListeners();
    }
  }

  /// 특정 퀴즈로 이동
  void goToQuiz(int index) {
    if (index >= 0 && index < _quizzes.length) {
      _currentQuizIndex = index;
      notifyListeners();
    }
  }

  /// 퀴즈 완료 및 결과 저장
  Future<QuizResult?> completeQuiz() async {
    if (!isQuizCompleted && answeredCount < totalQuizzes) {
      _errorMessage = '모든 문제를 풀어주세요.';
      notifyListeners();
      return null;
    }

    try {
      final timeTaken = _startTime != null 
          ? DateTime.now().difference(_startTime!).inSeconds 
          : 0;
      
      final score = totalQuizzes > 0 
          ? (correctCount / totalQuizzes * 100) 
          : 0.0;

      final result = QuizResult(
        totalQuestions: totalQuizzes,
        correctAnswers: correctCount,
        wrongAnswers: wrongCount,
        score: score,
        timeTaken: timeTaken,
        quizType: _quizzes.isNotEmpty ? _quizzes.first.type.displayName : null,
      );

      // 결과 저장
      await _dbService.insertQuizResult(result);
      
      // 결과 목록 새로고침
      await loadQuizResults();
      
      _isQuizActive = false;
      notifyListeners();
      
      return result;
    } catch (e) {
      _errorMessage = '퀴즈 결과를 저장하는 중 오류가 발생했습니다: $e';
      notifyListeners();
      return null;
    }
  }

  /// 퀴즈 초기화
  void resetQuiz() {
    _quizzes.clear();
    _currentQuizIndex = 0;
    _isQuizActive = false;
    _startTime = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// 퀴즈 결과 불러오기
  Future<void> loadQuizResults() async {
    _isLoading = true;
    notifyListeners();

    try {
      _quizResults = await _dbService.getAllQuizResults();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '퀴즈 결과를 불러오는 중 오류가 발생했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 최근 퀴즈 결과 불러오기
  Future<void> loadRecentQuizResults(int limit) async {
    try {
      _quizResults = await _dbService.getRecentQuizResults(limit);
      notifyListeners();
    } catch (e) {
      _errorMessage = '퀴즈 결과를 불러오는 중 오류가 발생했습니다: $e';
      notifyListeners();
    }
  }

  /// 퀴즈 결과 삭제
  Future<bool> deleteQuizResult(int id) async {
    try {
      final result = await _dbService.deleteQuizResult(id);
      if (result > 0) {
        await loadQuizResults();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = '퀴즈 결과를 삭제하는 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 평균 점수 가져오기
  Future<double> getAverageScore() async {
    try {
      return await _dbService.getAverageScore();
    } catch (e) {
      return 0.0;
    }
  }

  /// 최고 점수 가져오기
  Future<double> getHighestScore() async {
    try {
      return await _dbService.getHighestScore();
    } catch (e) {
      return 0.0;
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
