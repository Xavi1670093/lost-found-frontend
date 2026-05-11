import 'package:flutter/material.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:unilost_found/core/theme/app_theme.dart';
import 'package:unilost_found/shared/widgets/custom_button.dart';
import 'package:unilost_found/shared/widgets/custom_text_field.dart';
import 'package:unilost_found/features/auth/presentation/pages/register_page.dart';
import 'package:unilost_found/shared/widgets/main_navigation_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  final AppSettingsController settingsController;

  const LoginPage({
    super.key,
    required this.settingsController,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  String? _validateUabEmail(String? value) {
    final t = AppStrings.of(context);
    if (value == null || value.trim().isEmpty) {
      return t.loginEmailRequired;
    }
    final email = value.trim();
    final uabRegex = RegExp(r'^\d{7}@uab\.cat$');
    if (!uabRegex.hasMatch(email)) {
      return t.loginEmailInvalid;
    }
    return null;
  }

  Future<void> _login() async {
    final t = AppStrings.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      debugPrint("🔑 Intentando login REAL para: ${_emailController.text}");

      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        debugPrint("⚠️ Usuario no verificado. Forzando logout.");
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;
        setState(() => _loading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.verifyEmailMessage),
            backgroundColor: AppTheme.warningColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      debugPrint("✅ Login exitoso y verificado. UID: ${userCredential.user?.uid}");

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavigationPage(
            settingsController: widget.settingsController,
          ),
        ),
        (route) => false,
      );

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });

      String message;
      switch (e.code) {
        case 'user-not-found':
          message = t.errorUserNotFound;
          break;
        case 'wrong-password':
          message = t.errorWrongPassword;
          break;
        case 'invalid-email':
          message = t.errorInvalidEmail;
          break;
        case 'user-disabled':
          message = t.errorUserDisabled;
          break;
        case 'too-many-requests':
          message = t.errorTooManyRequests;
          break;
        default:
          message = t.errorLoginGeneric;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      debugPrint("💥 Error inesperado: $e");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                const SizedBox(height: 20),
                Icon(
                  Icons.lock_person_rounded,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 32),
                Text(
                  t.loginTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),

                CustomTextField(
                  label: t.uabEmailLabel,
                  hintText: t.emailHint,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: _validateUabEmail,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: t.passwordLabel,
                  controller: _passwordController,
                  isPassword: _obscurePassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                      size: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.passwordRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                CustomButton(
                  text: t.loginButton,
                  isLoading: _loading,
                  onPressed: _login,
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t.dontHaveAccount,
                      style: theme.textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterPage(
                              settingsController: widget.settingsController,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        t.signUpLink,
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