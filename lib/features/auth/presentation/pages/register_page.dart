import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:unilost_found/core/theme/app_theme.dart';
import 'package:unilost_found/shared/widgets/custom_button.dart';
import 'package:unilost_found/shared/widgets/custom_text_field.dart';

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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _register() async {
    final t = AppStrings.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      debugPrint("📡 Fase 1: Creando cuenta en el servidor...");

      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('secureUniversityRegistration');

      await callable.call(<String, dynamic>{
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'name': _nameController.text.trim(),
      });

      debugPrint("🔑 Fase 2: Login temporal para sesión de verificación...");

      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      debugPrint("📧 Fase 3: Disparando correo de verificación...");

      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
        await FirebaseAuth.instance.signOut();
      }

      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.registerSuccessMessage),
          backgroundColor: AppTheme.successColor,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pop(context);

    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      String errorMessage;

      switch (e.code) {
        case 'already-exists':
          errorMessage = t.errorAlreadyExists;
          break;
        case 'permission-denied':
          errorMessage = t.errorDomainNotAuthorized;
          break;
        case 'invalid-argument':
          errorMessage = t.errorInvalidArgument;
          break;
        case 'unavailable':
          errorMessage = t.errorUnavailable;
          break;
        default:
          errorMessage = t.errorLoginGeneric;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage), 
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      debugPrint("💥 Error inesperado: $e");
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.errorConnection), 
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

    final email = value.trim();
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
                  validator: _validateEmail,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: t.passwordLabel,
                  controller: _passwordController,
                  isPassword: _obscurePassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(_obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20),
                  ),
                  validator: (value) => (value == null || value.length < 6) ? t.registerPasswordMinLength : null,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: t.confirmPasswordLabel,
                  controller: _confirmPasswordController,
                  isPassword: _obscureConfirmPassword,
                  prefixIcon: Icons.lock_reset_rounded,
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20),
                  ),
                  validator: (value) => (value != _passwordController.text) ? t.passwordsDoNotMatch : null,
                ),
                const SizedBox(height: 40),

                CustomButton(
                  text: t.registerButton,
                  isLoading: _loading,
                  onPressed: _register,
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
                      onTap: () => Navigator.pop(context),
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}