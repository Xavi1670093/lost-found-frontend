import 'package:flutter/material.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:unilost_found/shared/widgets/main_navigation_page.dart';
// --- NUEVOS IMPORTS PARA LA INTEGRACIÓN (Iteración 2) ---
import 'package:cloud_functions/cloud_functions.dart';

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
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // --- LÓGICA DE REGISTRO SEGURO (RF01 / RNF03) ---
  Future<void> _register() async {
    final t = AppStrings.of(context);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 1. Llamamos a la Cloud Function definida en el Backend
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('secureUniversityRegistration');

      // 2. Enviamos los parámetros exactos que espera el servidor
      await callable.call(<String, dynamic>{
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'name': _nameController.text.trim(),
      });

      // 3. Si no hay error, el registro fue exitoso
      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.registerSuccess)),
      );

      // Navegación a la pantalla principal tras registro exitoso
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavigationPage(
            settingsController: widget.settingsController,
          ),
        ),
      );

    } on FirebaseFunctionsException catch (e) {
      // 4. Gestión de errores específicos del Backend
      setState(() => _loading = false);

      String errorMessage = "Error en el registro";

      if (e.code == 'already-exists') {
        errorMessage = "Este correo ya está registrado en la plataforma.";
      } else if (e.code == 'permission-denied') {
        errorMessage = "Dominio no autorizado. Debes usar tu correo de la UAB.";
      } else if (e.code == 'invalid-argument') {
        errorMessage = "Datos inválidos. Por favor, revisa el formulario.";
      } else if (e.code == 'unavailable') {
        errorMessage = "El servicio de tu centro está temporalmente inactivo.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // Error genérico de red o sistema
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error de conexión. Inténtalo de nuevo."),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final t = AppStrings.of(context);

    if (value == null || value.trim().isEmpty) {
      return t.loginEmailRequired;
    }

    final email = value.trim();

    if (!email.endsWith('@uab.cat')) {
      return t.registerEmailMustBeUab;
    }

    final prefix = email.split('@')[0];

    if (!RegExp(r'^\d{7}$').hasMatch(prefix)) {
      return t.registerNiuInvalid;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.registerTitleAppBar),
      ),
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
                        Icon(
                          Icons.person_add_alt_1_rounded,
                          size: 56,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t.registerTitle,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.registerSubtitle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: t.nameLabel,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return t.nameRequired;
                            }
                            if (value.trim().length < 2) {
                              return t.nameTooShort;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: t.emailLabel,
                            hintText: '1234567@uab.cat',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: t.passwordLabel,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return t.registerPasswordRequired;
                            }
                            if (value.length < 6) {
                              return t.registerPasswordMinLength;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            if (!_loading) {
                              _register();
                            }
                          },
                          decoration: InputDecoration(
                            labelText: t.confirmPasswordLabel,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_reset_outlined),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return t.confirmPasswordRequired;
                            }
                            if (value != _passwordController.text) {
                              return t.passwordsDoNotMatch;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _register,
                            child: _loading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                                : Text(t.registerButton),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: _loading ? null : () => Navigator.pop(context),
                          child: Text(t.goToLogin),
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