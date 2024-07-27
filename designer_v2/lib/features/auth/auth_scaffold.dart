import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/layout_two_column.dart';
import 'package:studyu_designer_v2/common_views/studyu_logo.dart';
import 'package:studyu_designer_v2/common_views/text_hyperlink.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/auth/auth_form_controller.dart';
import 'package:studyu_designer_v2/features/auth/studyu_jtbd.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/language_picker.dart';
import 'package:studyu_designer_v2/localization/locale_providers.dart';
import 'package:studyu_designer_v2/repositories/app_repository.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthScaffold extends ConsumerStatefulWidget {
  const AuthScaffold({
    required this.body,
    required this.formKey,
    this.leftPanelMinWidth = 550.0,
    this.leftPanelPadding = const EdgeInsets.fromLTRB(88.0, 54.0, 88.0, 40.0),
    super.key,
  });

  final Widget body;
  final AuthFormKey formKey;

  final double leftPanelMinWidth;

  final EdgeInsets leftPanelPadding;

  @override
  ConsumerState<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends ConsumerState<AuthScaffold> {
  AuthFormKey get formKey => widget.formKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.watch(authFormControllerProvider(formKey).notifier);
    final appConfig = ref.watch(appConfigProvider).value;

    return Scaffold(
      key: RouterKeys.authKey,
      backgroundColor: Colors.white,
      body: TwoColumnLayout(
        flexLeft: 4,
        flexRight: 6,
        leftWidget: ReactiveFormConfig(
          validationMessages: AuthFormController.authValidationMessages,
          child: ReactiveForm(
            formGroup: controller.form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(maxHeight: 88.0),
                  child: const StudyULogo(),
                ),
                const SizedBox(height: 32.0),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        formKey.title,
                        style: theme.textTheme.displaySmall,
                      ),
                      const SizedBox(height: 8.0),
                      if (formKey.description != null)
                        TextParagraph(
                          text: formKey.description,
                          style: ThemeConfig.bodyTextMuted(theme),
                        )
                      else
                        const SizedBox.shrink(),
                      const SizedBox(height: 24.0),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 24.0),
                            child: widget.body,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SelectableText(
                      "© HPI Digital Health Cluster ${DateTime.now().year}",
                      style: ThemeConfig.bodyTextBackground(theme),
                    ),
                    Row(
                      children: [
                        LanguagePicker(
                          languagePickerType: LanguagePickerType.icon,
                          iconColor:
                              ThemeConfig.bodyTextBackground(theme).color,
                          offset: const Offset(0, -60),
                        ),
                        const SizedBox(width: 12.0),
                        Hyperlink(
                          text: tr.imprint,
                          onClick: () => _onClickImprint(appConfig),
                          linkColor:
                              ThemeConfig.bodyTextBackground(theme).color!,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        rightWidget: const Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: StudyUJobsToBeDone(),
              ),
            ),
          ],
        ),
        backgroundColorLeft: ThemeConfig.bodyBackgroundColor(theme),
        backgroundColorRight: theme.colorScheme.primary,
        constraintsLeft: BoxConstraints(minWidth: widget.leftPanelMinWidth),
        scrollLeft: false,
        scrollRight: false,
        paddingLeft: widget.leftPanelPadding,
      ),
    );
  }

  Future<bool?> _onClickImprint(AppConfig? appConfig) {
    final locale = ref.watch(localeProvider);
    if (appConfig != null) {
      final imprintUri = appConfig.imprint[locale.languageCode];
      if (imprintUri != null) {
        return launchUrl(Uri.parse(imprintUri));
      }
    }
    return Future.value(false);
  }
}
