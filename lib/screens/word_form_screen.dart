import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../models/word.dart';
import '../utils/constants.dart';

/// 단어 추가/수정 화면
class WordFormScreen extends StatefulWidget {
  final Word? word; // null이면 추가, 값이 있으면 수정

  const WordFormScreen({super.key, this.word});

  @override
  State<WordFormScreen> createState() => _WordFormScreenState();
}

class _WordFormScreenState extends State<WordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _wordController;
  late TextEditingController _meaningController;
  late TextEditingController _exampleController;
  late int _difficulty;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: widget.word?.word ?? '');
    _meaningController = TextEditingController(text: widget.word?.meaning ?? '');
    _exampleController = TextEditingController(text: widget.word?.example ?? '');
    _difficulty = widget.word?.difficulty ?? 1;
  }

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.word != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? '단어 수정' : '단어 추가'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.paddingL),
          children: [
            // 단어 입력
            TextFormField(
              controller: _wordController,
              decoration: const InputDecoration(
                labelText: '단어',
                hintText: '예: 사과',
                prefixIcon: Icon(Icons.text_fields_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '단어를 입력해주세요';
                }
                return null;
              },
            ),

            const SizedBox(height: AppTheme.paddingL),

            // 의미 입력
            TextFormField(
              controller: _meaningController,
              decoration: const InputDecoration(
                labelText: '의미',
                hintText: '예: 빨갛고 둥근 과일',
                prefixIcon: Icon(Icons.description_rounded),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '의미를 입력해주세요';
                }
                return null;
              },
            ),

            const SizedBox(height: AppTheme.paddingL),

            // 예문 입력 (선택사항)
            TextFormField(
              controller: _exampleController,
              decoration: const InputDecoration(
                labelText: '예문 (선택사항)',
                hintText: '예: 나는 사과를 좋아해요.',
                prefixIcon: Icon(Icons.format_quote_rounded),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: AppTheme.paddingL),

            // 난이도 선택
            _buildDifficultySelector(),

            const SizedBox(height: AppTheme.paddingXL),

            // 저장 버튼
            ElevatedButton(
              onPressed: _isLoading ? null : _saveWord,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingM),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? '수정하기' : '추가하기'),
            ),
          ],
        ),
      ),
    );
  }

  /// 난이도 선택기
  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '난이도',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildDifficultyOption(1, '쉬움', AppTheme.successColor),
            ),
            const SizedBox(width: AppTheme.paddingM),
            Expanded(
              child: _buildDifficultyOption(2, '보통', AppTheme.warningColor),
            ),
            const SizedBox(width: AppTheme.paddingM),
            Expanded(
              child: _buildDifficultyOption(3, '어려움', AppTheme.errorColor),
            ),
          ],
        ),
      ],
    );
  }

  /// 난이도 옵션
  Widget _buildDifficultyOption(int value, String label, Color color) {
    final isSelected = _difficulty == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _difficulty = value;
        });
      },
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingM),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : AppTheme.surfaceColor,
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: Column(
          children: [
            Icon(
              AppIcons.star,
              color: isSelected ? color : AppTheme.textLightColor,
              size: 32,
            ),
            const SizedBox(height: AppTheme.paddingS),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: isSelected ? color : AppTheme.textSecondaryColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 단어 저장
  Future<void> _saveWord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final word = Word(
      id: widget.word?.id,
      word: _wordController.text.trim(),
      meaning: _meaningController.text.trim(),
      example: _exampleController.text.trim().isEmpty 
          ? null 
          : _exampleController.text.trim(),
      difficulty: _difficulty,
    );

    final provider = context.read<WordProvider>();
    bool success;

    if (isEditing) {
      success = await provider.updateWord(word);
    } else {
      success = await provider.addWord(word);
    }

    setState(() {
      _isLoading = false;
    });

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? AppMessages.errorSavingData : AppMessages.errorSavingData,
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
