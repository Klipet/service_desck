import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:service_desk/const/const_colors.dart';
import 'package:service_desk/data_base/data_models/user_model_db.dart';
import 'package:service_desk/packeges/custom_title_bar.dart';
import 'package:service_desk/screens/settings_screen.dart';
import 'package:service_desk/screens/tikets/ticket_table_screen.dart';


import '../data_base/user_repository.dart';
import '../packeges/costom_nav/costom_sidebar.dart';
import '../packeges/costom_nav/icon_nav.dart';
import '../packeges/costom_nav/nav_item.dart';
import '../utils/navigator_provider.dart';
import 'ticket_detail_screens/ticket_detail_page.dart';
import 'dashboard_screens/dashboard_screen.dart';
import 'my_tickets_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late NavigationProvider _navigationProvider;
  bool _isInitialized = false;
  final UserRepository _userRepository = UserRepository();
  UserModelDB? _user;

  static  final List<NavItem> _navItems = [
    NavItem(
      icon: IconNav.home,
      iconSelected: IconNav.home_select,
      label: 'Главная',
    ),
    NavItem(
      icon: IconNav.ticket,
      iconSelected: IconNav.ticket_select,
      label: 'Заявки',
    ),
    NavItem(
      icon: IconNav.new_ticket,
      iconSelected: IconNav.new_ticket_select,
      label: 'Новая Заявки',
    ),
    NavItem(
      icon: IconNav.sablon,
      iconSelected: IconNav.sablon_select,
      label: 'Шаблоны',
    ),
    NavItem(
      icon: IconNav.company,
      iconSelected: IconNav.company_select,
      label: 'Компания',
    ),
    NavItem(
      icon: IconNav.setting,
      iconSelected: IconNav.setting_select,
      label: 'Настройки',
    ),
  ];
  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0);
    // Инициализируем после построения виджета
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _navigationProvider = Provider.of<NavigationProvider>(
        context,
        listen: false,
      );
      // Передаем PageController в NavigationProvider
      _navigationProvider.setPageController(_pageController);
      // Слушаем изменения в NavigationProvider
      _navigationProvider.addListener(_onNavigationChanged);

      _isInitialized = true;
    });
    userName();
  }

  Future<void> userName() async {
    final user = await _userRepository.getUser();
    setState(() => _user = user);
  }


  void _onNavigationChanged() {
    if (!_isInitialized || !mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final currentPage = navigationProvider.currentPageIndex;

    return Scaffold(
      backgroundColor: AppColors.borderCardColor,
      body: Column(
        children: [
          CustomTitleBar(),
          Expanded(
            child: Row(                          // ← Row вместо Stack+Positioned
              children: [
                CostomSidebar(
                  items: _navItems,
                  userName: _user?.userName ?? '',
                  selectedIndex: currentPage,
                  onItemSelected: (i) => navigationProvider.goToPage(i),
                ),
                Expanded(                       // ← PageView занимает остаток
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      navigationProvider.updatePageIndex(index);
                    },
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: DashboardScreen(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 1.w),
                        child: TicketScreen(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 1.w),
                        child: TicketDetailPage(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: MyTicketsScreen(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: TicketDetailPageUI(),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: SettingsScreen(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
