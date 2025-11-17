import 'package:doist/generated/l10n.dart';
import 'package:doist/home/view/widgets/bottom_nav_bar_item.dart';
import 'package:doist/home_tab/view/screens/home_tab.dart';
import 'package:doist/settings_tab/view/screens/settings_tab.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:doist/shared/font_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Widget> appTabs = [HomeTab(), SettingsTab()];

  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final localization = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.appTitle),
        actions: [IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.add))],
      ),

      body: IndexedStack(index: _currentTabIndex, children: appTabs),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1, color: AppTheme.lightModeDividerGrey),
          ),
        ),
        child: BottomAppBar(
          color: AppTheme.lightModePrimary,
          padding: EdgeInsets.zero,
          child: BottomNavigationBar(
            selectedItemColor: AppTheme.lightModeBlack,
            unselectedItemColor: AppTheme.lightModeLightGrey,
            selectedLabelStyle: TextStyle(
              color: AppTheme.lightModeBlack,
              fontSize: FontManager.f14,
              fontWeight: FontManager.semiBold,
            ),
            unselectedLabelStyle: TextStyle(
              color: AppTheme.lightModeBlack,
              fontSize: FontManager.f12,
              fontWeight: FontManager.medium,
            ),
            currentIndex: _currentTabIndex,
            onTap: (index) {
              if (_currentTabIndex == index) return;
              _currentTabIndex = index;
              setState(() {});
            },
            items: [
              BottomNavigationBarItem(
                icon: BottomNavBarItem(
                  icon: CupertinoIcons.house,
                  isSelected: false,
                ),
                activeIcon: BottomNavBarItem(
                  icon: CupertinoIcons.house_fill,
                  isSelected: true,
                ),
                label: localization.home,
              ),
              BottomNavigationBarItem(
                icon: BottomNavBarItem(
                  icon: CupertinoIcons.settings,
                  isSelected: false,
                ),
                activeIcon: BottomNavBarItem(
                  icon: CupertinoIcons.settings_solid,
                  isSelected: true,
                ),
                label: localization.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
