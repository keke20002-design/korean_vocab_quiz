import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/word_provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';
import 'word_list_screen.dart';
import 'quiz_setup_screen.dart';

/// 홈 화면 - 앱의 메인 화면
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _bannerAdUnitId = 'ca-app-pub-5381891295736795/1661860861';

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WordProvider>().loadWords();
      context.read<QuizProvider>().loadRecentQuizResults(30);
    });
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
          setState(() {
            _isBannerAdLoaded = true;
          });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      bottomNavigationBar: _isBannerAdLoaded && _bannerAd != null
          ? SizedBox(
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 앱바
            _buildAppBar(),
            
            // 메인 컨텐츠
            SliverPadding(
              padding: const EdgeInsets.all(AppTheme.paddingM),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // 기록 카드
                  _buildRecordCard(),
                  const SizedBox(height: AppTheme.paddingL),
                  
                  // 통계 카드
                  _buildStatsCards(),
                  const SizedBox(height: AppTheme.paddingL),
                  
                  // 메인 액션 버튼들
                  _buildMainActions(),
                  const SizedBox(height: AppTheme.paddingL),
                  
                  // 최근 퀴즈 결과
                  _buildRecentResults(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 앱바
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0F2D52),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F2D52), Color(0xFF1A4A7A)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '단어 쏙쏙',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB8C9D9),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '어휘 실력을 테스트해보세요',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '지금 바로 퀴즈에 도전하세요',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFB8C9D9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 연속 학습일 계산
  int _calcStreak(List<dynamic> results) {
    if (results.isEmpty) return 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final dates = results
        .map((r) => DateTime(r.completedAt.year, r.completedAt.month, r.completedAt.day))
        .toSet();

    int streak = 0;
    DateTime check = todayDate;
    while (dates.contains(check)) {
      streak++;
      check = check.subtract(const Duration(days: 1));
    }
    if (streak == 0) {
      check = todayDate.subtract(const Duration(days: 1));
      while (dates.contains(check)) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      }
    }
    return streak;
  }

  /// 기록 카드
  Widget _buildRecordCard() {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        final results = quizProvider.quizResults;
        final bestScore = results.isEmpty
            ? 0
            : results.map((r) => r.accuracyPercentage).reduce((a, b) => a > b ? a : b);
        final streak = _calcStreak(results);

        return Container(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingL, horizontal: AppTheme.paddingL),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2F80ED), Color(0xFF1A6FD6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(
            children: [
              Expanded(child: _buildRecordItem(Icons.emoji_events_rounded, '최고 점수', results.isEmpty ? '-' : '$bestScore점', const Color(0xFFFFD700))),
              Container(width: 1, height: 50, color: Colors.white24),
              Expanded(child: _buildRecordItem(Icons.local_fire_department_rounded, '연속 학습', '$streak일', const Color(0xFFFF7043))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecordItem(IconData icon, String label, String value, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 30),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0x99FFFFFF))),
      ],
    );
  }

  /// 통계 카드들
  Widget _buildStatsCards() {
    return Consumer<WordProvider>(
      builder: (context, wordProvider, child) {
        final counts = wordProvider.wordsCountByDifficulty;
        
        return Row(
          children: [
            Expanded(child: _buildStatCard('Total', '${wordProvider.totalWords}', AppIcons.wordList, const Color(0xFF2F80ED))),
            const SizedBox(width: AppTheme.paddingS),
            Expanded(child: _buildStatCard('Easy', '${counts[1] ?? 0}', AppIcons.star, const Color(0xFF27AE60))),
            const SizedBox(width: AppTheme.paddingS),
            Expanded(child: _buildStatCard('Normal', '${counts[2] ?? 0}', AppIcons.star, const Color(0xFFF59E0B))),
            const SizedBox(width: AppTheme.paddingS),
            Expanded(child: _buildStatCard('Hard', '${counts[3] ?? 0}', AppIcons.star, const Color(0xFFEF4444))),
          ],
        );
      },
    );
  }

  /// 개별 통계 카드
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: AppTheme.cardShadow,
        border: Border(bottom: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF888888)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 메인 액션 버튼들
  Widget _buildMainActions() {
    return Column(
      children: [
        _buildActionButton(
          '퀴즈 시작하기',
          '단어를 선택하고 퀴즈를 풀어보세요',
          AppIcons.play,
          AppTheme.quizGradient,
          AppTheme.quizBlue,
          const Color(0xFFBFDBFE),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QuizSetupScreen()),
          ),
        ),
        const SizedBox(height: AppTheme.paddingM),
        _buildActionButton(
          '단어 관리',
          '단어를 추가하거나 수정해보세요',
          AppIcons.wordList,
          AppTheme.wordsGradient,
          AppTheme.wordsPurple,
          const Color(0xFFDDD6FE),
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WordListScreen()),
          ),
        ),
      ],
    );
  }

  /// 액션 버튼
  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    Gradient gradient,
    Color accentColor,
    Color borderColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusL),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingL),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingM),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Icon(icon, color: accentColor, size: 32),
            ),
            const SizedBox(width: AppTheme.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.headingSmall.copyWith(color: const Color(0xFF111827)),
                  ),
                  const SizedBox(height: AppTheme.paddingXS),
                  Text(
                    subtitle,
                    style: AppTheme.bodySmall.copyWith(color: const Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            Icon(AppIcons.forward, color: accentColor),
          ],
        ),
      ),
    );
  }

  /// 최근 퀴즈 결과
  Widget _buildRecentResults() {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        if (quizProvider.quizResults.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 4, height: 20, decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 8),
                Text('최근 퀴즈 결과', style: AppTheme.headingSmall),
              ],
            ),
            const SizedBox(height: AppTheme.paddingM),
            ...quizProvider.quizResults.take(3).map((result) {
              final gradeColor = _getGradeColor(result.grade);
              final d = result.completedAt;
              final dateStr = '${d.month}/${d.day} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
              return Container(
                margin: const EdgeInsets.only(bottom: AppTheme.paddingM),
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingM, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  boxShadow: AppTheme.cardShadow,
                  border: Border(left: BorderSide(color: gradeColor, width: 4)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: gradeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Center(
                        child: Text(result.grade, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: gradeColor)),
                      ),
                    ),
                    const SizedBox(width: AppTheme.paddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${result.accuracyPercentage}점',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: gradeColor),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${result.correctAnswers}/${result.totalQuestions} 정답 · $dateStr',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(result.formattedTime, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'S':
        return const Color(0xFFB8860B); // 진한 골드 (다크 골드)
      case 'A':
        return const Color(0xFFD4960A); // 황금색
      case 'B':
        return const Color(0xFF2F80ED); // 블루
      case 'C':
        return AppTheme.warningColor;   // 주황
      default:
        return AppTheme.errorColor;     // 빨강
    }
  }
}
