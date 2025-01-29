import 'package:flutter/material.dart';
import 'package:kokiku/constants/services/localization_service.dart';
import 'package:kokiku/constants/variables/asset.dart';
import 'package:kokiku/constants/variables/theme.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  OnboardingPageState createState() => OnboardingPageState();
}

class OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final localizations = LocalizationService.of(context)!;
    final onboardingList = [
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: OnboardingContent(
          image: Asset.welcome,
          title: localizations.translate('onboardingWelcome'),
          subtitle: localizations.translate('onboardingWelcomeSub'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: OnboardingContent(
          image: Asset.track,
          title: localizations.translate('onboardingTrack'),
          subtitle: localizations.translate('onboardingTrackSub'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: OnboardingContent(
          image: Asset.recipes,
          title: localizations.translate('onboardingRecipes'),
          subtitle: localizations.translate('onboardingRecipesSub'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: OnboardingContent(
          image: Asset.notification,
          title: localizations.translate('onboardingNotification'),
          subtitle: localizations.translate('onboardingNotificationSub'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(24.0),
        child: OnboardingContent(
          image: Asset.plan,
          title: localizations.translate('onboardingPlan'),
          subtitle: localizations.translate('onboardingPlanSub'),
        ),
      ),
    ];

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: onboardingList,
            ),
          ),
          // Indicator Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingList.length, (index) => buildDot(index, context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _onSkipPressed,
                  child: Text(
                    localizations.translate('skip'),
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                // Next or Get Started Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _onNextPressed,
                  child: Text(
                    _currentPage == (onboardingList.length - 1)
                        ? localizations.translate('getStarted')
                        : localizations.translate('next'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _onNextPressed() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to the next screen
      Navigator.pushReplacementNamed(
        context,
        '/landing',
      );
    }
  }

  void _onSkipPressed() {
    // Navigate to the next screen
    Navigator.pushReplacementNamed(
      context,
      '/landing',
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300), // animation duration
      height: 10,
      width: _currentPage == index ? 20 : 10,
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppTheme.primaryColor
            : AppTheme.primaryColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const OnboardingContent({super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          image,
          height: 250,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 30),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
