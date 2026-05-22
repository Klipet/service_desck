import 'package:flutter/material.dart';
class NavigationProvider extends ChangeNotifier {
  int _currentPageIndex = 0;
  Map<String, dynamic> _pageData = {};
  PageController? _pageController;
  int? _ticketId;

  Function(int oldIndex, int newIndex)? onIndexChanged;
  int? get ticketId => _ticketId; // геттер для доступа снаружи
  int get currentPageIndex => _currentPageIndex;

  // Установить PageController
  void setPageController(PageController controller) {
    _pageController = controller;
  }

  /// Переход на страницу
  void goToPage(int index) {
    print('🔄 $currentPageIndex $index');
    if (_currentPageIndex == 8) {
      print('🔄 Переход на страницу $_currentPageIndex');
      onIndexChanged?.call(_currentPageIndex, index);
    }
    if (_currentPageIndex != index) {
      _currentPageIndex = index;

      // ✅ Единственное изменение — проверка hasClients
      if (_pageController != null && _pageController!.hasClients) {
        _pageController!.jumpToPage(index);
      }

      FocusManager.instance.primaryFocus?.unfocus();
    }

    notifyListeners();
  }

  /// Переход на страницу с передачей данных
  void goToPageAndDestroy(int index, {int? ticketId}) {
    _ticketId = ticketId;
    _currentPageIndex = index;
    if (_pageController != null && _pageController!.hasClients) {
      _pageController!.jumpToPage(index);
    }
    notifyListeners();
  }


  /// Переход на страницу с передачей данных
  void goToPageAndSave(int index, {Map<String, dynamic>? data}) {
    print('📤 Переход на страницу $index с данными: $data');
    if (data != null) {
      _pageData = data;
    }
    _currentPageIndex = index;
    if (_pageController != null && _pageController!.hasClients) {
      _pageController!.jumpToPage(index);
    }
    notifyListeners();
  }

  /// Обновить текущий индекс (вызывается из onPageChanged)
  void updatePageIndex(int index) {
    print('updatePageIndex $currentPageIndex $index');
    if (_currentPageIndex != index) {
      _currentPageIndex = index;
      notifyListeners();
    }
  }


  void goToTicketDetail() {
    _ticketId = null;
    goToPageAndDestroy(2); // номер страницы TicketDetailPage
  }


  /// Получить данные страницы
  T? getPageData<T>(String key) {
    final value = _pageData[key];
    return value as T?;
  }

  /// Очистить данные страницы
  void clearPageData() {
    _pageData.clear();
  }

  void reset() {
    _currentPageIndex = 0;
    _pageData = {};
    _pageController = null;
    notifyListeners();
  }

  @override
  void dispose() {
    print('Удалил страницу');
    _pageController = null;
    super.dispose();
  }
}
