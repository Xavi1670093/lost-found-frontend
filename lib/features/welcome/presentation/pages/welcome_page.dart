import 'package:flutter/material.dart';
import 'package:unilost_found/shared/widgets/custom_button.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:unilost_found/features/auth/presentation/pages/login_page.dart';
import 'package:unilost_found/features/auth/presentation/pages/register_page.dart';

class WelcomePage extends StatelessWidget {
  final AppSettingsController settingsController;

  const WelcomePage({
    super.key,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Restored UAB Logo
                const _WelcomeLogo(),
                const SizedBox(height: 64),
                // Buttons
                CustomButton(
                  text: 'Iniciar Sesión',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginPage(
                          settingsController: settingsController,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Crear Cuenta',
                  isPrimary: false,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RegisterPage(
                          settingsController: settingsController,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeLogo extends StatelessWidget {
  const _WelcomeLogo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final subtitleColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.75);

    return Column(
      children: [
        Text(
          'UAB',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 100,
            height: 1.2,
            fontWeight: FontWeight.w900,
            color: primaryColor,
            letterSpacing: 1,
          ),
        ),
        Text(
          'Lost & Found',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            height: 1,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Encuentra tus objetos perdidos\nen el campus universitario',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            height: 1.4,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }
}