import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return IntroductionScreen(
      pages: [
        _buildPage(
          title: l10n.onboarding_page0_title,
          body: l10n.onboarding_page0_subtitle,
          imagePath: 'assets/icon/logo.png',
        ),
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
      ],
      showBackButton: true,
      back: Text(l10n.back),
      next: Text(l10n.next),
      done: Text(
        l10n.get_started,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onDone: () async {
        await SecureStorage.write('onboarded', 'true');
        if (!context.mounted) return;
        context.goNamed(RouteNames.terms);
      },
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
      image: Center(
        child: imagePath.endsWith('.svg')
            ? SvgPicture.asset(imagePath, height: 250)
            : Image.asset(imagePath, height: 250),
      ),
      decoration: const PageDecoration(
        titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        bodyTextStyle: TextStyle(fontSize: 16),
        imagePadding: EdgeInsets.only(top: 40),
        contentMargin: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
