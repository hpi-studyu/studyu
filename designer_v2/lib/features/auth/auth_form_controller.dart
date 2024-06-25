import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:supabase/supabase.dart';

part 'auth_form_controller.g.dart';

enum AuthFormKey {
  login,
  signup,
  passwordForgot,
  passwordRecovery,
  _loginSubmit,
  _signupSubmit;

  String get title {
    switch (this) {
      case login:
        return tr.login_page_title;
      case signup:
        return tr.signup_page_title;
      case passwordForgot:
        return tr.password_forgot_page_title;
      case passwordRecovery:
        return tr.password_recover_page_title;
      default:
        return "[AuthFormKey.title]";
    }
  }

  String? get description {
    switch (this) {
      case login:
        return tr.login_page_description;
      case signup:
        return tr.signup_page_description;
      case passwordForgot:
        return tr.password_forgot_page_description;
      default:
        return null;
    }
  }
}

@riverpod
class AuthFormController extends _$AuthFormController
    implements IFormGroupController {
  @override
  AsyncValue<void> build(AuthFormKey formKeyArg) {
    authRepository = ref.watch(authRepositoryProvider);
    notificationService = ref.watch(notificationServiceProvider);
    router = ref.watch(routerProvider);

    formKey = formKeyArg;
    resetControlsFor(formKey);

    ref.listenSelf((previous, next) {
      print("authFormController.state updated");
      if (state.hasError) {
        final AuthException error = state.error! as AuthException;
        switch (error.message) {
          case "Invalid login credentials":
            print("authFormController.state listen self");
            notificationService.show(Notifications.credentialsInvalid);
          case "User already registered":
            notificationService.show(Notifications.userAlreadyRegistered);
          default:
            notificationService.showMessage(error.message);
        }
      }
    });

    ref.onDispose(() {
      print("authFormControllerProvider.DISPOSE");
    });
    _readDebugUser();
    _onChangeFormKey(formKey);

    return const AsyncValue.data(null);
  }

  late final IAuthRepository authRepository;
  late final INotificationService notificationService;
  late final GoRouter router;

  // - Form controls

  final FormControl<String> emailControl = FormControl();
  final FormControl<String> passwordControl = FormControl();
  final FormControl<String> passwordConfirmationControl = FormControl();
  final FormControl<bool> termsOfServiceControl = FormControl(value: false);

  static final authValidationMessages = {
    ValidationMessage.required: (_) => tr.form_field_required,
    ValidationMessage.email: (_) => tr.form_field_email_invalid,
    ValidationMessage.mustMatch: (_) => tr.form_field_password_mustmatch,
    ValidationMessage.minLength: (error) => tr.form_field_password_minlength(
          (error as Map)['requiredLength'] as String,
        ),
  };

  late final FormGroup loginForm = FormGroup({
    'email': emailControl,
    'password': passwordControl,
  });

  late final FormGroup signupForm = FormGroup(
    {
      'email': emailControl,
      'password': passwordControl,
      'passwordConfirmation': passwordConfirmationControl,
      'termsOfService': termsOfServiceControl,
    },
    validators: [
      Validators.mustMatch('password', 'passwordConfirmation'),
    ],
  );

  late final FormGroup passwordForgotForm = FormGroup({
    'email': emailControl,
  });

  late final FormGroup passwordRecoveryForm = FormGroup(
    {
      'password': passwordControl,
      'passwordConfirmation': passwordConfirmationControl,
    },
    validators: [
      Validators.mustMatch('password', 'passwordConfirmation'),
    ],
  );

  late final Map<AuthFormKey, Map<FormControl, List<Validator<dynamic>>>>
      controlValidatorsByForm = {
    AuthFormKey.signup: {
      emailControl: [Validators.required, Validators.email],
      passwordControl: [Validators.minLength(8)],
      passwordConfirmationControl: [Validators.required],
      termsOfServiceControl: [Validators.required, Validators.requiredTrue],
    },
    AuthFormKey._signupSubmit: {
      emailControl: [Validators.required, Validators.email],
      passwordControl: [Validators.required, Validators.minLength(8)],
      passwordConfirmationControl: [Validators.required],
      termsOfServiceControl: [Validators.required, Validators.requiredTrue],
    },
    AuthFormKey._loginSubmit: {
      emailControl: [Validators.required, Validators.email],
      passwordControl: [Validators.required],
    },
    AuthFormKey.passwordForgot: {
      emailControl: [Validators.required, Validators.email],
    },
    AuthFormKey.passwordRecovery: {
      passwordControl: [Validators.required, Validators.minLength(8)],
      passwordConfirmationControl: [Validators.required],
    },
  };

  AuthFormKey _formKey = AuthFormKey.login;
  AuthFormKey get formKey => _formKey;
  set formKey(AuthFormKey key) {
    if (!AuthFormKey.values.contains(key)) {
      throw Exception("Unknown AuthFormKey");
    }
    _onChangeFormKey(formKey);
    _formKey = key;
  }

  @override
  FormGroup get form => _getFormFor(formKey)!;

  FormGroup? _getFormFor(AuthFormKey key) {
    switch (key) {
      case AuthFormKey.login:
        return loginForm;
      case AuthFormKey.signup:
        return signupForm;
      case AuthFormKey.passwordForgot:
        return passwordForgotForm;
      case AuthFormKey.passwordRecovery:
        return passwordRecoveryForm;
      default:
        return null;
    }
  }

  void _onChangeFormKey(AuthFormKey key) {
    resetControlsFor(key);
  }

  void resetControlsFor(AuthFormKey key) {
    final formControlValidators = controlValidatorsByForm[key];
    if (formControlValidators != null) {
      for (final entry in formControlValidators.entries) {
        final control = entry.key;
        final validators = entry.value;
        control.setValidators(validators, autoValidate: true);
        control.markAsUntouched();
      }
    }
    form.markAsUntouched();
    form.updateValueAndValidity();
  }

  void _forceValidationMessages(AuthFormKey key) {
    _onChangeFormKey(key);
    for (final control in form.controls.values) {
      control.markAsTouched();
      control.updateValueAndValidity();
    }
    form.markAsTouched();
    form.updateValueAndValidity();
  }

  Future<AuthResponse> signUp() {
    _forceValidationMessages(AuthFormKey._signupSubmit);
    if (emailControl.isNullOrEmpty || passwordControl.isNullOrEmpty) {
      return Future.value(AuthResponse());
    }
    return _signUp(emailControl.value!, passwordControl.value!);
  }

  Future<AuthResponse> _signUp(String email, String password) async {
    _forceValidationMessages(AuthFormKey._loginSubmit);
    if (!form.valid) {
      return Future.value(AuthResponse());
    }
    try {
      state = const AsyncValue.loading();
      return await authRepository.signUp(email: email, password: password);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      state = const AsyncValue.data(null);
    }
    return AuthResponse();
  }

  Future<AuthResponse> signIn() async {
    _forceValidationMessages(AuthFormKey._loginSubmit);
    if (!form.valid ||
        emailControl.isNullOrEmpty ||
        passwordControl.isNullOrEmpty) {
      return Future.value(AuthResponse());
    }
    return await _signInWith(emailControl.value!, passwordControl.value!);
  }

  Future<AuthResponse> _signInWith(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final response =
          await authRepository.signInWith(email: email, password: password);
      return response;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      state = const AsyncValue.data(null);
    }
    return Future.value(AuthResponse());
  }

  Future<void> signOut() async {
    try {
      state = const AsyncValue.loading();
      return await authRepository.signOut();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> resetPasswordForEmail(String email) async {
    try {
      state = const AsyncValue.loading();
      return await authRepository.resetPasswordForEmail(email: email);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> sendPasswordResetLink() {
    if (!form.valid) {
      return Future.value();
    }
    return resetPasswordForEmail(emailControl.value!)
        .then((_) => notificationService.show(Notifications.passwordReset));
  }

  Future<void> recoverPassword() async {
    if (!form.valid) {
      return Future.value();
    }
    return updateUser(passwordControl.value!)
        .then(
          (_) => notificationService.show(Notifications.passwordResetSuccess),
        )
        .then((_) => router.dispatch(RoutingIntents.studies));
  }

  Future<bool> updateUser(String newPassword) async {
    try {
      state = const AsyncValue.loading();
      return (await authRepository.updateUser(newPassword: newPassword)).user !=
          null;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      state = const AsyncValue.data(null);
    }
    return false;
  }

  Future<void> _readDebugUser() async {
    if (!kDebugMode) return;
    const email = String.fromEnvironment('EMAIL');
    const password = String.fromEnvironment('PASSWORD');
    const autoLogin = bool.fromEnvironment('AUTO_LOGIN');
    if (email.isNotEmpty && password.isNotEmpty) {
      emailControl.value = email;
      passwordControl.value = password;
      if (autoLogin && form.valid) await signIn();
    }
  }
}
