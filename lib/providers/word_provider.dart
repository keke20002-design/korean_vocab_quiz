import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word.dart';
import '../services/database_service.dart';
import '../services/krdict_service.dart';

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

  // 마지막 API 동기화 시간
  DateTime? _lastSyncTime;

  static const _prefKeyLastSync = 'last_sync_time';

  // Getters
  List<Word> get words => _filteredWords;
  DateTime? get lastSyncTime => _lastSyncTime;
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
      // 마지막 동기화 시간 복원
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKeyLastSync);
      if (saved != null) _lastSyncTime = DateTime.tryParse(saved);
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

  /// 마지막 동기화 시간 저장
  Future<void> _saveSyncTime() async {
    _lastSyncTime = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKeyLastSync, _lastSyncTime!.toIso8601String());
    notifyListeners();
  }

  /// 국립국어원 API에서 단어 불러오기
  /// 반환값: 새로 추가된 단어 수 (이미 있는 단어는 스킵)
  Future<int> fetchWordsFromApi({
    required String query,
    int target = 1,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await KrDictService.fetchWords(query: query, defaultDifficulty: target);
      final saved = await _dbService.batchInsertWords(fetched);
      await _saveSyncTime();
      await loadWords();
      return saved;
    } catch (e) {
      _errorMessage = 'API 불러오기 실패: $e';
      _isLoading = false;
      notifyListeners();
      return 0;
    }
  }

  /// 전체 주제 일괄 동기화 (모든 주제를 순서대로 호출)
  /// [onProgress]: 진행 콜백 (현재 주제, 전체 수)
  Future<int> fetchAllWordsFromApi({
    required List<String> topics,
    int target = 1,
    void Function(String topic, int current, int total)? onProgress,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    int totalSaved = 0;
    for (int i = 0; i < topics.length; i++) {
      final topic = topics[i];
      onProgress?.call(topic, i + 1, topics.length);
      try {
        // Round-robin: i%3 → 0=쉬움(1), 1=보통(2), 2=어려움(3)
        // 15개 주제 → 각 5개씩 균등 배분
        final roundRobinDifficulty = (i % 3) + 1;
        // 주제별 최대 10초 타임아웃 — 초과 시 빈 목록으로 스킵
        final fetched = await KrDictService.fetchWords(query: topic, defaultDifficulty: roundRobinDifficulty)
            .timeout(const Duration(seconds: 10), onTimeout: () => []);
        if (fetched.isNotEmpty) {
          totalSaved += await _dbService.batchInsertWords(fetched);
        }
      } catch (_) {
        // 개별 주제 실패 시 계속 진행
      }
    }

    await _saveSyncTime();
    await loadWords();
    return totalSaved;
  }

  /// 오늘 추가된 단어 수
  Future<int> getTodayWordsCount() async {
    return await _dbService.getTodayWordsCount();
  }

  /// 중복 단어 수
  Future<int> getDuplicateWordsCount() async {
    final dups = await _dbService.getDuplicateWords();
    // 단어별 그룹에서 중복본(첫 번째 제외)의 수
    final Map<String, int> counts = {};
    for (final w in dups) {
      counts[w.word] = (counts[w.word] ?? 0) + 1;
    }
    return counts.values.fold<int>(0, (sum, c) => sum + (c - 1));
  }

  /// 중복 단어 정리
  Future<int> removeDuplicates() async {
    final deleted = await _dbService.deleteDuplicateWords();
    await loadWords();
    return deleted;
  }

  /// 학습 현황 통계 (미학습/학습중/완전정복)
  Future<Map<String, int>> getLearningStats() async {
    return await _dbService.getLearningStats();
  }

  /// 요주의 단어 목록 (정답률 낮은 순)
  Future<List<Word>> getWeakWords(int limit) async {
    return await _dbService.getWeakWords(limit);
  }

  /// 최근 N일 학습 캘린더
  Future<Map<String, int>> getStudyCalendar(int days) async {
    return await _dbService.getStudyCalendar(days);
  }

  /// 에러 메시지 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
