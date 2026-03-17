import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'utils/constants.dart';
import 'utils/sample_data.dart';
import 'providers/word_provider.dart';
import 'providers/quiz_provider.dart';
import 'screens/home_screen.dart';

/// 앱의 진입점
void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();
  
  // 세로 방향으로 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // 상태바 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Web용 SQLite 초기화
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // Google Mobile Ads SDK 초기화 (Android/iOS만)
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }

  // 샘플 데이터 초기화
  await SampleData.addSampleData();
  
  runApp(const KoreanVocabQuizApp());
}

/// 앱의 루트 위젯
class KoreanVocabQuizApp extends StatelessWidget {
  const KoreanVocabQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 단어 관리 Provider
        ChangeNotifierProvider(create: (_) => WordProvider()),
        
        // 퀴즈 관리 Provider
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: MaterialApp(
        // 앱 제목
        title: AppConstants.appName,
        
        // 디버그 배너 숨기기
        debugShowCheckedModeBanner: false,
        
        // 테마 설정
        theme: AppTheme.lightTheme,
        
        // 홈 화면
        home: const HomeScreen(),
      ),
    );
  }
}

/// 임시 홈 화면 (나중에 실제 HomeScreen으로 교체됨)
class TemporaryHomePage extends StatelessWidget {
  const TemporaryHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 앱 아이콘 (임시)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: const Icon(
                    AppIcons.quiz,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: AppTheme.paddingXL),
                
                // 앱 제목
                Text(
                  AppConstants.appName,
                  style: AppTheme.headingLarge.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppTheme.paddingS),
                
                // 부제목
                Text(
                  '초등학생을 위한 재미있는 한국어 학습',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppTheme.paddingXL * 2),
                
                // 개발 진행 상태 카드
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingL),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.construction_rounded,
                        size: 48,
                        color: AppTheme.warningColor,
                      ),
                      const SizedBox(height: AppTheme.paddingM),
                      Text(
                        '앱 개발 중',
                        style: AppTheme.headingSmall,
                      ),
                      const SizedBox(height: AppTheme.paddingS),
                      Text(
                        'Phase 1: 프로젝트 설정 완료\n다음: 데이터 모델 구현',
                        style: AppTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppTheme.paddingXL),
                
                // 진행률 표시
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '전체 진행률',
                          style: AppTheme.bodySmall,
                        ),
                        Text(
                          '12%',
                          style: AppTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingS),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      child: LinearProgressIndicator(
                        value: 0.12,
                        minHeight: 8,
                        backgroundColor: AppTheme.surfaceColor,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
