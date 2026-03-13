import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../models/word.dart';
import '../utils/constants.dart';
import 'word_form_screen.dart';

/// 단어 목록 화면
class WordListScreen extends StatefulWidget {
  const WordListScreen({super.key});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('단어 목록'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.add),
            onPressed: () => _navigateToAddWord(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 검색 및 필터
          _buildSearchAndFilter(),
          
          // 단어 목록
          Expanded(
            child: Consumer<WordProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.words.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.paddingM),
                  itemCount: provider.words.length,
                  itemBuilder: (context, index) {
                    final word = provider.words[index];
                    return _buildWordCard(word);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 검색 및 필터
  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingM),
      color: AppTheme.cardColor,
      child: Column(
        children: [
          // 검색창
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '단어 또는 의미 검색',
              prefixIcon: const Icon(AppIcons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(AppIcons.close),
                      onPressed: () {
                        _searchController.clear();
                        context.read<WordProvider>().clearSearch();
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              context.read<WordProvider>().setSearchQuery(value);
            },
          ),
          
          const SizedBox(height: AppTheme.paddingM),
          
          // 난이도 필터
          Consumer<WordProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  const Text('난이도: ', style: AppTheme.bodyMedium),
                  const SizedBox(width: AppTheme.paddingS),
                  Expanded(
                    child: Wrap(
                      spacing: AppTheme.paddingS,
                      children: [
                        _buildFilterChip('전체', 0, provider.difficultyFilter),
                        _buildFilterChip('쉬움', 1, provider.difficultyFilter),
                        _buildFilterChip('보통', 2, provider.difficultyFilter),
                        _buildFilterChip('어려움', 3, provider.difficultyFilter),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// 필터 칩
  Widget _buildFilterChip(String label, int value, int currentValue) {
    final isSelected = value == currentValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        context.read<WordProvider>().setDifficultyFilter(value);
      },
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.3),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  /// 단어 카드
  Widget _buildWordCard(Word word) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingM),
      child: InkWell(
        onTap: () => _navigateToEditWord(word),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      word.word,
                      style: AppTheme.headingSmall,
                    ),
                  ),
                  _buildDifficultyBadge(word.difficulty),
                  const SizedBox(width: AppTheme.paddingS),
                  IconButton(
                    icon: const Icon(AppIcons.delete, color: AppTheme.errorColor),
                    onPressed: () => _confirmDelete(word),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingS),
              Text(
                word.meaning,
                style: AppTheme.bodyMedium,
              ),
              if (word.example != null && word.example!.isNotEmpty) ...[
                const SizedBox(height: AppTheme.paddingS),
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingS),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: Text(
                    '예: ${word.example}',
                    style: AppTheme.bodySmall,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 난이도 배지
  Widget _buildDifficultyBadge(int difficulty) {
    Color color;
    switch (difficulty) {
      case 1:
        color = AppTheme.successColor;
        break;
      case 2:
        color = AppTheme.warningColor;
        break;
      case 3:
        color = AppTheme.errorColor;
        break;
      default:
        color = AppTheme.textSecondaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingS,
        vertical: AppTheme.paddingXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Text(
        Word(word: '', meaning: '', difficulty: difficulty).difficultyText,
        style: AppTheme.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.wordList,
            size: 80,
            color: AppTheme.textLightColor,
          ),
          const SizedBox(height: AppTheme.paddingL),
          Text(
            AppMessages.noWordsYet,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.paddingL),
          ElevatedButton.icon(
            onPressed: _navigateToAddWord,
            icon: const Icon(AppIcons.add),
            label: const Text('단어 추가하기'),
          ),
        ],
      ),
    );
  }

  /// 단어 추가 화면으로 이동
  void _navigateToAddWord() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WordFormScreen()),
    );
    
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppMessages.wordAdded)),
      );
    }
  }

  /// 단어 수정 화면으로 이동
  void _navigateToEditWord(Word word) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WordFormScreen(word: word)),
    );
    
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppMessages.wordUpdated)),
      );
    }
  }

  /// 삭제 확인
  void _confirmDelete(Word word) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('단어 삭제'),
        content: Text('\'${word.word}\'를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final provider = context.read<WordProvider>();
              
              navigator.pop();
              final success = await provider.deleteWord(word.id!);
              if (success && mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text(AppMessages.wordDeleted)),
                );
              }
            },
            child: const Text('삭제', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}
