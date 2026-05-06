import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart'; // AÑADIDO para el login temporal
import 'package:cloud_functions/cloud_functions.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'login_page.dart'; // Para volver atrás

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

      // 1. Delegar la creación al Backend (Cloud Function)
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('secureUniversityRegistration');

      await callable.call(<String, dynamic>{
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'name': _nameController.text.trim(),
      });

      debugPrint("🔑 Fase 2: Login temporal para sesión de verificación...");

      // 2. Iniciar sesión en el dispositivo para recuperar las credenciales
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      debugPrint("📧 Fase 3: Disparando correo de verificación...");

      // 3. Disparar el correo de verificación y cerrar sesión
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();

        // Cierre de sesión inmediato (Gatekeeping)
        await FirebaseAuth.instance.signOut();
      }

      if (!mounted) return;
      setState(() => _loading = false);

      // Notificamos éxito y pedimos verificación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registro exitoso. Por favor, verifica tu correo antes de entrar (MIRAR SPAM)."),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );

      // Volvemos al Login
      Navigator.pop(context);

    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      debugPrint("❌ Error de Cloud Function: [${e.code}] - ${e.message}");
      debugPrint("❌ Detalles: ${e.details}");
      String errorMessage = "Error en el registro";

      // Manejo de duplicados y errores de servidor
      if (e.code == 'already-exists') {
        errorMessage = "Este correo ya está registrado. Intenta iniciar sesión.";
      } else if (e.code == 'permission-denied') {
        errorMessage = "Dominio no autorizado. Usa el correo @uab.cat.";
      } else if (e.code == 'invalid-argument') {
        errorMessage = "Datos inválidos. Revisa el formulario.";
      } else if (e.code == 'unavailable') {
        errorMessage = "Servidor fuera de línea. Inténtalo más tarde.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } on FirebaseAuthException catch (e) {
      // Errores durante el login temporal
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de acceso: ${e.message}"), backgroundColor: Colors.red),
      );
    } catch (e) {
      debugPrint("💥 Error inesperado: $e");
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error de conexión."), backgroundColor: Colors.orange),
      );
    }
  }

  // --- VALIDACIÓN Y DISEÑO (Se mantiene igual, solo he limpiado el _validateEmail) ---

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
      appBar: AppBar(title: Text(t.registerTitleAppBar)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(Icons.person_add_alt_1_rounded, size: 56, color: theme.colorScheme.primary),
                        const SizedBox(height: 16),
                        Text(t.registerTitle, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: t.nameLabel, border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.person_outline)),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return t.nameRequired;
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(labelText: t.emailLabel, hintText: '1234567@uab.cat', border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.email_outlined)),
                          validator: _validateEmail,
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
                          validator: (value) => (value == null || value.length < 6) ? t.registerPasswordMinLength : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: t.confirmPasswordLabel,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_reset_outlined),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                            ),
                          ),
                          validator: (value) => (value != _passwordController.text) ? t.passwordsDoNotMatch : null,
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _register,
                            child: _loading ? const CircularProgressIndicator() : Text(t.registerButton),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(onPressed: _loading ? null : () => Navigator.pop(context), child: Text(t.goToLogin)),
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