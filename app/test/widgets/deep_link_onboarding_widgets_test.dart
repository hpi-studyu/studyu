import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/deep_link_onboarding_widgets.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase/supabase.dart';

void main() {
  setUpAll(() {
    setEnv(
      'https://example.supabase.co',
      'test-anon-key',
      envAndroidPackageName: 'health.studyu.app',
      envIosAppStoreId: '123456789',
      supabaseClient: SupabaseClient('https://example.supabase.co', 'test'),
    );
  });

  group('buildAppLaunchLink', () {
    test('uses public study universal link for public study links', () {
      expect(
        buildAppLaunchLink(studyId: 'test-study-id'),
        'https://app.studyu.health/study/test-study-id',
      );
    });
  });

  testWidgets('desktop invite landing renders the resolved study handoff', (
    tester,
  ) async {
    final previousPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      final study = Study('study-123', 'owner-123')
        ..title = 'Invite study'
        ..description = 'Study description'
        ..iconName = 'accountHeart';

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DeepLinkWebLandingPage(
            inviteCode: 'invite-123',
            lookupInvite: (_) async =>
                (StudyInvite('invite-123', study.id), study),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final stepOne = find.byKey(const ValueKey('invite-step-1'));
      final stepTwo = find.byKey(const ValueKey('invite-step-2'));

      expect(find.byKey(const Key('invite-study-summary')), findsOneWidget);
      expect(find.byKey(const Key('invite-static-steps')), findsOneWidget);
      expect(find.byType(Stepper), findsNothing);
      expect(stepOne, findsOneWidget);
      expect(stepTwo, findsOneWidget);
      expect(
        find.descendant(
          of: stepTwo,
          matching: find.byKey(const Key('invite-code')),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: stepTwo,
          matching: find.byKey(const Key('invite-qr')),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Invite study'), findsOneWidget);
      expect(find.text('Study description'), findsOneWidget);
      expect(find.text('invite-123'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Get it on Google Play'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(FilledButton, 'Download on the App Store'),
        findsOneWidget,
      );
    } finally {
      debugDefaultTargetPlatformOverride = previousPlatform;
    }
  });

  testWidgets('desktop invite landing renders closed study metadata', (
    tester,
  ) async {
    final previousPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      final study = Study('study-closed', 'owner-123')
        ..title = 'Closed study'
        ..status = StudyStatus.closed;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DeepLinkWebLandingPage(
            inviteCode: 'invite-closed',
            lookupInvite: (_) async =>
                (StudyInvite('invite-closed', study.id), study),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Closed study'), findsOneWidget);
      expect(find.byKey(const Key('invite-static-steps')), findsOneWidget);
      expect(find.byKey(const Key('invite-code')), findsOneWidget);
      expect(
        find.text(
          'This invitation is no longer available. Please check the link or code and try again.',
        ),
        findsNothing,
      );
    } finally {
      debugDefaultTargetPlatformOverride = previousPlatform;
    }
  });

  testWidgets('desktop invite landing shows loading before invite resolves', (
    tester,
  ) async {
    final previousPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final completer = Completer<(StudyInvite?, Study?)>();
    try {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DeepLinkWebLandingPage(
            inviteCode: 'invite-loading',
            lookupInvite: (_) => completer.future,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(const Key('invite-static-steps')), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = previousPlatform;
      if (!completer.isCompleted) {
        completer.complete((null, null));
      }
    }
  });

  testWidgets('desktop invite landing shows localized load error message', (
    tester,
  ) async {
    final previousPlatform = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DeepLinkWebLandingPage(
            inviteCode: 'invite-error',
            lookupInvite: (_) async => throw Exception('failed'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(DeepLinkWebLandingPage));
      final l10n = AppLocalizations.of(context)!;
      expect(find.text(l10n.invite_landing_load_error), findsOneWidget);
      expect(find.byKey(const Key('invite-static-steps')), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = previousPlatform;
    }
  });

  testWidgets(
    'desktop invite landing shows invalid invite message when missing study',
    (tester) async {
      final previousPlatform = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      try {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: DeepLinkWebLandingPage(
              inviteCode: 'invite-invalid',
              lookupInvite: (_) async =>
                  (StudyInvite('invite-invalid', 'study'), null),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(DeepLinkWebLandingPage));
        final l10n = AppLocalizations.of(context)!;
        expect(find.text(l10n.invite_landing_invalid), findsOneWidget);
        expect(find.byKey(const Key('invite-static-steps')), findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = previousPlatform;
      }
    },
  );

  testWidgets(
    'desktop study deep link shows join description without invite options',
    (tester) async {
      final previousPlatform = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      try {
        await tester.pumpWidget(
          const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: DeepLinkWebLandingPage(studyId: 'study-123'),
          ),
        );
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(DeepLinkWebLandingPage));
        final l10n = AppLocalizations.of(context)!;
        expect(
          find.text(l10n.invite_landing_step_join_description),
          findsOneWidget,
        );
        expect(find.byKey(const Key('invite-static-steps')), findsNothing);
        expect(find.byKey(const Key('invite-code')), findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = previousPlatform;
      }
    },
  );

  testWidgets(
    'copy button shows temporary copied feedback on desktop invite landing',
    (tester) async {
      final previousPlatform = debugDefaultTargetPlatformOverride;
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      try {
        String? clipboardText;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              clipboardText =
                  (call.arguments as Map<Object?, Object?>)['text']! as String;
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );

        final study = Study('study-copy', 'owner-123')..title = 'Invite study';

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: DeepLinkWebLandingPage(
              inviteCode: 'invite-copy',
              lookupInvite: (_) async =>
                  (StudyInvite('invite-copy', study.id), study),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(DeepLinkWebLandingPage));
        final l10n = AppLocalizations.of(context)!;
        final copyButton = find.widgetWithText(FilledButton, l10n.copy_btn);
        expect(copyButton, findsOneWidget);

        await tester.ensureVisible(copyButton);
        await tester.tap(copyButton);
        await tester.pump();
        expect(clipboardText, 'invite-copy');
        expect(
          find.widgetWithText(FilledButton, l10n.invite_landing_copied),
          findsOneWidget,
        );

        await tester.pump(const Duration(seconds: 2));
        expect(
          find.widgetWithText(FilledButton, l10n.copy_btn),
          findsOneWidget,
        );
      } finally {
        debugDefaultTargetPlatformOverride = previousPlatform;
      }
    },
  );

  group('buildAppLaunchLink with prod-like env', () {
    setUp(() {
      appDeepLinkScheme = 'studyu-app://';
    });
    tearDown(() {
      appDeepLinkScheme = null;
    });

    test('invite link uses custom scheme studyu-app:// for app launch', () {
      expect(buildAppLaunchLink(inviteCode: '123'), 'studyu-app://invite/123');
    });

    test('invite link encodes reserved code characters', () {
      expect(
        buildAppLaunchLink(inviteCode: 'abc/xyz#part%value'),
        'studyu-app://invite/abc%2Fxyz%23part%25value',
      );
    });

    test('public study link still uses HTTPS universal link', () {
      expect(
        buildAppLaunchLink(studyId: 'test-study-id'),
        'https://app.studyu.health/study/test-study-id',
      );
    });
  });
}
