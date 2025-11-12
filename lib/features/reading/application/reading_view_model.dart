import 'package:flutter/material.dart';

import 'package:bookmark/features/library/domain/library_item.dart';
import 'package:bookmark/features/library/domain/library_item_x.dart'; // .toBook() 확장
import 'package:bookmark/features/library/domain/library_repository.dart';
import 'package:bookmark/features/library/application/page_count_resolver.dart';

import 'package:bookmark/features/reading/domain/entities/reading_session.dart';

/// 이어읽기 화면용 ViewModel
/// - 현재 세션 보유(진행률은 [computedProgress])
/// - 총 페이지 보장(알라딘 LookUp → repo 저장 → 사용자 입력 폴백)
/// - 마지막 읽은 페이지 갱신
class ReadingViewModel extends ChangeNotifier {
  ReadingViewModel(this._repo, this._resolver);

  final LibraryRepository _repo;
  final PageCountResolver _resolver;

  ReadingSession? _current;
  ReadingSession? get current => _current;

  /// 이어읽기 세션이 없는 상태(빈 화면 노출 여부)
  bool get isEmpty => _current == null;

  /// 현재 진행률 (0.0 ~ 1.0)
  double get progress => _current?.computedProgress ?? 0.0;

  /// 초기 로드: 기본은 비어 있는 상태로 시작
  Future<void> load() async {
    _current = null;
    notifyListeners();
  }

  /// 외부에서 선택된 세션을 직접 열기
  void open(ReadingSession session) {
    _current = session;
    notifyListeners();
  }

  /// 라이브러리 카드에서 넘어올 때 Book 기반으로 세션 구성하여 오픈
  /// - [LibraryItem.id]를 isbn13로 간주 (LibraryItem→Book 매핑은 extension 사용)
  /// - pageCount가 있으면 session.totalPagesOverride로 반영
  void openFromLibraryItem(LibraryItem item) {
    final session = ReadingSession.fromBook(item.toBook()).copyWith(
      totalPagesOverride: item.itemPage,
    );
    open(session);
  }

  /// 기존 시그니처 유지
  Future<void> setCurrent(ReadingSession session) async => open(session);

  /// 이어읽기 상태 비우기 (빈 화면으로 전환)
  Future<void> clear() async {
    _current = null;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // 총 페이지 확보 로직 (검색 화면에는 표시하지 않고, 이어읽기/서재에서만 보장)
  // ------------------------------------------------------------------

  /// 이어읽기 진입 시 총 페이지가 없으면 확보해 두는 편의 메서드
  /// - LibraryItem 기준으로 LookUp → repo.updatePageCount → session에도 반영
  /// - 그래도 실패하면 사용자에게 직접 입력받아 repo & session 갱신
  ///
  /// 반환: 최신 LibraryItem (pageCount 반영됨)
  Future<LibraryItem> ensurePageCount(
      BuildContext context,
      LibraryItem item,
      ) async {
    // 1) 이미 보유하면 즉시 반환 + 세션에만 없으면 세션 반영
    if ((item.itemPage ?? 0) > 0) {
      final total = item.itemPage!;
      if (_current != null && (_current!.totalPages ?? 0) <= 0) {
        _current = _current!.withTotalPages(total);
        notifyListeners();
      }
      return item;
    }

    // 2) LookUp 시도 (성공 시 내부적으로 repo.updatePageCount 호출)
    await _resolver.resolveAndReplace(item);

    // 최신 LibraryItem 재조회
    var list = await _repo.getItems();
    var updated = list.firstWhere((e) => e.id == item.id, orElse: () => item);

    if ((updated.itemPage ?? 0) > 0) {
      if (_current != null) {
        _current = _current!.withTotalPages(updated.itemPage!);
        notifyListeners();
      }
      return updated;
    }

    // 3) 사용자 입력 폴백
    //  (lint: use_build_context_synchronously 경고가 있을 수 있음. 필요하면 위젯층에서 다이얼로그를 띄우고 값만 VM에 넘겨주는 구조로 분리)
    final input = await _askPageCount(context, updated.title);
    if (input != null && input > 0) {
      await _repo.updatePageCount(updated.id, input);
      list = await _repo.getItems();
      updated = list.firstWhere((e) => e.id == item.id, orElse: () => updated);

      if (_current != null) {
        _current = _current!.withTotalPages(input);
        notifyListeners();
      }
    }
    return updated;
  }

  // ------------------------------------------------------------------
  // 진행 페이지/진행률 갱신
  // ------------------------------------------------------------------

  /// 현재 세션의 마지막 읽은 페이지 갱신(진행률 자동 재계산)
  Future<void> updateCurrentPage(int page) async {
    if (_current == null) return;
    _current = _current!.withLastPage(page);
    notifyListeners();
  }

  /// (호환용) 외부에서 LibraryItem 기준 진행률이 필요할 때
  /// - 현재 열려있는 세션의 책(id=isbn13)과 동일할 때만 session의 진행률 반환
  double progressOf(LibraryItem item) {
    final cur = _current;
    if (cur == null) return 0.0;
    // LibraryItem.id 를 isbn13로 사용 중 → Book.isbn13과 비교
    if (cur.book.isbn13 == item.id) {
      return cur.computedProgress;
    }
    return 0.0;
  }

  // ------------------------------------------------------------------
  // 사용자 입력 다이얼로그 (총 페이지 폴백)
  // ------------------------------------------------------------------

  Future<int?> _askPageCount(BuildContext context, String title) async {
    final controller = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('총 페이지 수 입력'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '예: 264',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              Navigator.pop(context, v);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
