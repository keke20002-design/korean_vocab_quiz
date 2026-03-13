import 'package:flutter/material.dart';

/// 앱 전체에서 사용되는 상수 및 테마 설정
class AppConstants {
  // 앱 정보
  static const String appName = '한국어 어휘 퀴즈';
  static const String appVersion = '1.0.0';

  // 데이터베이스
  static const String databaseName = 'korean_vocab_quiz.db';
  static const int databaseVersion = 1;

  // 테이블 이름
  static const String wordsTable = 'words';
  static const String quizResultsTable = 'quiz_results';

  // 퀴즈 설정
  static const int minQuizWords = 5;
  static const int maxQuizWords = 20;
  static const int defaultQuizWords = 10;
  static const int quizTimeLimit = 60; // 초 단위 (선택사항)

  // 애니메이션 시간
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

/// 앱 테마 설정
class AppTheme {
  // 기본 색상 팔레트 (70-25-5 파스텔 법칙 - 초등학생 대상)
  static const Color primaryColor = Color(0xFF10B981); // 차분한 초록 (포인트 5%)
  static const Color secondaryColor = Color(0xFF059669); // 짙은 초록 (텍스트/아이콘)
  static const Color accentColor = Color(0xFFF97316); // 주황 포인트 (강조 5%)
  static const Color successColor = Color(0xFF10B981); // 초록색
  static const Color errorColor = Color(0xFFFF6B6B); // 빨간색
  static const Color warningColor = Color(0xFFF97316); // 주황색

  // 배경 색상 (70% - 거의 흰색/매우 연한 회색)
  static const Color backgroundColor = Color(0xFFF9FAFB); // 아주 연한 회색/흰색
  static const Color cardColor = Colors.white;
  static const Color surfaceColor = Color(0xFFF5F5F5);

  // 텍스트 색상
  static const Color textPrimaryColor = Color(0xFF2D3436);
  static const Color textSecondaryColor = Color(0xFF636E72);
  static const Color textLightColor = Color(0xFFB2BEC3);

  // 그라데이션 (25% 메인 영역 - 은은한 파스텔)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [errorColor, Color(0xFFFF9999)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 간격 및 패딩
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // 테두리 반경
  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 24.0;

  // 그림자
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // 텍스트 스타일
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    height: 1.2,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
    height: 1.3,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
    height: 1.5,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
    height: 1.4,
  );

  /// 라이트 테마 데이터
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      error: errorColor,
      onError: Colors.white,
      surface: cardColor,
      onSurface: textPrimaryColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    
    // AppBar 테마
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: textPrimaryColor,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
    ),

    // Card 테마
    cardTheme: CardThemeData(
      elevation: 3,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXL),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.1),
    ),

    // ElevatedButton 테마 (5% 포인트 - 핵심 버튼만 강한 색)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(
          horizontal: paddingL,
          vertical: paddingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusL),
        ),
        textStyle: buttonText,
      ),
    ),

    // TextButton 테마
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: paddingM,
          vertical: paddingS,
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // OutlinedButton 테마
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 2),
        padding: const EdgeInsets.symmetric(
          horizontal: paddingL,
          vertical: paddingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusM),
        ),
      ),
    ),

    // InputDecoration 테마
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusM),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: paddingM,
        vertical: paddingM,
      ),
      hintStyle: const TextStyle(color: textLightColor),
    ),

    // FloatingActionButton 테마
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
    ),

    // SnackBar 테마
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimaryColor,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusS),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // Dialog 테마
    dialogTheme: DialogThemeData(
      backgroundColor: cardColor,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusL),
      ),
    ),

    // ProgressIndicator 테마
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: surfaceColor,
    ),

    // 기본 텍스트 테마
    textTheme: const TextTheme(
      displayLarge: headingLarge,
      displayMedium: headingMedium,
      displaySmall: headingSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: buttonText,
      labelSmall: caption,
    ),
  );
}

/// 아이콘 상수
class AppIcons {
  static const IconData home = Icons.home_rounded;
  static const IconData quiz = Icons.quiz_rounded;
  static const IconData wordList = Icons.list_rounded;
  static const IconData add = Icons.add_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_rounded;
  static const IconData check = Icons.check_circle_rounded;
  static const IconData close = Icons.cancel_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData info = Icons.info_rounded;
  static const IconData trophy = Icons.emoji_events_rounded;
  static const IconData star = Icons.star_rounded;
  static const IconData play = Icons.play_arrow_rounded;
  static const IconData refresh = Icons.refresh_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.filter_list_rounded;
  static const IconData sort = Icons.sort_rounded;
  static const IconData back = Icons.arrow_back_rounded;
  static const IconData forward = Icons.arrow_forward_rounded;
}

/// 메시지 상수
class AppMessages {
  // 성공 메시지
  static const String wordAdded = '단어가 추가되었습니다!';
  static const String wordUpdated = '단어가 수정되었습니다!';
  static const String wordDeleted = '단어가 삭제되었습니다!';
  static const String quizCompleted = '퀴즈를 완료했습니다!';

  // 오류 메시지
  static const String errorGeneral = '오류가 발생했습니다. 다시 시도해주세요.';
  static const String errorEmptyField = '모든 항목을 입력해주세요.';
  static const String errorNotEnoughWords = '퀴즈를 시작하려면 최소 5개의 단어가 필요합니다.';
  static const String errorLoadingData = '데이터를 불러오는 중 오류가 발생했습니다.';
  static const String errorSavingData = '데이터를 저장하는 중 오류가 발생했습니다.';

  // 확인 메시지
  static const String confirmDelete = '정말 삭제하시겠습니까?';
  static const String confirmExit = '퀴즈를 종료하시겠습니까?';

  // 안내 메시지
  static const String noWordsYet = '아직 등록된 단어가 없습니다.\n단어를 추가해보세요!';
  static const String noResultsYet = '아직 퀴즈 기록이 없습니다.\n퀴즈를 시작해보세요!';
}
