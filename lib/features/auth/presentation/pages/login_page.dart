import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Directo a Firebase
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:unilost_found/features/auth/presentation/pages/register_page.dart';
import 'package:unilost_found/shared/widgets/main_navigation_page.dart';

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

  bool _obscurePassword = true;
  bool _isLoading = false;      // Gestión de carga local
  String? _errorMessage;       // Gestión de error local

  String? _validateUabEmail(String? value) {
    final t = AppStrings.of(context);
    if (value == null || value.trim().isEmpty) return t.loginEmailRequired;
    final email = value.trim();
    final uabRegex = RegExp(r'^\d{7}@uab\.cat$');
    if (!uabRegex.hasMatch(email)) return t.loginEmailInvalid;
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print("🔑 Intentando login: ${_emailController.text}");
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print("✅ Login exitoso");

      if (!mounted) return;
      setState(() => _isLoading = false);

      // --- AQUÍ ESTÁ LA NAVEGACIÓN MÁGICA ---
      // Usamos pushReplacement para que el usuario no pueda volver atrás al login con el botón del móvil
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainNavigationPage(
            settingsController: widget.settingsController,
          ),
        ),
      );

    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') _errorMessage = "Usuario no registrado";
        else if (e.code == 'wrong-password') _errorMessage = "Contraseña incorrecta";
        else _errorMessage = e.message;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.loginTitleAppBar)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.lock_person_rounded, size: 64, color: theme.colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(t.loginTitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),

                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(color: Colors.red.shade50, border: Border.all(color: Colors.red), borderRadius: BorderRadius.circular(8)),
                            child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700)),
                          ),

                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(labelText: t.uabEmailLabel, hintText: '1234567@uab.cat', border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.badge_outlined)),
                          validator: _validateUabEmail,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: t.passwordLabel,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            ),
                          ),
                          validator: (value) => (value == null || value.length < 6) ? t.passwordMinLength : null,
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading ? const CircularProgressIndicator() : Text(t.loginButton),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage(settingsController: widget.settingsController))),
                          child: Text(t.goToRegister),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}