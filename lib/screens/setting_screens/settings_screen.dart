import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/screens/setting_screens/settings_tab/company_settings_tab.dart';

import '../../data_base/repository/dictionaries_repository.dart';
import 'settings_tab/category_create_tab.dart';
import 'settings_tab/company_state_create_tab.dart';
import 'settings_tab/email_template_create_tab.dart';
import 'settings_tab/holiday_create_tab.dart';
import 'settings_tab/mode_create_tab.dart';
import 'settings_tab/phone_resault_create_tab.dart';
import 'settings_tab/ticket_state_create_tab.dart';
import 'settings_tab/tiket_type_create_tab.dart';
import 'settings_tab/user_create_tab.dart';
import 'settings_tab/workspace_create_tab.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

/// Описание одного раздела настроек: иконка, заголовок и билдер контента.
class SettingsTabItem {
  final String title;
  final IconData icon;
  final WidgetBuilder builder;

  const SettingsTabItem({
    required this.title,
    required this.icon,
    required this.builder,
  });
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 0;
  final _dictionariesRepo = DictionariesRepository();

  // 👉 Чтобы добавить новый раздел настроек — просто добавь элемент сюда.
  late final List<SettingsTabItem> _tabs = [
    SettingsTabItem(
      title: 'Компании',
      icon: Icons.apartment_outlined,
      builder: (_) => const CompanySettingsTab(),
    ),
    SettingsTabItem(
      title: 'Рабочие пространства',
      icon: Icons.workspaces_outlined,
      builder: (_) => const WorkSpaceCreateTab(),
    ),
    SettingsTabItem(
      title: 'Типы заявок (API)',
      icon: Icons.add_box_outlined,
      builder: (_) => const TiketTypeCreateTab(),
    ),
    SettingsTabItem(
      title: 'Статусы заявок (API)',
      icon: Icons.add_box_outlined,
      builder: (_) => const TicketStateCreateTab(),
    ),
    SettingsTabItem(
      title: 'Режимы (API)',
      icon: Icons.add_box_outlined,
      builder: (_) => const ModeCreateTab(),
    ),
    SettingsTabItem(
      title: 'Результаты звонков',
      icon: Icons.call_outlined,
      builder: (_) => const PhoneResaultCreateTab(),
    ),
    SettingsTabItem(
      title: 'Статусы компаний',
      icon: Icons.apartment_outlined,
      builder: (_) => const CompanyStateCreateTab(),
    ),
    SettingsTabItem(
      title: 'Категории и подкатегории',
      icon: Icons.folder_outlined,
      builder: (_) => const CategoryCreateTab(),
    ),
    SettingsTabItem(
      title: 'Праздники',
      icon: Icons.event_outlined,
      builder: (_) => const HolidayCreateTab(),
    ),
    SettingsTabItem(
      title: 'Email-шаблоны',
      icon: Icons.email_outlined,
      builder: (_) => const EmailTemplateCreateTab(),
    ),
    SettingsTabItem(
      title: 'Пользователи',
      icon: Icons.person_add_alt_outlined,
      builder: (_) => const UserCreateTab(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.borderCardColor,
      body: Row(
        children: [
          _SettingsSidebar(
            tabs: _tabs,
            selectedIndex: _selectedIndex,
            onSelected: (i) => setState(() => _selectedIndex = i),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(14.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(10.r),
                border:
                Border.all(color: AppColors.borderCardColor, width: 1.w),
              ),
              // key нужен, чтобы у каждой вкладки было своё чистое состояние
              child: KeyedSubtree(
                key: ValueKey(_selectedIndex),
                child: _tabs[_selectedIndex].builder(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSidebar extends StatelessWidget {
  final List<SettingsTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _SettingsSidebar({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220.w,
      margin: EdgeInsets.fromLTRB(14.w, 14.h, 0, 14.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.borderCardColor, width: 1.w),
      ),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: tabs.length,
        itemBuilder: (_, i) {
          final tab = tabs[i];
          final active = i == selectedIndex;
          return InkWell(
            borderRadius: BorderRadius.circular(8.r),
            onTap: () => onSelected(i),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: active ? AppColors.backgroundCardColor : null,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    tab.icon,
                    size: 18.sp,
                    color: active
                        ? AppColors.textTitleFl
                        : AppColors.hintTextColor,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      tab.title,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp.clamp(12, 20),
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active
                            ? AppColors.textTitleFl
                            : AppColors.textColorOne,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}