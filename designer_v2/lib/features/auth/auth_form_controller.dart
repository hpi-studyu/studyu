import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/auth_repository.dart';
import 'package:studyu_designer_v2/routing/router.dart';
import 'package:studyu_designer_v2/routing/router_intent.dart';
import 'package:studyu_designer_v2/services/notification_service.dart';
import 'package:studyu_designer_v2/services/notifications.dart';
import 'package:studyu_designer_v2/services/shared_prefs.dart';
import 'package:supabase/supabase.dart';

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

class AuthFormController extends StateNotifier<AsyncValue<void>> implements IFormGroupController {
  AuthFormController({
    required this.authRepository,
    required this.sharedPreferences,
    required this.notificationService,
    required this.router,
  }) : super(const AsyncValue.data(null)) {
    _initRememberMe();
    _readDebugUser();
    _onChangeFormKey(formKey);
  }

  final IAuthRepository authRepository;
  final SharedPreferences sharedPreferences;
  final INotificationService notificationService;
  final GoRouter router;

  // - Form controls

  final FormControl<String> emailControl = FormControl();
  final FormControl<String> passwordControl = FormControl();
  final FormControl<String> passwordConfirmationControl = FormControl();
  final FormControl<bool> rememberMeControl = FormControl(value: false);
  final FormControl<bool> termsOfServiceControl = FormControl(value: false);

  bool get shouldRemember => rememberMeControl.value!;

  static final authValidationMessages = {
    ValidationMessage.required: (error) => tr.form_field_required,
    ValidationMessage.email: (error) => tr.form_field_email_invalid,
    ValidationMessage.mustMatch: (error) => tr.form_field_password_mustmatch,
    ValidationMessage.minLength: (error) => tr.form_field_password_minlength(error['requiredLength']),
  };

  late final FormGroup loginForm = FormGroup({
    'email': emailControl,
    'password': passwordControl,
    'rememberMe': rememberMeControl,
  });

  late final FormGroup signupForm = FormGroup({
    'email': emailControl,
    'password': passwordControl,
    'passwordConfirmation': passwordConfirmationControl,
    'termsOfService': termsOfServiceControl,
  }, validators: [
    Validators.mustMatch('password', 'passwordConfirmation'),
  ]);

  late final FormGroup passwordForgotForm = FormGroup({
    'email': emailControl,
  });

  late final FormGroup passwordRecoveryForm = FormGroup({
    'password': passwordControl,
    'passwordConfirmation': passwordConfirmationControl,
  }, validators: [
    Validators.mustMatch('password', 'passwordConfirmation'),
  ]);

  late final Map<AuthFormKey, Map<FormControl, List<Validator<dynamic>>>> controlValidatorsByForm = {
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
  FormGroup get form => _getFormFor(formKey);

  _getFormFor(AuthFormKey key) {
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

  _onChangeFormKey(AuthFormKey key) {
    resetControlsFor(key);
  }

  resetControlsFor(AuthFormKey key) {
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

  _forceValidationMessages(AuthFormKey key) {
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
    if (!form.valid || emailControl.isNullOrEmpty || passwordControl.isNullOrEmpty) {
      return Future.value(AuthResponse());
    }
    return await _signInWith(emailControl.value!, passwordControl.value!);
  }

  Future<AuthResponse> _signInWith(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      final response = await authRepository.signInWith(email: email, password: password);
      if (shouldRemember) {
        _setRememberMe();
      }
      return response;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } finally {
      state = const AsyncValue.data(null);
    }
    _delRememberMe();
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
      return Future.value(null);
    }
    return resetPasswordForEmail(emailControl.value!)
        .then((_) => notificationService.show(Notifications.passwordReset));
  }

  Future<void> recoverPassword() async {
    if (!form.valid) {
      return Future.value(null);
    }
    return updateUser(passwordControl.value!)
        .then((value) {
          final shouldRemember = sharedPreferences.getBool("remember_me") ?? false;
          if (shouldRemember) {
            sharedPreferences.setString('password', passwordControl.value!);
          }
        })
        .then((_) => notificationService.show(Notifications.passwordResetSuccess))
        .then((_) => router.dispatch(RoutingIntents.studies));
  }

  Future<bool> updateUser(String newPassword) async {
    try {
      state = const AsyncValue.loading();
      return (await authRepository.updateUser(newPassword: newPassword)).user != null;
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

  // - Remember Me
  // TODO properly implement this to auto-login instead of autofill

  void _setRememberMe() {
    sharedPreferences.setBool("rememberMe", rememberMeControl.value ?? false);
    sharedPreferences.setString('email', emailControl.value ?? '');
    sharedPreferences.setString('password', passwordControl.value ?? '');
  }

  void _delRememberMe() {
    sharedPreferences.remove("rememberMe");
    sharedPreferences.remove("email");
    sharedPreferences.remove("password");
  }

  void _initRememberMe() async {
    try {
      final email = sharedPreferences.getString("email");
      final password = sharedPreferences.getString("password");
      final rememberMe = sharedPreferences.getBool("rememberMe") ?? false;
      if (rememberMe) {
        rememberMeControl.value = true;
        emailControl.value = email ?? '';
        passwordControl.value = password ?? '';
      }
    } catch (e) {
      emailControl.value = '';
      passwordControl.value = '';
    }
  }
}

final authFormControllerProvider =
    StateNotifierProvider.autoDispose.family<AuthFormController, AsyncValue<void>, AuthFormKey>((ref, formKey) {
  final authFormController = AuthFormController(
    authRepository: ref.watch(authRepositoryProvider),
    sharedPreferences: ref.watch(sharedPreferencesProvider),
    notificationService: ref.watch(notificationServiceProvider),
    router: ref.watch(routerProvider),
  );
  authFormController.formKey = formKey;
  authFormController.resetControlsFor(formKey);
  authFormController.addListener((state) {
    print("authFormController.state updated");
    if (state.hasError) {
      final AuthException error = state.error as AuthException;
      switch (error.message) {
        case "Invalid login credentials":
          authFormController.notificationService.show(Notifications.credentialsInvalid);
          break;
        case "User already registered":
          authFormController.notificationService.show(Notifications.userAlreadyRegistered);
          break;
        default:
          authFormController.notificationService.showMessage(error.message);
      }
    }
  });
  ref.onDispose(() {
    print("authFormControllerProvider.DISPOSE");
  });
  print("authFormControllerProvider");
  return authFormController;
});
