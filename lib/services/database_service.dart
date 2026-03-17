import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/word.dart';
import '../models/quiz_result.dart';
import '../utils/constants.dart';

/// 데이터베이스 서비스 클래스
/// SQLite 데이터베이스를 관리하고 CRUD 작업을 수행
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  /// 싱글톤 패턴 - 인스턴스 반환
  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  /// 데이터베이스 인스턴스 가져오기
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// 데이터베이스 초기화
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 데이터베이스 테이블 생성
  Future<void> _onCreate(Database db, int version) async {
    // 단어 테이블 생성
    await db.execute('''
      CREATE TABLE ${AppConstants.wordsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL UNIQUE,
        meaning TEXT NOT NULL,
        example TEXT,
        difficulty INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        try_count INTEGER DEFAULT 0,
        correct_count INTEGER DEFAULT 0,
        last_tested TEXT,
        is_favorite INTEGER DEFAULT 0
      )
    ''');

    // 퀴즈 결과 테이블 생성
    await db.execute('''
      CREATE TABLE ${AppConstants.quizResultsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        totalQuestions INTEGER NOT NULL,
        correctAnswers INTEGER NOT NULL,
        wrongAnswers INTEGER NOT NULL,
        score REAL NOT NULL,
        timeTaken INTEGER NOT NULL,
        completedAt TEXT NOT NULL,
        quizType TEXT
      )
    ''');
  }

  /// 데이터베이스 업그레이드
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 중복 단어 먼저 제거 (id가 작은 것만 남김)
      await db.rawDelete('''
        DELETE FROM ${AppConstants.wordsTable}
        WHERE id NOT IN (
          SELECT MIN(id) FROM ${AppConstants.wordsTable} GROUP BY word
        )
      ''');
      // UNIQUE 인덱스 추가
      await db.execute('''
        CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_word
        ON ${AppConstants.wordsTable}(word)
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE ${AppConstants.wordsTable} ADD COLUMN try_count INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE ${AppConstants.wordsTable} ADD COLUMN correct_count INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE ${AppConstants.wordsTable} ADD COLUMN last_tested TEXT');
      await db.execute('ALTER TABLE ${AppConstants.wordsTable} ADD COLUMN is_favorite INTEGER DEFAULT 0');
    }
  }

  // ==================== 단어 관련 메서드 ====================

  /// 단어 추가
  Future<int> insertWord(Word word) async {
    final db = await database;
    return await db.insert(
      AppConstants.wordsTable,
      word.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 모든 단어 조회
  Future<List<Word>> getAllWords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.wordsTable,
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Word.fromMap(maps[i]);
    });
  }

  /// ID로 단어 조회
  Future<Word?> getWordById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.wordsTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Word.fromMap(maps.first);
  }

  /// 난이도별 단어 조회
  Future<List<Word>> getWordsByDifficulty(int difficulty) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.wordsTable,
      where: 'difficulty = ?',
      whereArgs: [difficulty],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Word.fromMap(maps[i]);
    });
  }

  /// 단어 검색
  Future<List<Word>> searchWords(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.wordsTable,
      where: 'word LIKE ? OR meaning LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return Word.fromMap(maps[i]);
    });
  }

  /// 단어 수정
  Future<int> updateWord(Word word) async {
    final db = await database;
    return await db.update(
      AppConstants.wordsTable,
      word.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  /// 단어 일괄 삽입 (Batch Insert, UNIQUE 제약으로 중복 자동 스킵)
  Future<int> batchInsertWords(List<Word> words) async {
    final db = await database;
    int inserted = 0;

    final batch = db.batch();
    for (final word in words) {
      batch.insert(
        AppConstants.wordsTable,
        word.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    final results = await batch.commit(noResult: false);
    // ConflictAlgorithm.ignore 시 성공=양수, 무시=0
    inserted = results.whereType<int>().where((r) => r > 0).length;
    return inserted;
  }

  /// 단어 삭제
  Future<int> deleteWord(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.wordsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 전체 단어 개수 조회
  Future<int> getWordsCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.wordsTable}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 오늘 추가된 단어 수
  Future<int> getTodayWordsCount() async {
    final db = await database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).toIso8601String();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.wordsTable} WHERE createdAt >= ?',
      [startOfDay],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 중복 단어 목록 조회 (같은 word가 2개 이상인 것)
  Future<List<Word>> getDuplicateWords() async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT * FROM ${AppConstants.wordsTable}
      WHERE word IN (
        SELECT word FROM ${AppConstants.wordsTable}
        GROUP BY word HAVING COUNT(*) > 1
      )
      ORDER BY word, id
    ''');
    return maps.map(Word.fromMap).toList();
  }

  /// 중복 단어 정리 (각 word에서 id 가장 작은 것만 남김)
  Future<int> deleteDuplicateWords() async {
    final db = await database;
    return await db.rawDelete('''
      DELETE FROM ${AppConstants.wordsTable}
      WHERE id NOT IN (
        SELECT MIN(id) FROM ${AppConstants.wordsTable} GROUP BY word
      )
    ''');
  }

  /// 단어 학습 통계 업데이트 (퀴즈 후 호출)
  Future<void> updateWordStats(int wordId, bool isCorrect) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE ${AppConstants.wordsTable}
      SET
        try_count = try_count + 1,
        correct_count = correct_count + ?,
        last_tested = ?
      WHERE id = ?
    ''', [isCorrect ? 1 : 0, DateTime.now().toIso8601String(), wordId]);
  }

  /// 학습 현황 통계 (미학습/학습중/완전정복)
  Future<Map<String, int>> getLearningStats() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        SUM(CASE WHEN try_count = 0 THEN 1 ELSE 0 END) as untested,
        SUM(CASE WHEN try_count > 0 AND correct_count < 3 THEN 1 ELSE 0 END) as learning,
        SUM(CASE WHEN correct_count >= 3 THEN 1 ELSE 0 END) as mastered
      FROM ${AppConstants.wordsTable}
    ''');
    if (result.isEmpty) return {'untested': 0, 'learning': 0, 'mastered': 0};
    final row = result.first;
    return {
      'untested': (row['untested'] as int?) ?? 0,
      'learning': (row['learning'] as int?) ?? 0,
      'mastered': (row['mastered'] as int?) ?? 0,
    };
  }

  /// 요주의 단어 (정답률 50% 미만, 시도 횟수 있는 단어)
  Future<List<Word>> getWeakWords(int limit) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT * FROM ${AppConstants.wordsTable}
      WHERE try_count > 0
        AND CAST(correct_count AS REAL) / try_count < 0.5
      ORDER BY CAST(correct_count AS REAL) / try_count ASC, try_count DESC
      LIMIT ?
    ''', [limit]);
    return maps.map(Word.fromMap).toList();
  }

  /// 최근 N일 학습 기록 (퀴즈 세션 수 / 일)
  Future<Map<String, int>> getStudyCalendar(int days) async {
    final db = await database;
    final since = DateTime.now().subtract(Duration(days: days - 1));
    final sinceStr = DateTime(since.year, since.month, since.day).toIso8601String();
    final result = await db.rawQuery('''
      SELECT DATE(completedAt) as day, COUNT(*) as count
      FROM ${AppConstants.quizResultsTable}
      WHERE completedAt >= ?
      GROUP BY DATE(completedAt)
    ''', [sinceStr]);
    final Map<String, int> calendar = {};
    for (final row in result) {
      calendar[row['day'] as String] = row['count'] as int;
    }
    return calendar;
  }

  /// 난이도별 단어 개수 조회
  Future<Map<int, int>> getWordsCountByDifficulty() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT difficulty, COUNT(*) as count FROM ${AppConstants.wordsTable} GROUP BY difficulty',
    );

    final Map<int, int> counts = {1: 0, 2: 0, 3: 0};
    for (var row in result) {
      final difficulty = row['difficulty'] as int;
      final count = row['count'] as int;
      counts[difficulty] = count;
    }
    return counts;
  }

  // ==================== 퀴즈 결과 관련 메서드 ====================

  /// 퀴즈 결과 저장
  Future<int> insertQuizResult(QuizResult result) async {
    final db = await database;
    return await db.insert(
      AppConstants.quizResultsTable,
      result.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 모든 퀴즈 결과 조회
  Future<List<QuizResult>> getAllQuizResults() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.quizResultsTable,
      orderBy: 'completedAt DESC',
    );

    return List.generate(maps.length, (i) {
      return QuizResult.fromMap(maps[i]);
    });
  }

  /// 최근 퀴즈 결과 조회 (limit 개수만큼)
  Future<List<QuizResult>> getRecentQuizResults(int limit) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.quizResultsTable,
      orderBy: 'completedAt DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return QuizResult.fromMap(maps[i]);
    });
  }

  /// 퀴즈 결과 삭제
  Future<int> deleteQuizResult(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.quizResultsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 전체 퀴즈 결과 개수 조회
  Future<int> getQuizResultsCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppConstants.quizResultsTable}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// 평균 점수 조회
  Future<double> getAverageScore() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(score) as avgScore FROM ${AppConstants.quizResultsTable}',
    );
    return (result.first['avgScore'] as double?) ?? 0.0;
  }

  /// 최고 점수 조회
  Future<double> getHighestScore() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(score) as maxScore FROM ${AppConstants.quizResultsTable}',
    );
    return (result.first['maxScore'] as double?) ?? 0.0;
  }

  // ==================== 유틸리티 메서드 ====================

  /// 모든 데이터 삭제 (초기화)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(AppConstants.wordsTable);
    await db.delete(AppConstants.quizResultsTable);
  }

  /// 데이터베이스 닫기
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
