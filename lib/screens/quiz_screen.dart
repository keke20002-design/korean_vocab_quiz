import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz.dart';
import '../providers/quiz_provider.dart';
import '../utils/constants.dart';
import 'result_screen.dart';

/// 퀴즈 진행 화면
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Timer? _autoAdvanceTimer;

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  void _scheduleAutoAdvance(QuizProvider provider) {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (provider.hasNextQuiz) {
        provider.nextQuiz();
      } else {
        _completeQuiz(context, provider);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _confirmExit(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('퀴즈'),
          leading: IconButton(
            icon: const Icon(AppIcons.close),
            onPressed: () => _confirmExit(context),
          ),
        ),
        body: Consumer<QuizProvider>(
          builder: (context, provider, child) {
            if (provider.currentQuiz == null) {
              return const Center(child: Text('퀴즈를 불러올 수 없습니다.'));
            }

            return Column(
              children: [
                // 진행률 표시
                _buildProgressBar(provider),

                // 퀴즈 내용
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppTheme.paddingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 문제 번호
                        _buildQuestionNumber(provider),

                        const SizedBox(height: AppTheme.paddingL),

                        // 문제
                        _buildQuestion(provider.currentQuiz!),

                        const SizedBox(height: AppTheme.paddingXL),

                        // 선택지
                        _buildOptions(context, provider),

                        const SizedBox(height: AppTheme.paddingXL),

                        // 다음 버튼
                        if (provider.currentQuiz!.isAnswered)
                          _buildNextButton(context, provider),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 진행률 바
  Widget _buildProgressBar(QuizProvider provider) {
    return Container(
      color: AppTheme.cardColor,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingM,
        vertical: AppTheme.paddingS,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '문제 ${provider.currentQuizIndex + 1} / ${provider.totalQuizzes}',
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingS,
                  vertical: AppTheme.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  '✓ ${provider.correctCount}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingS),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
            child: LinearProgressIndicator(
              value: provider.progress,
              minHeight: 5,
              backgroundColor: AppTheme.surfaceColor,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  /// 문제 번호
  Widget _buildQuestionNumber(QuizProvider provider) {
    return Text(
      '문제 ${provider.currentQuizIndex + 1}',
      style: AppTheme.bodyLarge.copyWith(
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// 문제
  Widget _buildQuestion(Quiz quiz) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingXL),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
      ),
      child: Column(
        children: [
          Text(
            quiz.type.description,
            style: AppTheme.bodySmall.copyWith(color: const Color(0xFF059669)),
          ),
          const SizedBox(height: AppTheme.paddingM),
          Text(
            quiz.question,
            style: AppTheme.headingLarge.copyWith(
              color: const Color(0xFF065F46),
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 선택지
  Widget _buildOptions(BuildContext context, QuizProvider provider) {
    final quiz = provider.currentQuiz!;
    
    return Column(
      children: quiz.options.map((option) {
        final isSelected = quiz.userAnswer == option;
        final isCorrect = option == quiz.correctAnswer;
        final showResult = quiz.isAnswered;
        
        Color? backgroundColor;
        Color? borderColor;
        
        if (showResult) {
          if (isCorrect) {
            backgroundColor = AppTheme.successColor.withValues(alpha: 0.2);
            borderColor = AppTheme.successColor;
          } else if (isSelected) {
            backgroundColor = AppTheme.errorColor.withValues(alpha: 0.2);
            borderColor = AppTheme.errorColor;
          }
        } else if (isSelected) {
          backgroundColor = AppTheme.primaryColor.withValues(alpha: 0.1);
          borderColor = AppTheme.primaryColor;
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.paddingM),
          child: InkWell(
            onTap: quiz.isAnswered ? null : () {
                provider.submitAnswer(option);
                _scheduleAutoAdvance(provider);
              },
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingL,
                vertical: AppTheme.paddingM,
              ),
              decoration: BoxDecoration(
                color: backgroundColor ?? AppTheme.cardColor,
                border: Border.all(
                  color: borderColor ?? const Color(0xFFE5E7EB),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  if (showResult && isCorrect)
                    const Icon(AppIcons.check, color: AppTheme.successColor, size: 28)
                  else if (showResult && isSelected)
                    const Icon(AppIcons.close, color: AppTheme.errorColor, size: 28)
                  else
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.textLightColor,
                          width: 2,
                        ),
                        color: isSelected ? AppTheme.primaryColor : null,
                      ),
                    ),
                  const SizedBox(width: AppTheme.paddingL),
                  Expanded(
                    child: Text(
                      option,
                      style: AppTheme.bodyLarge.copyWith(
                        fontSize: 18,
                        fontWeight: isSelected || (showResult && isCorrect)
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 다음 버튼
  Widget _buildNextButton(BuildContext context, QuizProvider provider) {
    final isLastQuestion = !provider.hasNextQuiz;
    
    return ElevatedButton(
      onPressed: () {
        _autoAdvanceTimer?.cancel();
        if (isLastQuestion) {
          _completeQuiz(context, provider);
        } else {
          provider.nextQuiz();
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingL),
      ),
      child: Text(
        isLastQuestion ? '결과 보기' : '다음 문제',
        style: AppTheme.buttonText,
      ),
    );
  }

  /// 퀴즈 완료
  Future<void> _completeQuiz(BuildContext context, QuizProvider provider) async {
    final result = await provider.completeQuiz();
    
    if (result != null && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    }
  }

  /// 종료 확인
  Future<bool> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('퀴즈 종료'),
        content: const Text(AppMessages.confirmExit),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('계속하기'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('종료', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
    
    if (result == true && context.mounted) {
      context.read<QuizProvider>().resetQuiz();
      Navigator.pop(context);
    }
    
    return false;
  }
}
