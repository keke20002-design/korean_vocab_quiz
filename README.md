# 한국어 어휘 퀴즈 앱 📚

초등학생을 위한 재미있는 한국어 학습 애플리케이션

## 📱 주요 기능

### 1. 단어 관리
- ✅ 단어 추가, 수정, 삭제
- ✅ 단어 검색 기능
- ✅ 난이도별 필터링 (쉬움/보통/어려움)
- ✅ 예문 포함 가능

### 2. 퀴즈 시스템
- ✅ 두 가지 퀴즈 타입
  - 단어 → 의미 맞추기
  - 의미 → 단어 맞추기
- ✅ 문제 개수 선택 (5~20개)
- ✅ 난이도별 퀴즈 생성
- ✅ 4지선다 문제 자동 생성
- ✅ 실시간 진행률 표시

### 3. 결과 추적
- ✅ 퀴즈 결과 저장
- ✅ 등급 시스템 (S, A, B, C, D, F)
- ✅ 정답률 및 소요 시간 기록
- ✅ 최근 퀴즈 결과 확인

### 4. 사용자 경험
- ✅ 밝고 친근한 디자인
- ✅ 직관적인 인터페이스
- ✅ 부드러운 애니메이션
- ✅ 반응형 레이아웃

## 🏗️ 기술 스택

- **Framework**: Flutter
- **언어**: Dart
- **상태 관리**: Provider
- **데이터베이스**: SQLite (sqflite)
- **아키텍처**: MVVM 패턴

## 📂 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   ├── word.dart            # 단어 모델
│   ├── quiz.dart            # 퀴즈 모델
│   └── quiz_result.dart     # 퀴즈 결과 모델
├── providers/                # 상태 관리
│   ├── word_provider.dart   # 단어 상태 관리
│   └── quiz_provider.dart   # 퀴즈 상태 관리
├── screens/                  # 화면
│   ├── home_screen.dart     # 홈 화면
│   ├── word_list_screen.dart    # 단어 목록
│   ├── word_form_screen.dart    # 단어 추가/수정
│   ├── quiz_setup_screen.dart   # 퀴즈 설정
│   ├── quiz_screen.dart         # 퀴즈 진행
│   └── result_screen.dart       # 결과 화면
├── services/                 # 서비스
│   └── database_service.dart    # 데이터베이스 서비스
├── utils/                    # 유틸리티
│   ├── constants.dart       # 상수 및 테마
│   └── sample_data.dart     # 샘플 데이터
└── widgets/                  # 재사용 위젯
```

## 🚀 시작하기

### 필수 요구사항
- Flutter SDK (3.10.7 이상)
- Dart SDK

### 설치 및 실행

1. 저장소 클론
```bash
git clone <repository-url>
cd korean_vocab_quiz
```

2. 의존성 설치
```bash
flutter pub get
```

3. 앱 실행
```bash
flutter run
```

## 📊 데이터베이스 스키마

### Words 테이블
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | INTEGER | 기본 키 (자동 증가) |
| word | TEXT | 단어 |
| meaning | TEXT | 의미 |
| example | TEXT | 예문 (선택) |
| difficulty | INTEGER | 난이도 (1-3) |
| createdAt | TEXT | 생성 날짜 |
| updatedAt | TEXT | 수정 날짜 |

### QuizResults 테이블
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | INTEGER | 기본 키 (자동 증가) |
| totalQuestions | INTEGER | 전체 문제 수 |
| correctAnswers | INTEGER | 정답 개수 |
| wrongAnswers | INTEGER | 오답 개수 |
| score | REAL | 점수 (백분율) |
| timeTaken | INTEGER | 소요 시간 (초) |
| completedAt | TEXT | 완료 시간 |
| quizType | TEXT | 퀴즈 타입 |

## 🎨 디자인 시스템

### 색상 팔레트
- **Primary**: #6C63FF (보라색)
- **Secondary**: #FF6584 (핑크색)
- **Accent**: #FFD93D (노란색)
- **Success**: #6BCF7F (초록색)
- **Error**: #FF6B6B (빨간색)
- **Warning**: #FFA726 (주황색)

### 난이도별 색상
- **쉬움**: 초록색
- **보통**: 주황색
- **어려움**: 빨간색

## 📝 샘플 데이터

앱 최초 실행 시 23개의 샘플 단어가 자동으로 추가됩니다:
- 난이도 1 (쉬움): 8개
- 난이도 2 (보통): 7개
- 난이도 3 (어려움): 8개

## 🧪 테스트

코드 분석 실행:
```bash
flutter analyze
```

## 📱 지원 플랫폼

- ✅ Android
- ✅ iOS
- ⚠️ Web (제한적 지원)
- ⚠️ Desktop (제한적 지원)

## 🔄 업데이트 계획

- [ ] 음성 발음 기능
- [ ] 단어장 공유 기능
- [ ] 학습 통계 그래프
- [ ] 다크 모드 지원
- [ ] 오프라인 동기화

## 👨‍💻 개발자

이 프로젝트는 초등학생의 한국어 학습을 돕기 위해 개발되었습니다.

## 📄 라이선스

이 프로젝트는 교육 목적으로 자유롭게 사용할 수 있습니다.

## 🙏 감사의 말

Flutter 커뮤니티와 모든 오픈소스 기여자들에게 감사드립니다.

---

**Made with ❤️ for Korean language learners**
