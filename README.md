# Feature #2 — 이어읽기 플로우 + 타이머/기록 바텀시트

## 요약
- **서재 카드 탭 → 이어읽기 진입** 플로우를 정리하고,
- **타이머(시작/중단)** + **중단 시 기록 바텀시트(읽은 페이지 입력/메모)** 를 추가.
- 이후 **진행률 = (입력 페이지 / 총 페이지)** 로 연동할 준비까지 완료.

---

## 변경 사항(파일)

### 신규
- `lib/features/reading/application/reading_timer_view_model.dart`  
  - 1초 간격 타이머. `start() / pause() / reset()` 제공, `elapsed` 노출.
- `lib/pages/reading/widgets/reading_timer_card.dart`  
  - 타이머 UI 카드. ▶︎/⏸ 토글, 시작 시 안내 다이얼로그, **중단 시 기록 시트 호출**.
  - API:  
    ```dart
    ReadingTimerCard({
      int? initialPage,
      int? totalPages,
      void Function(Duration elapsed, int? page, String? memo)? onSaved,
    })
    ```
- `lib/pages/reading/widgets/reading_log_sheet.dart`  
  - **중단 시 표시되는 바텀시트**. 기록 시간 표시, **읽은 페이지 입력**, 선택 메모 입력.
  - `ReadingLogSheet.show(...) → Future<ReadingLogResult?>`

> (선택) `lib/pages/reading/widgets/open_reading_sheet.dart`  
> - 서재에서 이어읽기 진입 전 “계속하기/뒤로가기” 확인 시트가 필요할 때 사용.

###  수정
- `lib/pages/reading/widgets/reading_detail_view.dart`
  - 페이지 헤더 중복 제거(헤더는 `ReadingPage`에서만).
  - 타이머 박스 → **`ReadingTimerCard`** 로 교체.
  - 예시 연결:
    ```dart
    ReadingTimerCard(
      initialPage: session.lastPage,
      totalPages: session.totalPages,
      onSaved: (elapsed, page, memo) {
        // TODO: 저장/진행률 업데이트
        final progress = (page ?? 0) / (session.totalPages ?? 1);
        // vm.open(session.copyWith(progress: progress, lastPage: page)); 등으로 연동
      },
    )
    ```
- `lib/pages/library/widgets/library_grid.dart`
  - 카드 탭 시 `ReadingSession.fromBook(book)` 열고 탭 전환(`TabNav.I.go(0)`).
  - (필요 시) 진입 전 확인 시트 띄우는 로직 연결 가능.
- `lib/features/reading/application/reading_view_model.dart`
  - `open(ReadingSession)` / `clear()` 추가로 세션 상태 관리.
- `lib/features/reading/domain/reading_session.dart`
  - `fromBook(Book)` 팩토리, `totalPages` 게터.

---

## 동작 흐름

```text
서재 카드 탭
  └─ (선택) 이어읽기 확인 시트
      └─ 계속하기 → ReadingViewModel.open(session)
           └─ 탭 전환(TabNav.I.go(0)) → ReadingPage
                └─ ReadingDetailView
                     ├─ 진행도 바(세션 기반)
                     └─ ReadingTimerCard
                          ├─ ▶︎ 시작 → "오늘의 독서 기록이 시작되었어요!" 다이얼로그
                          └─ ⏸ 중단 → ReadingLogSheet
                               └─ 완료(page, memo) → onSaved(elapsed, page, memo)
                                    └─ (TODO) 저장/진행률 업데이트
```

---

## TODO / 다음 단계

-  onSaved에서 Repository 저장 및 ReadingSession 업데이트(progress/lastPage).

 진행률: progress = page / totalPages 실시간 반영.

- 총 페이지(pageCount) API 연동 안정화(현재 일부 도서에서 null 발생)
→ Book.pageCount 확보 및 ReadingSession.totalPages로 전달.

- UI 디테일: surfaceVariant 등 경고 해결(최신 Material3 대응).

- 기록 목록(날짜/시간/페이지) 모델링 & 리스트 렌더링.
