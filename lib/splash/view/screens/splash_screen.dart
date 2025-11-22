import 'package:doist/home/view/screens/home_screen.dart';
import 'package:doist/shared/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash-screen';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLogoAnimationComplete = false;

  void _handleAnimation() async {
    await Future.delayed(Duration(milliseconds: 1200), () {
      isLogoAnimationComplete = true;
      setState(() {});
    });
  }

  void _handleNaviagtion() async {
    await Future.delayed(Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
      }
    });
  }

  @override
  void initState() {
    _handleAnimation();
    _handleNaviagtion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: AlignmentGeometry.center,
          children: [
            AnimatedPositioned(
              duration: 400.ms,
              bottom: isLogoAnimationComplete
                  ? MediaQuery.sizeOf(context).height * 0.32
                  : MediaQuery.sizeOf(context).height * 0.45,
              child: AnimatedOpacity(
                duration: 400.ms,
                opacity: isLogoAnimationComplete ? 1 : 0,
                child: Column(
                  children: [
                    Text('Doist', style: textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Get things done, simply.',
                      style: textTheme.headlineSmall!.copyWith(
                        color: AppTheme.lightModeLightGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child:
                  Image.asset(
                        'assets/images/logo.png',
                        height: MediaQuery.sizeOf(context).height * 0.17,
                        width: MediaQuery.sizeOf(context).height * 0.17,
                        fit: BoxFit.fill,
                      )
                      .animate()
                      .fade(duration: 400.ms)
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        duration: 400.ms,
                        curve: Curves.easeIn,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
