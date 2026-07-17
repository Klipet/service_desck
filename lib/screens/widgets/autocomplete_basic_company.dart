import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/const/const_colors.dart';

import '../../blocs/company_blocs/company_bloc.dart';
import '../../models/company_model.dart';

class AutocompleteBasicCompany extends StatefulWidget {
  /// Вызывается когда пользователь выбирает компанию из списка
  final void Function(CompanyModel company)? onSelected;

  /// Начальное значение (при редактировании тикета)
  final String? initialValue;

  const AutocompleteBasicCompany({
    super.key,
    this.onSelected,
    this.initialValue,
  });

  @override
  State<AutocompleteBasicCompany> createState() =>
      _AutocompleteBasicCompanyState();
}

class _AutocompleteBasicCompanyState extends State<AutocompleteBasicCompany> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  final ValueNotifier<bool> _isOpenNotifier = ValueNotifier(false);

  final GlobalKey _textFieldKey = GlobalKey();


  Timer? _debounce;
  CompanyModel? _selectedCompany;


  static const Duration _debounceDuration = Duration(milliseconds: 400);
  StreamSubscription? _subscription;
  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _subscription = context.read<CompanyBloc>().stream.listen((state) {
        if (state is CompanyLoaded) {
          final company = state.companies.first;

          setState(() {
            _selectedCompany = company;
            _controller.text = company.name;
            widget.onSelected?.call(company);
          });
        }
      });
      // запускаем поиск
      context.read<CompanyBloc>().add(
        SearchCompanyEvent(widget.initialValue ?? ''),
      );
    }

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
          if (_selectedCompany != null) {
            _controller.text = _selectedCompany!.name;
          } else {
            _controller.clear();
          }
       //   setState(() => _showDropdown = false);
      } else {
        if (_controller.text.isNotEmpty) {
       //   setState(() => _showDropdown = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _hideOverlay();
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _isOpenNotifier.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void deactivate() {
    _hideOverlay();
    super.deactivate();
  }

  void _onTextChanged(String value, {
  bool showOverlay = true,
  }) {
    _debounce?.cancel();

    _debounce = Timer(_debounceDuration, () {
      if (value.trim().isNotEmpty) {
        context.read<CompanyBloc>().add(SearchCompanyEvent(value.trim()));
        if (showOverlay) {
          _showOverlay();
        }else {
          _selectedCompany = _selectedCompany;
          _controller.text = _selectedCompany?.name ?? '';
        }
      } else {
        context.read<CompanyBloc>().add(ClearCompanyEvent());
        _hideOverlay();
      }
    });
  }

  void _showOverlay() {
    _hideOverlay();
    final bloc = context.read<CompanyBloc>(); // сохраняем bloc здесь

    // получаем позицию TextField
    final RenderBox renderBox = _textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
        canSizeOverlay: true,
      builder: (context) => Positioned(
        top: position.dy + size.height, // прямо под TextField
        left: position.dx,
          width: renderBox.size.width,
        height: 32.h,
        child: BlocProvider.value(
          value: bloc, // передаём существующий bloc
          child: Material(
          type: MaterialType.transparency,
          child: BlocBuilder<CompanyBloc, CompanyState>(
            builder: (context, state) {
              if (state is CompanyLoading) {
                return _DropdownContainer(
                  isEmpty: true,
                  child: Padding(
                    padding: EdgeInsets.all(16.h),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              if (state is CompanyError) {
              //  _showDropdown = true;
                return _DropdownContainer(
                  isEmpty: false,
                  child: Padding(
                    padding: EdgeInsets.all(14.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16.sp,
                          color: Colors.red.shade400,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            state.message,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.red.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is CompanyLoaded) {
              //  _showDropdown = true;
                if (state.companies.isEmpty) {
                  return _DropdownContainer(
                    isEmpty: true,
                    child: Center(
                      child: Text(
                        'Nicio companie găsită',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  );
                }
              //  _showDropdown = true;
                return _DropdownContainer(
                  isEmpty: false,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.companies.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1.h, color: AppColors.textTitleFl),
                      itemBuilder: (context, index) {
                        final company = state.companies[index];
                          return _CompanyTile(
                            company: company,
                            onTap: () => _onSelectCompany(company),
                          );
                      },
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
              // твой существующий код dropdown
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

  double _getDropdownPosition() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    return position.dy + 32.h;
  }

  void _onSelectCompany(CompanyModel company) {
    setState(() {
    //  _showDropdown = false;
      _selectedCompany = company;
      _controller.text = company.name;
    });
    _hideOverlay();
    _focusNode.unfocus();
    widget.onSelected?.call(company);
  }

  void _clearSelection() {
    setState(() {
      _selectedCompany = null;
      _controller.clear();
    //  _showDropdown = false;
    });
    context.read<CompanyBloc>().add(ClearCompanyEvent());
    widget.onSelected?.call(
      CompanyModel(
        oid: 0,
        name: '',
        idnp: null,
        companyStateOid: 0,
        companyStateName: '',
        active: false,
        dateModifire: DateTime(0),
        dateCreated: DateTime(0),
        platforms: [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(valueListenable: _isOpenNotifier,
    builder: (context, isOpen, child) {
      // ─── Поле ввода ───────────────────────────────────────
    return  Container(
        key: _textFieldKey,
        alignment: Alignment.center,
        height: 32.h,
        // высота только для поля ввода
        decoration: BoxDecoration(
          color: AppColors.backgroundCardColor,
          borderRadius: isOpen
              ? BorderRadius.only(
            topLeft: Radius.circular(10.r),
            topRight: Radius.circular(10.r),
          )
              : BorderRadius.circular(100.r),
          border: Border(
            top: BorderSide(color: AppColors.textTitleFl, width: 1),
            left: BorderSide(color: AppColors.textTitleFl, width: 1),
            right: BorderSide(color: AppColors.textTitleFl, width: 1),
            bottom: isOpen
                ? BorderSide.none
                : BorderSide(
              color: AppColors.textTitleFl,
              width: 1,
            ), // убираем нижнюю
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Icon(
                Icons.business_outlined,
                size: 20.sp,
                color: AppColors.hintTextColor,
              ),
            ),
            SizedBox(
              width: 230.w,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: _onTextChanged,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  hintText: 'Selectare companie',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: AppColors.textColorOne,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            Spacer(),
            if (_controller.text.isNotEmpty)
              GestureDetector(
                onTap: _clearSelection,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Icon(
                    Icons.close,
                    size: 18.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
          ],
        ),
      );
      //    // ─── Dropdown ─────────────────────────────────────────
    }
    );
  }
}

// ─── Вспомогательные виджеты ──────────────────────────────

class _DropdownContainer extends StatelessWidget {
  final Widget child;
  final bool isEmpty;

  const _DropdownContainer({required this.child, required this.isEmpty});

  @override
  Widget build(BuildContext context) {
    return Container(
      //  margin: EdgeInsets.only(top: 4.h),
      //  constraints: BoxConstraints(maxHeight: !isEmpty ? 200.h : 32.h, minHeight: 32.h),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.backgroundCardColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10.r),
          bottomRight: Radius.circular(10.r),
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.textTitleFl, width: 1),
          left: BorderSide(color: AppColors.textTitleFl, width: 1),
          right: BorderSide(color: AppColors.textTitleFl, width: 1),
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

class _CompanyTile extends StatelessWidget {
  final CompanyModel company;
  final VoidCallback onTap;

  const _CompanyTile({required this.company, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },

      child: Padding(
        padding: EdgeInsets.only(left: 10.h, right: 10.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (company.idnp != null && company.idnp!.isNotEmpty)
                    Text(
                      'IDNP: ${company.idnp}',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                ],
              ),
            ),
            // Статус активности
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: company.active
                    ? Colors.green.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                company.active ? 'Activ' : 'Inactiv',
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: company.active
                      ? Colors.green.shade600
                      : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
