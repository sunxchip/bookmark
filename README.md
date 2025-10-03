# Bookmark — 오늘 작업 요약

**알라딘 OpenAPI 연동 → 검색 → 바텀시트로 “내 서재 담기” → 서재 그리드 표시**까지 구현.  
아키텍처는 **MVVM + Clean Architecture**

---

## ✅ 오늘 구현한 것

### 검색 (Search)
- 알라딘 OpenAPI 연동 (`AladinApiService`)
- 키워드 **검색 + 무한 스크롤** (`SearchViewModel.loadMore`)
- 결과 아이템 탭 → **“내 서재 담기” 바텀시트** 진입

### 서재 (Library)
- **그리드 카드 UI**: 표지 확대, **제목 2줄**, 진행도 자리(0%) 포함
- 빈 상태 뷰 / 상단 캡슐 헤더 유지
- 담기 성공 시 **라이브러리 갱신**

### 공용 UI
- **상단 토스트 + 배경 디밍(2초 자동 닫힘)**

### DI / 아키텍처
- `MultiProvider`로 **SearchViewModel**, **LibraryViewModel** 전역 주입
- 임시 **InMemory** 저장소 추가(영속 저장소로 교체 가능 구조)

### Git
- `.gitignore` 정리(빌드/Pods/keystore/env 등 제외)
- 브랜치 전략: `main` / `dev` / `feature/*`


---

## 🧷 DI (전역 Provider) 예시

```dart
// Dart/Flutter
return MultiProvider(
  providers: [
    // Library
    Provider<LibraryRepository>(create: (_) => InMemoryLibraryRepository()),
    ChangeNotifierProvider(create: (ctx) => LibraryViewModel(ctx.read())),

    // Search
    Provider(create: (_) => AladinApiService(const String.fromEnvironment('ALADIN_TTBKEY'))),
    Provider(create: (ctx) => SearchRepositoryImpl(ctx.read())),
    ChangeNotifierProvider(create: (ctx) => SearchViewModel(ctx.read())),
  ],
  child: MaterialApp(theme: AppTheme.dark, home: const HomeShell()),
);
```

영속 저장소(Hive/Isar/SQLite 등)로 바꿀 때는 LibraryRepositoryImpl(dep) DI만 교체

---

## 📌 TODO

- Library 영속 저장소 도입(Hive/Isar/SQLite)

- 읽기 진행도(%) 저장/표시

- 검색 캐시/오프라인 처리

- 오류/네트워크 예외 UX 개선(재시도/스낵바)

- 위젯 테스트 & 뷰모델 단위 테스트
