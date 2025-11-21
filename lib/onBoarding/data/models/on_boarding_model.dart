class OnBoardingModel {
  final String imageName;
  final String title;
  final String subTitle;

  const OnBoardingModel({
    required this.imageName,
    required this.title,
    required this.subTitle,
  });

  static List<OnBoardingModel> modelList = [
    OnBoardingModel(
      imageName: 'assets/images/onboarding-1.png',
      title: 'Welcome to Doist',
      subTitle:
          'Organize your work and life, finally. Become focused, organized, and calm with Doist.',
    ),
    OnBoardingModel(
      imageName: 'assets/images/onboarding-2.png',
      title: 'Organize your life with Doist',
      subTitle:
          'Manage tasks, projects, and goals in one place. Stay focused and achieve more every day.',
    ),
    OnBoardingModel(
      imageName: 'assets/images/onboarding-3.png',
      title: 'Set your first task',
      subTitle:
          'Start organizing your day by adding your first task. It\'s the first step to a more productive you.',
    ),
  ];
}
