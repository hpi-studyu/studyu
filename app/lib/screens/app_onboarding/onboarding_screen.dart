import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/routes.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return IntroductionScreen(
      pages: [
        _buildPage(
          title: l10n.onboarding_page1_title,
          body: l10n.onboarding_page1_subtitle,
          imagePath: 'assets/images/onboarding/page1.svg',
        ),
        _buildPage(
          title: l10n.onboarding_page2_title,
          body: l10n.onboarding_page2_subtitle,
          imagePath: 'assets/images/onboarding/page2.svg',
        ),
        _buildPage(
          title: l10n.onboarding_page3_title,
          body: l10n.onboarding_page3_subtitle,
          imagePath: 'assets/images/onboarding/page3.svg',
        ),
        _buildPage(
          title: l10n.onboarding_page4_title,
          body: l10n.onboarding_page4_subtitle,
          imagePath: 'assets/images/onboarding/page4.svg',
        ),
        _buildPage(
          title: l10n.onboarding_page5_title,
          body: l10n.onboarding_page5_subtitle,
          imagePath: 'assets/images/onboarding/page5.svg',
        ),
        _buildPage(
          title: l10n.onboarding_page6_title,
          body: l10n.onboarding_page6_subtitle,
          imagePath: 'assets/images/onboarding/page6.svg',
        ),
      ],
      showBackButton: true,
      back: Text(l10n.back),
      next: Text(l10n.next),
      done: Text(
        l10n.get_started,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      onDone: () => Navigator.pushReplacementNamed(context, Routes.welcome),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Theme.of(context).colorScheme.primary,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }

  PageViewModel _buildPage({
    required String title,
    required String body,
    required String imagePath,
  }) {
    return PageViewModel(
      title: title,
      body: body,
      image: Center(child: SvgPicture.asset(imagePath, height: 250)),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 16),
        imagePadding: EdgeInsets.only(top: 40),
        contentMargin: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
