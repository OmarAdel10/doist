import 'package:doist/home/view/screens/home_screen.dart';
import 'package:doist/onBoarding/view/widgets/on_boarding_screen_item.dart';
import 'package:doist/onBoarding/view_model/on_boarding_events.dart';
import 'package:doist/onBoarding/view_model/on_boarding_states.dart';
import 'package:doist/onBoarding/view_model/on_boarding_view_model.dart';
import 'package:doist/settings_tab/view_model/settings_events.dart';
import 'package:doist/settings_tab/view_model/settings_view_model.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/on-boarding';
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePress(BuildContext context) {
    final currentState = context.read<OnBoardingBloc>().state;
    final currentIndex = currentState.index;
    final totalPagesCount = currentState.modelList.length;

    if (currentIndex < totalPagesCount - 1) {
      context.read<OnBoardingBloc>().add(OnBoardingNext());
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.read<SettingsBloc>().add(SettingsUpdateOnBoardingCompleteness());
      Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<OnBoardingBloc, OnBoardingState>(
              builder: (context, state) {
                return Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          controller: _pageController,
                          itemCount: state.modelList.length,
                          itemBuilder: (context, index) {
                            final model = state.modelList[index];
                            return OnBoardingScreenItem(
                              imageUrl: model.imageName,
                              title: model.title,
                              subTitle: model.subTitle,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Transform.scale(
                              scale: 0.6,
                              child: SmoothPageIndicator(
                                controller: _pageController,
                                count: state.modelList.length,
                                effect: JumpingDotEffect(
                                  activeDotColor: AppTheme.darkModeSecondry,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                _handlePress(context);
                              },
                              child: Container(
                                width: double.infinity,
                                height:
                                    MediaQuery.sizeOf(context).height * 0.07,
                                decoration: BoxDecoration(
                                  color: AppTheme.darkModeSecondry,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    state.index == state.modelList.length - 1
                                        ? 'Get Started'
                                        : 'Next',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
