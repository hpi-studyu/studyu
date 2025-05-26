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
  passwordReset,
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
      case passwordReset:
        return tr.change_password;
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
      case passwordReset:
        return tr.password_change_description;
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
    _authRepository = ref.watch(authRepositoryProvider);
    _notificationService = ref.watch(notificationServiceProvider);
    _router = ref.watch(routerProvider);

    formKey = formKeyArg;
    resetControlsFor(formKey);

    listenSelf((previous, next) {
      print("authFormController.state updated");
      if (state.hasError) {
        final AuthException error = state.error! as AuthException;
        switch (error.message) {
          case "Invalid login credentials":
            print("authFormController.state listen self");
            _notificationService.show(Notifications.credentialsInvalid);
          case "User already registered":
            _notificationService.show(Notifications.userAlreadyRegistered);
          default:
            _notificationService.showMessage(error.message);
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

  late final IAuthRepository _authRepository;
  late final INotificationService _notificationService;
  late final GoRouter _router;

  // - Form controls

  final FormControl<String> emailControl = FormControl();
  final FormControl<String> oldPasswordControl = FormControl();
  final FormControl<String> passwordControl = FormControl();
  final FormControl<String> passwordConfirmationControl = FormControl();
  final FormControl<bool> termsOfServiceControl = FormControl(value: false);

  static final authValidationMessages = {
    ValidationMessage.required: (_) => tr.form_field_required,
    ValidationMessage.email: (_) => tr.form_field_email_invalid,
    ValidationMessage.mustMatch: (_) => tr.form_field_password_mustmatch,
    ValidationMessage.minLength: (error) => tr.form_field_password_minlength(
          (error as Map)['requiredLength'] as num,
        ),
  };

  late final FormGroup _loginForm = FormGroup({
    'email': emailControl,
    'password': passwordControl,
  });

  late final FormGroup _signupForm = FormGroup(
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

  late final FormGroup _passwordForgotForm = FormGroup({
    'email': emailControl,
  });

  late final FormGroup _passwordRecoveryForm = FormGroup(
    {
      'password': passwordControl,
      'passwordConfirmation': passwordConfirmationControl,
    },
    validators: [
      Validators.mustMatch('password', 'passwordConfirmation'),
    ],
  );

  late final FormGroup _passwordResetForm = FormGroup(
    {
      'oldPassword': oldPasswordControl,
      'password': passwordControl,
      'passwordConfirmation': passwordConfirmationControl,
    },
    validators: [
      Validators.mustMatch('password', 'passwordConfirmation'),
    ],
  );

  late final Map<AuthFormKey, Map<FormControl, List<Validator<dynamic>>>>
      _controlValidatorsByForm = {
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
    AuthFormKey.passwordReset: {
      oldPasswordControl: [Validators.required, Validators.minLength(8)],
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
        return _loginForm;
      case AuthFormKey.signup:
        return _signupForm;
      case AuthFormKey.passwordForgot:
        return _passwordForgotForm;
      case AuthFormKey.passwordRecovery:
        return _passwordRecoveryForm;
      case AuthFormKey.passwordReset:
        return _passwordResetForm;
      default:
        return null;
    }
  }

  void _onChangeFormKey(AuthFormKey key) {
    resetControlsFor(key);
  }

  void resetControlsFor(AuthFormKey key) {
    final formControlValidators = _controlValidatorsByForm[key];
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
      return await _authRepository.signUp(email: email, password: password);
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
          await _authRepository.signInWith(email: email, password: password);
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
      return await _authRepository.signOut();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> resetPasswordForEmail(String email) async {
    try {
      state = const AsyncValue.loading();
      return await _authRepository.resetPasswordForEmail(email: email);
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
        .then((_) => _notificationService.show(Notifications.passwordReset));
  }

  Future<void> recoverPassword() {
    if (!form.valid) {
      return Future.value();
    }
    return updateUser(passwordControl.value!)
        .then(
          (_) => _notificationService.show(Notifications.passwordResetSuccess),
        )
        .then((_) => _router.dispatch(RoutingIntents.studies));
  }

  Future<bool> resetPassword() async {
    if (!form.valid) {
      return false;
    }

    final isOldPasswordValid =
        await _isOldPasswordValid(oldPasswordControl.value!);

    if (!isOldPasswordValid) {
      return false;
    }

    return updateUser(passwordControl.value!);
  }

  Future<bool> updateUser(String newPassword) async {
    try {
      state = const AsyncValue.loading();
      return (await _authRepository.updateUser(newPassword: newPassword))
              .user !=
          null;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      state = const AsyncValue.data(null);
    }
    return false;
  }

  Future<bool> _isOldPasswordValid(String oldPassword) async {
    if (oldPassword.isEmpty || _authRepository.currentUser?.email == null) {
      return false;
    }

    try {
      state = const AsyncValue.loading();

      final response = await _authRepository.signInWith(
        email: _authRepository.currentUser!.email!,
        password: oldPassword,
      );

      return response.session != null;
    } catch (e) {
      return false;
    } finally {
      state = const AsyncValue.data(null);
    }
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
