
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../const/const_colors.dart';
import '../../models/dictionaries_items/dictionary_item_model.dart';

class CustomDictionaryDropdown extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final List<DictionaryItem> items;

  /// Начальное значение (например при редактировании тикета)
  final DictionaryItem? initialValue;

  /// Если true и initialValue не задан — попробует подставить значение
  /// автоматически (см. _resolveDefault)
  final bool autoSelectDefault;

  /// Кастомная логика выбора дефолтного значения (например "стандартный режим")
  final DictionaryItem? Function(List<DictionaryItem> items)? defaultResolver;

  final void Function(DictionaryItem item)? onSelected;

  const CustomDictionaryDropdown({
    super.key,
    required this.hintText,
    required this.icon,
    required this.items,
    this.initialValue,
    this.autoSelectDefault = false,
    this.defaultResolver,
    this.onSelected,
  });

  @override
  State<CustomDictionaryDropdown> createState() =>
      _CustomDictionaryDropdownState();
}

class _CustomDictionaryDropdownState extends State<CustomDictionaryDropdown> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  final ValueNotifier<bool> _isOpenNotifier = ValueNotifier(false);
  final ValueNotifier<List<DictionaryItem>> _filteredNotifier =
  ValueNotifier([]);

  DictionaryItem? _selected;

  @override
  void initState() {
    super.initState();
    _filteredNotifier.value = widget.items;

    if (widget.initialValue != null) {
      _select(widget.initialValue!, notify: false);
    } else if (widget.autoSelectDefault) {
      final def = widget.defaultResolver?.call(widget.items) ??
          _defaultActiveResolver(widget.items);
      if (def != null) {
        _select(def, notify: false);
      }
    }

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        if (_selected != null) {
          _controller.text = _selected!.name;
        } else {
          _controller.clear();
        }
        _hideOverlay();
      }
    });
  }


  @override
  void didUpdateWidget(covariant CustomDictionaryDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Список справочника обновился (например, пришёл с сервера) —
    // обновляем то, что показываем в overlay.
    if (!identical(widget.items, oldWidget.items)) {
      _filteredNotifier.value = widget.items;
    }

    // initialValue изменился (например, тикет подгрузился позже,
    // чем был создан сам dropdown) — подставляем/сбрасываем значение.
    if (widget.initialValue != oldWidget.initialValue) {
      if (widget.initialValue != null) {
        _select(widget.initialValue!, notify: false);
      } else {
        _clear();
      }
      return;
    }

    // initialValue не задан, но раньше не было из чего выбрать дефолт
    // (items были пустые), а теперь они появились.
    if (_selected == null &&
        !identical(widget.items, oldWidget.items) &&
        widget.items.isNotEmpty) {
      if (widget.initialValue != null) {
        _select(widget.initialValue!, notify: false);
      } else if (widget.autoSelectDefault) {
        final def = widget.defaultResolver?.call(widget.items) ??
            _defaultActiveResolver(widget.items);
        if (def != null) {
          _select(def, notify: false);
        }
      }
    }
  }

  /// Дефолт "из коробки": если ровно один active-элемент — берём его.
  /// Замените на свою логику через defaultResolver, если правило другое.
  DictionaryItem? _defaultActiveResolver(List<DictionaryItem> items) {
    final activeOnes = items.where((e) => e.active).toList();
    if (activeOnes.length == 1) return activeOnes.first;
    return null;
  }



  @override
  void dispose() {
    _hideOverlay();
    _controller.dispose();
    _focusNode.dispose();
    _isOpenNotifier.dispose();
    _filteredNotifier.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    _hideOverlay();
    super.deactivate();
  }

  void _onTextChanged(String value) {
    final query = value.trim().toLowerCase();
    if (query.isEmpty) {
      _filteredNotifier.value = widget.items;
    } else {
      _filteredNotifier.value = widget.items
          .where((e) => e.name.toLowerCase().contains(query))
          .toList();
    }
    _showOverlay();
  }

  void _showOverlay() {
    _hideOverlay();

    final RenderBox renderBox =
    _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      canSizeOverlay: true,
      builder: (context) => Positioned(
        top: position.dy + size.height,
        left: position.dx,
        width: size.width,
        child: TextFieldTapRegion(
          child: Material(
            type: MaterialType.transparency,
            child: ValueListenableBuilder<List<DictionaryItem>>(
              valueListenable: _filteredNotifier,
              builder: (context, list, _) {
                if (list.isEmpty) {
                  return _DictDropdownContainer(
                    child: Padding(
                      padding: EdgeInsets.all(14.h),
                      child: Text(
                        'Nimic găsit',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  );
                }
                return _DictDropdownContainer(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 200.h),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                          Divider(thickness: 1.h, color: AppColors.textTitleFl),
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return _DictTile(
                          item: item,
                          onTap: () => _select(item),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isOpenNotifier.value = true;
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpenNotifier.value = false;
  }

  void _select(DictionaryItem item, {bool notify = true}) {
    setState(() {
      _selected = item;
      _controller.text = item.name;
    });
    _hideOverlay();
    _focusNode.unfocus();
    if (notify) widget.onSelected?.call(item);
  }

  void _clear() {
    setState(() {
      _selected = null;
      _controller.clear();
    });
    _filteredNotifier.value = widget.items;
    _hideOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isOpenNotifier,
      builder: (context, isOpen, child) {
        return Container(
          key: _fieldKey,
          alignment: Alignment.center,
          height: 32.h,
          decoration: BoxDecoration(
            color: AppColors.backgroundCardColor,
            borderRadius: isOpen
                ? BorderRadius.only(
              topLeft: Radius.circular(10.r),
              topRight: Radius.circular(10.r),
            )
                : BorderRadius.circular(100.r),
            border: Border(
              top: BorderSide(color: AppColors.textTitleFl, width: 1.w),
              left: BorderSide(color: AppColors.textTitleFl, width: 1.w),
              right: BorderSide(color: AppColors.textTitleFl, width: 1.w),
              bottom: isOpen
                  ? BorderSide.none
                  : BorderSide(color: AppColors.textTitleFl, width: 1.w),
            ),
          ),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Icon(widget.icon, size: 20.sp, color: AppColors.hintTextColor),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onTextChanged,
              onTap: () {
                if (_overlayEntry == null) {
                  _filteredNotifier.value = widget.items;
                  _showOverlay();
                }
              },
              style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black87),
              decoration: InputDecoration(
                isCollapsed: true,
                hintText: widget.hintText,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: AppColors.textColorOne,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: _clear,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Icon(Icons.close, size: 18.sp, color: Colors.grey.shade400),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DictDropdownContainer extends StatelessWidget {
  final Widget child;
  const _DictDropdownContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.backgroundCardColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10.r),
          bottomRight: Radius.circular(10.r),
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.textTitleFl, width: 1.w),
          left: BorderSide(color: AppColors.textTitleFl, width: 1.w),
          right: BorderSide(color: AppColors.textTitleFl, width: 1.w),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DictTile extends StatelessWidget {
  final DictionaryItem item;
  final VoidCallback onTap;

  const _DictTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.name,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: item.active ? Colors.green.shade50 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                item.active ? 'Activ' : 'Inactiv',
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: item.active ? Colors.green.shade600 : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}