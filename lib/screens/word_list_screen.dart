import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/word_provider.dart';
import '../providers/quiz_provider.dart';
import '../models/word.dart';
import '../models/quiz.dart';
import '../utils/constants.dart';
import 'word_form_screen.dart';
import 'quiz_screen.dart';
import 'package:intl/intl.dart';

/// 단어 관리 화면 — 학습 대시보드
class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  static const String _bannerAdUnitId = 'ca-app-pub-5381891295736795/1661860861';

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  int _todayCount = 0;
  int _duplicateCount = 0;
  Map<String, int> _learningStats = {'untested': 0, 'learning': 0, 'mastered': 0};
  List<Word> _weakWords = [];
  Map<String, int> _studyCalendar = {};
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    if (kIsWeb) return;
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() => _isBannerAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    setState(() => _statsLoading = true);
    final provider = context.read<WordProvider>();
    final today = await provider.getTodayWordsCount();
    final dups = await provider.getDuplicateWordsCount();
    final stats = await provider.getLearningStats();
    final weak = await provider.getWeakWords(10);
    final calendar = await provider.getStudyCalendar(7);
    if (mounted) {
      setState(() {
        _todayCount = today;
        _duplicateCount = dups;
        _learningStats = stats;
        _weakWords = weak;
        _studyCalendar = calendar;
        _statsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('단어 관리'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.add),
            onPressed: _navigateToAddWord,
          ),
        ],
      ),
      bottomNavigationBar: _isBannerAdLoaded && _bannerAd != null
          ? SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
      body: _statsLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                children: [
                  _buildDashboard(),
                  _buildActionButtons(),
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingM),
                    child: Column(
                      children: [
                        _buildLearningProgress(),
                        const SizedBox(height: AppTheme.paddingM),
                        _buildWeakWords(),
                        const SizedBox(height: AppTheme.paddingM),
                        _buildStudyCalendar(),
                        const SizedBox(height: AppTheme.paddingL),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ==================== 대시보드 ====================

  Widget _buildDashboard() {
    return Consumer<WordProvider>(
      builder: (context, provider, child) {
        final syncTime = provider.lastSyncTime;
        final syncLabel = syncTime != null
            ? DateFormat('MM/dd HH:mm').format(syncTime)
            : '없음';
        return Container(
          color: AppTheme.cardColor,
          padding: const EdgeInsets.fromLTRB(
            AppTheme.paddingM,
            AppTheme.paddingM,
            AppTheme.paddingM,
            AppTheme.paddingS,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildStatTile('전체 단어', '${provider.totalWords}개', AppTheme.primaryColor),
                  _buildStatDivider(),
                  _buildStatTile('오늘 추가', '$_todayCount개', AppTheme.successColor),
                  _buildStatDivider(),
                  _buildStatTile('중복 단어', '$_duplicateCount개',
                      _duplicateCount > 0 ? AppTheme.errorColor : AppTheme.textSecondaryColor),
                ],
              ),
              const SizedBox(height: AppTheme.paddingS),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.sync, size: 12, color: AppTheme.textLightColor),
                  const SizedBox(width: 4),
                  Text(
                    '마지막 동기화: $syncLabel',
                    style: AppTheme.caption.copyWith(color: AppTheme.textLightColor),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTheme.headingSmall.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.caption),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 36, color: AppTheme.surfaceColor);
  }

  // ==================== 액션 버튼 ====================

  Widget _buildActionButtons() {
    return Container(
      color: AppTheme.cardColor,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.paddingM,
        AppTheme.paddingS,
        AppTheme.paddingM,
        AppTheme.paddingM,
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showApiImportDialog,
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('단어장 내려받기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingS),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.paddingS),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _duplicateCount > 0 ? _confirmRemoveDuplicates : null,
              icon: const Icon(Icons.cleaning_services_rounded, size: 18),
              label: Text(_duplicateCount > 0 ? '중복 정리 ($_duplicateCount)' : '중복 없음'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _duplicateCount > 0 ? AppTheme.errorColor : AppTheme.textSecondaryColor,
                side: BorderSide(
                  color: _duplicateCount > 0 ? AppTheme.errorColor : AppTheme.textLightColor,
                ),
                padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingS),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 내 단어 정복률 ====================

  Widget _buildLearningProgress() {
    final untested = _learningStats['untested'] ?? 0;
    final learning = _learningStats['learning'] ?? 0;
    final mastered = _learningStats['mastered'] ?? 0;
    final total = untested + learning + mastered;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart_rounded, color: AppTheme.primaryColor),
                const SizedBox(width: AppTheme.paddingS),
                Text('내 단어 정복률', style: AppTheme.headingSmall),
                const Spacer(),
                if (total > 0)
                  Text(
                    '${(mastered / total * 100).toStringAsFixed(0)}% 정복',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingM),
            // 색상 바
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
              child: SizedBox(
                height: 16,
                child: total == 0
                    ? Container(color: AppTheme.surfaceColor)
                    : Row(
                        children: [
                          if (mastered > 0)
                            Flexible(
                              flex: mastered,
                              child: Container(color: AppTheme.primaryColor),
                            ),
                          if (learning > 0)
                            Flexible(
                              flex: learning,
                              child: Container(color: AppTheme.warningColor),
                            ),
                          if (untested > 0)
                            Flexible(
                              flex: untested,
                              child: Container(color: AppTheme.surfaceColor),
                            ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppTheme.paddingM),
            // 범례
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('완전정복', mastered, AppTheme.primaryColor),
                _buildLegendItem('학습중', learning, AppTheme.warningColor),
                _buildLegendItem('미학습', untested, AppTheme.textLightColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Text(label, style: AppTheme.caption),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '$count개',
          style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ==================== 요주의 단어 ====================

  Widget _buildWeakWords() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor),
                const SizedBox(width: AppTheme.paddingS),
                Text('요주의 단어', style: AppTheme.headingSmall),
                const Spacer(),
                if (_weakWords.length >= 4)
                  TextButton.icon(
                    onPressed: _startReviewQuiz,
                    icon: const Icon(Icons.replay_rounded, size: 16),
                    label: const Text('복습 퀴즈'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.warningColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingS,
                        vertical: AppTheme.paddingXS,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingS),
            if (_weakWords.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingM),
                child: Center(
                  child: Text(
                    '틀린 단어가 없어요! 계속 열심히 하세요.',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textLightColor),
                  ),
                ),
              )
            else
              ...List.generate(_weakWords.length, (i) {
                final word = _weakWords[i];
                final accuracy = word.tryCount > 0
                    ? (word.correctCount / word.tryCount * 100).toStringAsFixed(0)
                    : '0';
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingS),
                  decoration: BoxDecoration(
                    border: i < _weakWords.length - 1
                        ? Border(bottom: BorderSide(color: AppTheme.surfaceColor))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${i + 1}',
                          style: AppTheme.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.paddingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              word.word,
                              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              word.meaning,
                              style: AppTheme.caption,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$accuracy%',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('${word.tryCount}번 시도', style: AppTheme.caption),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _startReviewQuiz() async {
    if (_weakWords.length < 4) return;
    final quizProvider = context.read<QuizProvider>();
    final count = _weakWords.length.clamp(4, AppConstants.maxQuizWords);
    final success = await quizProvider.generateQuiz(
      words: _weakWords,
      questionCount: count,
      quizType: QuizType.wordToMeaning,
    );
    if (success && mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizScreen()));
    }
  }

  // ==================== 7일 학습 기록 ====================

  Widget _buildStudyCalendar() {
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final maxCount = _studyCalendar.values.isEmpty
        ? 1
        : _studyCalendar.values.reduce((a, b) => a > b ? a : b).clamp(1, 999);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryColor),
                const SizedBox(width: AppTheme.paddingS),
                Text('7일 학습 기록', style: AppTheme.headingSmall),
              ],
            ),
            const SizedBox(height: AppTheme.paddingM),
            SizedBox(
              height: 90,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: days.map((day) {
                  final key =
                      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                  final count = _studyCalendar[key] ?? 0;
                  final ratio = count == 0 ? 0.04 : (count / maxCount).clamp(0.1, 1.0);
                  final isToday = day.year == now.year &&
                      day.month == now.month &&
                      day.day == now.day;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (count > 0)
                            Text(
                              '$count',
                              style: AppTheme.caption.copyWith(fontSize: 9),
                            )
                          else
                            const SizedBox(height: 12),
                          const SizedBox(height: 2),
                          Flexible(
                            child: FractionallySizedBox(
                              heightFactor: ratio,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? AppTheme.primaryColor
                                      : count > 0
                                          ? AppTheme.primaryColor.withValues(alpha: 0.45)
                                          : AppTheme.surfaceColor,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppTheme.paddingS),
            Row(
              children: days.map((day) {
                final isToday = day.year == now.year &&
                    day.month == now.month &&
                    day.day == now.day;
                const dayNames = ['월', '화', '수', '목', '금', '토', '일'];
                final dayName = dayNames[day.weekday - 1];
                return Expanded(
                  child: Text(
                    isToday ? '오늘' : dayName,
                    style: AppTheme.caption.copyWith(
                      fontSize: 9,
                      color: isToday ? AppTheme.primaryColor : null,
                      fontWeight: isToday ? FontWeight.bold : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== API 불러오기 ====================

  static const String _allTopicsKey = '전체';
  static const List<String> _presetTopics = [
    '가족', '학교', '동물', '음식', '자연', '몸', '집', '날씨', '색깔', '숫자',
    '직업', '교통', '감정', '운동', '나라',
  ];

  void _showApiImportDialog() {
    String selectedTopic = _allTopicsKey;
    int selectedDifficulty = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text(
            '국립국어원 단어 동기화',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('주제', style: AppTheme.bodySmall),
              const SizedBox(height: AppTheme.paddingS),
              DropdownButtonFormField<String>(
                initialValue: selectedTopic,
                decoration: const InputDecoration(isDense: true),
                items: [
                  const DropdownMenuItem(
                    value: _allTopicsKey,
                    child: Text('전체 (모든 주제 일괄 동기화)'),
                  ),
                  ..._presetTopics
                      .map((t) => DropdownMenuItem(value: t, child: Text(t))),
                ],
                onChanged: (v) => setDialogState(() => selectedTopic = v!),
              ),
              if (selectedTopic == _allTopicsKey) ...[
                const SizedBox(height: AppTheme.paddingS),
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingS),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    '${_presetTopics.length}개 주제를 순서대로 호출합니다.\n시간이 걸릴 수 있습니다.',
                    style: AppTheme.caption.copyWith(color: AppTheme.primaryColor),
                  ),
                ),
              ],
              if (selectedTopic != _allTopicsKey) ...[
                const SizedBox(height: AppTheme.paddingM),
                const Text('난이도', style: AppTheme.bodySmall),
                const SizedBox(height: AppTheme.paddingS),
                DropdownButtonFormField<int>(
                  value: selectedDifficulty,
                  decoration: const InputDecoration(isDense: true),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('쉬움')),
                    DropdownMenuItem(value: 2, child: Text('보통')),
                    DropdownMenuItem(value: 3, child: Text('어려움')),
                  ],
                  onChanged: (v) => setDialogState(() => selectedDifficulty = v!),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _importWords(
                  selectedTopic,
                  selectedTopic == _allTopicsKey ? 1 : selectedDifficulty,
                );
              },
              child: const Text('동기화'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importWords(String query, int target) async {
    final provider = context.read<WordProvider>();

    if (query == _allTopicsKey) {
      final progressNotifier = ValueNotifier<String>('준비 중...');

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('전체 동기화 중'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppTheme.paddingM),
              ValueListenableBuilder<String>(
                valueListenable: progressNotifier,
                builder: (_, text, __) => Text(text, style: AppTheme.bodySmall),
              ),
            ],
          ),
        ),
      );

      final saved = await provider.fetchAllWordsFromApi(
        topics: _presetTopics,
        target: target,
        onProgress: (topic, current, total) {
          progressNotifier.value = '$topic ($current / $total)';
        },
      );

      progressNotifier.dispose();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('전체 동기화 완료! $saved개 단어 추가됨')),
      );
      await _loadStats();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('\'$query\' 단어 동기화 중...'),
          duration: const Duration(seconds: 30),
        ),
      );

      final saved = await provider.fetchWordsFromApi(query: query, target: target);

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!), backgroundColor: AppTheme.errorColor),
        );
        provider.clearError();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$saved개 단어를 새로 추가했습니다!')),
        );
        await _loadStats();
      }
    }
  }

  // ==================== 중복 정리 ====================

  void _confirmRemoveDuplicates() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('중복 단어 정리'),
        content: Text('중복된 단어 $_duplicateCount개를 삭제하시겠습니까?\n각 단어에서 처음 등록된 것만 남깁니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<WordProvider>();
              final deleted = await provider.removeDuplicates();
              if (!mounted) return;
              await _loadStats();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$deleted개 중복 단어를 삭제했습니다.')),
              );
            },
            child: const Text('삭제', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }

  // ==================== 단어 추가 ====================

  void _navigateToAddWord() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WordFormScreen()),
    );
    if (result == true && mounted) {
      await _loadStats();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppMessages.wordAdded)),
      );
    }
  }
}
