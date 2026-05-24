import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/gestures.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:unilost_found/core/theme/app_theme.dart';
import 'package:unilost_found/shared/widgets/custom_button.dart';
import 'package:unilost_found/shared/widgets/custom_text_field.dart';
import 'package:unilost_found/core/services/error_handler.dart';
import 'package:unilost_found/shared/utils/app_notifications.dart';
import 'package:unilost_found/features/auth/presentation/pages/login_page.dart';
import 'package:unilost_found/shared/widgets/language_selector_widget.dart';
import 'package:unilost_found/shared/widgets/legal_markdown_dialog.dart';

class RegisterPage extends StatefulWidget {
  final AppSettingsController settingsController;

  const RegisterPage({
    super.key,
    required this.settingsController,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAccepted = false;
  bool _privacyAccepted = false;

  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _termsRecognizer = TapGestureRecognizer()..onTap = _showTerms;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _showPrivacy;
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (context) => const LegalMarkdownDialog(documentName: 'terms'),
    );
  }

  void _showPrivacy() {
    showDialog(
      context: context,
      builder: (context) => const LegalMarkdownDialog(documentName: 'privacy'),
    );
  }

  Future<void> _register() async {
    final t = AppStrings.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_termsAccepted || !_privacyAccepted) {
      AppNotifications.showError(context, t.termsErrorNotAccepted);
      return;
    }

    setState(() => _loading = true);

    try {
      final email = _emailController.text.trim().toLowerCase();
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('secureUniversityRegistration');

      await callable.call(<String, dynamic>{
        'email': email,
        'password': _passwordController.text,
        'name': _nameController.text.trim(),
        'language': widget.settingsController.locale.languageCode,
        'termsAccepted': true,
        'privacyAccepted': true,
        'legalAccepted': true,
        'legalAcceptedAt': ServerValue.timestamp,
      });

      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );

      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        await FirebaseAuth.instance.signOut();
      } else if (userCredential.user != null) {
        // Si por algún motivo ya está verificado, guardamos sesión
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);
      }

      if (!mounted) return;
      setState(() => _loading = false);

      AppNotifications.showSuccess(context, t.registerSuccessMessage);

      Navigator.pop(context);

    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      final errorMessage = ErrorHandler.getMessage(e, t);
      AppNotifications.showError(context, errorMessage);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t.errorConnection,
            softWrap: true,
            overflow: TextOverflow.visible,
          ), 
          backgroundColor: AppTheme.warningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    final t = AppStrings.of(context);
    if (value == null || value.trim().isEmpty) return t.loginEmailRequired;

    final email = value.trim().toLowerCase();
    if (!email.endsWith('@uab.cat')) return t.registerEmailMustBeUab;

    final prefix = email.split('@')[0];
    if (!RegExp(r'^\d{7}$').hasMatch(prefix)) return t.registerNiuInvalid;

    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Icon(
                  Icons.person_add_rounded,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  t.registerTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 32),

                CustomTextField(
                  label: t.nameLabel,
                  hintText: t.nameHint,
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return t.nameRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: t.emailLabel,
                  hintText: t.emailHint,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: t.passwordLabel,
                  hintText: t.passwordHint,
                  controller: _passwordController,
                  isPassword: _obscurePassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.next,
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20),
                  ),
                  validator: (value) => (value == null || value.length < 6) ? t.registerPasswordMinLength : null,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: t.confirmPasswordLabel,
                  hintText: t.confirmPasswordHint,
                  controller: _confirmPasswordController,
                  isPassword: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_reset_rounded,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20),
                  ),
                  validator: (value) => (value != _passwordController.text) ? t.passwordsDoNotMatch : null,
                ),
                const SizedBox(height: 24),

                // Premium Styled Checkboxes
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _termsAccepted,
                          onChanged: (val) {
                            setState(() {
                              _termsAccepted = val ?? false;
                            });
                          },
                          activeColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodyMedium,
                              children: [
                                TextSpan(text: t.acceptTermsPrefix),
                                TextSpan(
                                  text: t.termsAndConditions,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: _termsRecognizer,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _privacyAccepted,
                          onChanged: (val) {
                            setState(() {
                              _privacyAccepted = val ?? false;
                            });
                          },
                          activeColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodyMedium,
                              children: [
                                TextSpan(text: t.acceptPrivacyPrefix),
                                TextSpan(
                                  text: t.privacyPolicy,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: _privacyRecognizer,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                CustomButton(
                  text: t.registerButton,
                  isLoading: _loading,
                  onPressed: (_termsAccepted && _privacyAccepted) ? _register : null,
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t.alreadyHaveAccount,
                      style: theme.textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginPage(
                              settingsController: widget.settingsController,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        t.loginLink,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                LanguageSelectorWidget(settingsController: widget.settingsController),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}