import 'dart:developer';

import 'package:doist/home/view/screens/home_screen.dart';
import 'package:doist/home_tab/view_model/home_tab_view_model.dart';
import 'package:doist/onBoarding/view/screens/on_boarding_screen.dart';
import 'package:doist/onBoarding/view_model/on_boarding_view_model.dart';
import 'package:doist/settings_tab/view_model/settings_states.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:doist/splash/view/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getTemporaryDirectory()).path,
    ),
  );
  log('HydratedStorage built: ${storage.runtimeType}');
  HydratedBloc.storage = storage;
  log('HydratedBloc.storage has been set.');

  runApp(const Doist());
}

class Doist extends StatelessWidget {
  const Doist({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsBloc(),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // routes: {
            //   HomeScreen.routeName: (_) => BlocProvider(
            //     create: (context) => HomeTabBloc(),
            //     child: HomeScreen(),
            //   ),
            //   OnboardingScreen.routeName: (_) => BlocProvider(
            //     create: (context) => OnBoardingBloc(),
            //     child: OnboardingScreen(),
            //   ),
            //   SplashScreen.routeName: (_) => SplashScreen(),
            // },
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case HomeScreen.routeName:
                  return PageTransition(
                    type: PageTransitionType.fade,
                    child: BlocProvider(
                      create: (context) => HomeTabBloc(),
                      child: HomeScreen(),
                    ),
                    duration: 400.ms,
                    curve: Curves.easeInOut,
                    settings: settings,
                  );
                case OnboardingScreen.routeName:
                  return PageTransition(
                    type: PageTransitionType.fade,
                    child: BlocProvider(
                      create: (context) => OnBoardingBloc(),
                      child: OnboardingScreen(),
                    ),
                    duration: 400.ms,
                    curve: Curves.easeInOut,
                    settings: settings,
                  );
                case SplashScreen.routeName:
                  return PageTransition(
                    type: PageTransitionType.fade,
                    child: SplashScreen(),
                    duration: 400.ms,
                    curve: Curves.easeInOut,
                    settings: settings,
                  );
                default:
                  return null;
              }
            },
            initialRoute: SplashScreen.routeName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.model.themeMode,
            locale: Locale(state.model.language),
            localizationsDelegates: [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
          );
        },
      ),
    );
  }
}
