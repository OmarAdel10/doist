import 'package:doist/generated/l10n.dart';
import 'package:doist/home/view/widgets/bottom_nav_bar_item.dart';
import 'package:doist/home_tab/view/screens/home_tab.dart';
import 'package:doist/settings_tab/view/screens/settings_tab.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:doist/shared/font_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final themeMode = context.read<SettingsBloc>().state.model.themeMode;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentTabIndex == 1 ? localization.settings : localization.appTitle,
        ),
        shape: Border(bottom: BorderSide(color: AppTheme.lightModeDividerGrey)),
      ),

      body: IndexedStack(index: _currentTabIndex, children: appTabs),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1, color: AppTheme.lightModeDividerGrey),
          ),
        ),
        child: BottomAppBar(
          color: themeMode == ThemeMode.light
              ? AppTheme.lightModePrimary
              : AppTheme.darkModePrimary,
          padding: EdgeInsets.zero,
          child: BottomNavigationBar(
            backgroundColor: themeMode == ThemeMode.light
                ? AppTheme.lightModePrimary
                : AppTheme.darkModePrimary,
            selectedItemColor: themeMode == ThemeMode.light ? AppTheme.lightModeBlack : AppTheme.darkModeWhite,
            unselectedItemColor: themeMode == ThemeMode.light ?AppTheme.lightModeLightGrey : AppTheme.darkModeFormAndCheckBoxGrey,
            selectedLabelStyle: TextStyle(
              color: themeMode == ThemeMode.light ? AppTheme.lightModeBlack : AppTheme.darkModeFormAndCheckBoxGrey,
              fontSize: FontManager.f14,
              fontWeight: FontManager.semiBold,
            ),
            unselectedLabelStyle: TextStyle(
              color: themeMode == ThemeMode.light ? AppTheme.lightModeBlack : AppTheme.darkModeFormAndCheckBoxGrey,
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
