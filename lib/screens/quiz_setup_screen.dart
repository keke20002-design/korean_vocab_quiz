import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../providers/quiz_provider.dart';
import '../models/quiz.dart';
import '../utils/constants.dart';
import 'quiz_screen.dart';

/// 퀴즈 설정 화면
class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  int _questionCount = AppConstants.defaultQuizWords;
  int _difficultyFilter = 0; // 0: 전체, 1-3: 난이도
  QuizType _quizType = QuizType.wordToMeaning;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('퀴즈 설정'),
      ),
      body: Consumer<WordProvider>(
        builder: (context, wordProvider, child) {
          final availableWords = _difficultyFilter == 0
              ? wordProvider.words
              : wordProvider.words.where((w) => w.difficulty == _difficultyFilter).toList();

          return ListView(
            padding: const EdgeInsets.all(AppTheme.paddingL),
            children: [
              // 퀴즈 타입 선택
              _buildQuizTypeSelector(),
              
              const SizedBox(height: AppTheme.paddingXL),
              
              // 문제 개수 선택
              _buildQuestionCountSelector(availableWords.length),
              
              const SizedBox(height: AppTheme.paddingXL),
              
              // 난이도 선택
              _buildDifficultySelector(wordProvider),
              
              const SizedBox(height: AppTheme.paddingXL),
              
              // 정보 카드
              _buildInfoCard(availableWords.length),

              const SizedBox(height: AppTheme.paddingM),

              // 시작 버튼
              ElevatedButton(
                onPressed: availableWords.length >= AppConstants.minQuizWords && !_isLoading
                    ? () => _startQuiz(availableWords)
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingL),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('퀴즈 시작하기', style: AppTheme.buttonText),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 퀴즈 타입 선택기
  Widget _buildQuizTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('퀴즈 타입', style: AppTheme.headingSmall),
        const SizedBox(height: AppTheme.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildQuizTypeOption(
                QuizType.wordToMeaning,
                '단어 → 의미',
                '단어를 보고 의미 맞추기',
                Icons.arrow_forward_rounded,
              ),
            ),
            const SizedBox(width: AppTheme.paddingM),
            Expanded(
              child: _buildQuizTypeOption(
                QuizType.meaningToWord,
                '의미 → 단어',
                '의미를 보고 단어 맞추기',
                Icons.arrow_back_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 퀴즈 타입 옵션
  Widget _buildQuizTypeOption(QuizType type, String title, String subtitle, IconData icon) {
    final isSelected = _quizType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          _quizType = type;
        });
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingM),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : AppTheme.cardColor,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          boxShadow: isSelected ? AppTheme.buttonShadow : AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
              size: 40,
            ),
            const SizedBox(height: AppTheme.paddingS),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.paddingXS),
            Text(
              subtitle,
              style: AppTheme.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 문제 개수 선택기
  Widget _buildQuestionCountSelector(int maxWords) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('문제 개수', style: AppTheme.headingSmall),
            Text(
              '$_questionCount개',
              style: AppTheme.headingSmall.copyWith(color: AppTheme.primaryColor),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.paddingM),
        Slider(
          value: _questionCount.toDouble(),
          min: AppConstants.minQuizWords.toDouble(),
          max: (maxWords < AppConstants.maxQuizWords ? maxWords.toDouble() : AppConstants.maxQuizWords.toDouble()).clamp(AppConstants.minQuizWords.toDouble(), double.infinity),
          divisions: (maxWords < AppConstants.maxQuizWords ? maxWords - AppConstants.minQuizWords : AppConstants.maxQuizWords - AppConstants.minQuizWords).clamp(0, 1000),
          label: '$_questionCount개',
          onChanged: maxWords >= AppConstants.minQuizWords
              ? (value) {
                  setState(() {
                    _questionCount = value.toInt();
                  });
                }
              : null,
        ),
      ],
    );
  }

  /// 난이도 선택기
  Widget _buildDifficultySelector(WordProvider provider) {
    final counts = provider.wordsCountByDifficulty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('난이도 선택', style: AppTheme.headingSmall),
        const SizedBox(height: AppTheme.paddingM),
        Wrap(
          spacing: AppTheme.paddingM,
          runSpacing: AppTheme.paddingM,
          children: [
            _buildDifficultyChip('전체', 0, provider.totalWords),
            _buildDifficultyChip('쉬움', 1, counts[1] ?? 0),
            _buildDifficultyChip('보통', 2, counts[2] ?? 0),
            _buildDifficultyChip('어려움', 3, counts[3] ?? 0),
          ],
        ),
      ],
    );
  }

  /// 난이도 칩
  Widget _buildDifficultyChip(String label, int value, int count) {
    final isSelected = _difficultyFilter == value;
    
    return FilterChip(
      label: Text('$label ($count개)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _difficultyFilter = value;
          
          // 난이도 변경 시 사용 가능한 단어 수에 맞춰 문제 개수 조정
          final wordProvider = context.read<WordProvider>();
          final availableCount = value == 0
              ? wordProvider.totalWords
              : wordProvider.wordsCountByDifficulty[value] ?? 0;
          
          final maxPossible = availableCount < AppConstants.maxQuizWords 
              ? availableCount 
              : AppConstants.maxQuizWords;
          
          if (_questionCount > maxPossible && maxPossible >= AppConstants.minQuizWords) {
            _questionCount = maxPossible;
          } else if (_questionCount < AppConstants.minQuizWords && maxPossible >= AppConstants.minQuizWords) {
            _questionCount = AppConstants.minQuizWords;
          }
        });
      },
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.3),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  /// 정보 카드
  Widget _buildInfoCard(int availableWords) {
    final canStart = availableWords >= AppConstants.minQuizWords;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingL, vertical: AppTheme.paddingM),
      decoration: BoxDecoration(
        color: canStart ? AppTheme.successColor.withValues(alpha: 0.1) : AppTheme.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: canStart ? AppTheme.successColor : AppTheme.errorColor,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            canStart ? AppIcons.check : AppIcons.info,
            color: canStart ? AppTheme.successColor : AppTheme.errorColor,
            size: 32,
          ),
          const SizedBox(width: AppTheme.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  canStart ? '준비 완료!' : '단어가 부족해요',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: canStart ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                ),
                const SizedBox(height: AppTheme.paddingXS),
                Text(
                  canStart
                      ? '사용 가능한 단어: $availableWords개'
                      : '최소 ${AppConstants.minQuizWords}개의 단어가 필요합니다 (현재: $availableWords개)',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 퀴즈 시작
  Future<void> _startQuiz(List<dynamic> availableWords) async {
    setState(() {
      _isLoading = true;
    });

    final quizProvider = context.read<QuizProvider>();
    final success = await quizProvider.generateQuiz(
      words: availableWords.cast(),
      questionCount: _questionCount,
      quizType: _quizType,
    );

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const QuizScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppMessages.errorGeneral),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
