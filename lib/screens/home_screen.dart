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
      context.read<QuizProvider>().loadRecentQuizResults(5);
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
                  // 환영 메시지
                  _buildWelcomeCard(),
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
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFF9FAFB),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          AppConstants.appName,
          style: AppTheme.headingMedium.copyWith(color: const Color(0xFF111827)),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: Center(
            child: Icon(
              AppIcons.quiz,
              size: 64,
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }

  /// 환영 메시지 카드
  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingL),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.waving_hand_rounded,
            size: 48,
            color: Color(0xFF059669),
          ),
          const SizedBox(width: AppTheme.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '준비됐어?',
                  style: AppTheme.headingSmall.copyWith(color: Color(0xFF111827)),
                ),
                const SizedBox(height: AppTheme.paddingXS),
                Text(
                  '한국어 퀴즈 출발! 😊',
                  style: AppTheme.bodyMedium.copyWith(color: Color(0xFF374151)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 통계 카드들
  Widget _buildStatsCards() {
    return Consumer<WordProvider>(
      builder: (context, wordProvider, child) {
        final counts = wordProvider.wordsCountByDifficulty;
        
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '전체 단어',
                '${wordProvider.totalWords}개',
                AppIcons.wordList,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: AppTheme.paddingM),
            Expanded(
              child: _buildStatCard(
                '쉬움',
                '${counts[1] ?? 0}개',
                AppIcons.star,
                AppTheme.successColor,
              ),
            ),
            const SizedBox(width: AppTheme.paddingM),
            Expanded(
              child: _buildStatCard(
                '보통',
                '${counts[2] ?? 0}개',
                AppIcons.star,
                AppTheme.warningColor,
              ),
            ),
          ],
        );
      },
    );
  }

  /// 개별 통계 카드
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingM),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppTheme.paddingS),
          Text(
            value,
            style: AppTheme.headingSmall.copyWith(color: color),
          ),
          const SizedBox(height: AppTheme.paddingXS),
          Text(
            label,
            style: AppTheme.bodySmall,
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
          AppTheme.primaryGradient,
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
          AppTheme.successGradient,
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
          border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingM),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 32),
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
            const Icon(
              AppIcons.forward,
              color: AppTheme.primaryColor,
            ),
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
            Text(
              '최근 퀴즈 결과',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: AppTheme.paddingM),
            ...quizProvider.quizResults.take(3).map((result) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppTheme.paddingM),
                padding: const EdgeInsets.all(AppTheme.paddingM),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.paddingM),
                      decoration: BoxDecoration(
                        color: _getGradeColor(result.grade).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Text(
                        result.grade,
                        style: AppTheme.headingMedium.copyWith(
                          color: _getGradeColor(result.grade),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.paddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${result.correctAnswers}/${result.totalQuestions} 정답',
                            style: AppTheme.bodyMedium,
                          ),
                          Text(
                            '${result.accuracyPercentage}% · ${result.formattedTime}',
                            style: AppTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
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
      case 'A':
        return AppTheme.successColor;
      case 'B':
      case 'C':
        return AppTheme.warningColor;
      default:
        return AppTheme.errorColor;
    }
  }
}
