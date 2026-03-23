import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/quiz_result.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'quiz_setup_screen.dart';

/// 퀴즈 결과 화면
class ResultScreen extends StatefulWidget {
  final QuizResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  static const String _interstitialAdUnitId = 'ca-app-pub-5381891295736795/8861694036';

  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    if (kIsWeb) return;
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  Future<void> _showAdThen(VoidCallback onComplete) async {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          onComplete();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          onComplete();
        },
      );
      await _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      onComplete();
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  QuizResult get result => widget.result;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goToHome(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('퀴즈 결과'),
          leading: IconButton(
            icon: const Icon(AppIcons.close),
            onPressed: () => _goToHome(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 등급 카드
              _buildGradeCard(),
              
              const SizedBox(height: AppTheme.paddingL),
              
              // 점수 카드
              _buildScoreCard(),
              
              const SizedBox(height: AppTheme.paddingL),
              
              // 통계 카드
              _buildStatsCards(),
              
              const SizedBox(height: AppTheme.paddingXL),
              
              // 액션 버튼들
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  /// 등급 카드
  Widget _buildGradeCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingXL),
      decoration: BoxDecoration(
        gradient: _getGradeGradient(result.grade),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            result.gradeMessage,
            style: AppTheme.headingMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppTheme.paddingL),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                result.grade,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.paddingL),
          Text(
            '${result.accuracyPercentage}%',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 점수 카드
  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingL),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreStat(
            '정답',
            '${result.correctAnswers}',
            AppTheme.successColor,
            AppIcons.check,
          ),
          Container(
            width: 1,
            height: 60,
            color: AppTheme.surfaceColor,
          ),
          _buildScoreStat(
            '오답',
            '${result.wrongAnswers}',
            AppTheme.errorColor,
            AppIcons.close,
          ),
          Container(
            width: 1,
            height: 60,
            color: AppTheme.surfaceColor,
          ),
          _buildScoreStat(
            '시간',
            result.formattedTime,
            AppTheme.primaryColor,
            Icons.timer_rounded,
          ),
        ],
      ),
    );
  }

  /// 점수 통계
  Widget _buildScoreStat(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: AppTheme.paddingS),
        Text(
          value,
          style: AppTheme.headingMedium.copyWith(color: color),
        ),
        const SizedBox(height: AppTheme.paddingXS),
        Text(
          label,
          style: AppTheme.bodySmall,
        ),
      ],
    );
  }

  /// 통계 카드들
  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '전체 문제',
            '${result.totalQuestions}개',
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: AppTheme.paddingM),
        Expanded(
          child: _buildStatCard(
            '정답률',
            '${result.accuracyPercentage}%',
            AppTheme.successColor,
          ),
        ),
      ],
    );
  }

  /// 통계 카드
  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingL),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.headingMedium.copyWith(color: color),
          ),
          const SizedBox(height: AppTheme.paddingXS),
          Text(
            label,
            style: AppTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// 액션 버튼들
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: () => _retryQuiz(context),
          icon: const Icon(AppIcons.refresh),
          label: const Text('다시 풀기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingL),
            minimumSize: const Size(double.infinity, 64),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.paddingM),
        OutlinedButton.icon(
          onPressed: () => _goToHome(context),
          icon: const Icon(AppIcons.home),
          label: const Text('홈으로', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingL),
            minimumSize: const Size(double.infinity, 64),
            side: const BorderSide(color: AppTheme.primaryColor, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
          ),
        ),
      ],
    );
  }

  /// 등급에 따른 그라데이션
  Gradient _getGradeGradient(String grade) {
    switch (grade) {
      case 'S':
        return const LinearGradient(
          colors: [Color(0xFF92620A), Color(0xFFB8860B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'A':
        return const LinearGradient(
          colors: [Color(0xFF1B6B3A), Color(0xFF27AE60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'B':
      case 'C':
        return const LinearGradient(
          colors: [Color(0xFFE07B00), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppTheme.errorGradient;
    }
  }

  /// 다시 풀기
  void _retryQuiz(BuildContext context) {
    _showAdThen(() {
      if (!context.mounted) return;
      context.read<QuizProvider>().resetQuiz();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const QuizSetupScreen()),
      );
    });
  }

  /// 홈으로 이동
  void _goToHome(BuildContext context) {
    _showAdThen(() {
      if (!context.mounted) return;
      context.read<QuizProvider>().resetQuiz();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    });
  }
}
