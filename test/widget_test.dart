// 한국어 어휘 퀴즈 앱 위젯 테스트
// 기본 앱 실행 테스트

import 'package:flutter_test/flutter_test.dart';

import 'package:korean_vocab_quiz/main.dart';

void main() {
  testWidgets('앱이 정상적으로 실행되는지 테스트', (WidgetTester tester) async {
    // 앱 빌드 및 프레임 트리거
    await tester.pumpWidget(const KoreanVocabQuizApp());

    // 앱 제목이 표시되는지 확인
    expect(find.text('한국어 어휘 퀴즈'), findsOneWidget);
    
    // 개발 중 메시지가 표시되는지 확인
    expect(find.text('앱 개발 중'), findsOneWidget);
  });
}
