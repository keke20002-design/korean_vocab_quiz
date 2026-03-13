import 'package:flutter/foundation.dart';
import '../models/word.dart';
import '../services/database_service.dart';

/// 단어 관리 Provider
/// 단어 목록의 상태를 관리하고 UI에 알림
class WordProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  // 단어 목록
  List<Word> _words = [];
  
  // 로딩 상태
  bool _isLoading = false;
  
  // 에러 메시지
  String? _errorMessage;
  
  // 검색 쿼리
  String _searchQuery = '';
  
  // 난이도 필터 (0: 전체, 1: 쉬움, 2: 보통, 3: 어려움)
  int _difficultyFilter = 0;

  // Getters
  List<Word> get words => _filteredWords;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int get difficultyFilter => _difficultyFilter;
  int get totalWords => _words.length;
  bool get hasWords => _words.isNotEmpty;

  /// 필터링된 단어 목록 반환
  List<Word> get _filteredWords {
    var filtered = _words;

    // 난이도 필터 적용
    if (_difficultyFilter > 0) {
      filtered = filtered.where((word) => word.difficulty == _difficultyFilter).toList();
    }

    // 검색 쿼리 적용
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((word) {
        return word.word.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            word.meaning.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  /// 난이도별 단어 개수
  Map<int, int> get wordsCountByDifficulty {
    final Map<int, int> counts = {1: 0, 2: 0, 3: 0};
    for (var word in _words) {
      counts[word.difficulty] = (counts[word.difficulty] ?? 0) + 1;
    }
    return counts;
  }

  /// 모든 단어 불러오기
  Future<void> loadWords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _words = await _dbService.getAllWords();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = '단어를 불러오는 중 오류가 발생했습니다: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 단어 추가
  Future<bool> addWord(Word word) async {
    try {
      final id = await _dbService.insertWord(word);
      if (id > 0) {
        await loadWords(); // 목록 새로고침
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = '단어를 추가하는 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 단어 수정
  Future<bool> updateWord(Word word) async {
    try {
      final result = await _dbService.updateWord(word);
      if (result > 0) {
        await loadWords(); // 목록 새로고침
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = '단어를 수정하는 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// 단어 삭제
  Future<bool> deleteWord(int id) async {
    try {
      final result = await _dbService.deleteWord(id);
      if (result > 0) {
        await loadWords(); // 목록 새로고침
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = '단어를 삭제하는 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// ID로 단어 찾기
  Future<Word?> getWordById(int id) async {
    try {
      return await _dbService.getWordById(id);
    } catch (e) {
      _errorMessage = '단어를 찾는 중 오류가 발생했습니다: $e';
      notifyListeners();
      return null;
    }
  }

  /// 검색 쿼리 설정
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// 검색 쿼리 초기화
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// 난이도 필터 설정
  void setDifficultyFilter(int difficulty) {
    _difficultyFilter = difficulty;
    notifyListeners();
  }

  /// 필터 초기화
  void clearFilters() {
    _searchQuery = '';
    _difficultyFilter = 0;
    notifyListeners();
  }

  /// 랜덤 단어 가져오기 (퀴즈용)
  List<Word> getRandomWords(int count, {int? difficulty}) {
    var availableWords = difficulty != null
        ? _words.where((word) => word.difficulty == difficulty).toList()
        : _words;

    if (availableWords.length <= count) {
      return List.from(availableWords)..shuffle();
    }

    availableWords.shuffle();
    return availableWords.take(count).toList();
  }

  /// 에러 메시지 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
