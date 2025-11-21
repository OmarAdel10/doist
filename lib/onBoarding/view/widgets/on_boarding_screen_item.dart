import 'package:flutter/material.dart';

class OnBoardingScreenItem extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subTitle;

  const OnBoardingScreenItem({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          imageUrl,
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height * 0.3,
          fit: BoxFit.fill,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center,),
              const SizedBox(height: 16),
              Text(
                subTitle,
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
