import 'package:flutter/material.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.colorScheme.primary;
    final subtitleColor = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.75);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  /// Logo / cabecera principal
                  _WelcomeLogo(
                    primaryColor: primaryColor,
                    subtitleColor: subtitleColor ?? primaryColor,
                  ),

                  const SizedBox(height: 46),

                  /// Botón principal
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: primaryColor,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        backgroundColor: isDark
                            ? theme.colorScheme.surface
                            : Colors.transparent,
                      ),
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
                      child: Text(
                        'Acceder',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: primaryColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// Registro
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '¿No tienes una cuenta? ',
                        style: TextStyle(
                          fontSize: 14,
                          color: subtitleColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RegisterPage(
                                settingsController: settingsController,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Regístrate',
                          style: TextStyle(
                            fontSize: 14,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: primaryColor,
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
      ),
    );
  }
}

class _WelcomeLogo extends StatelessWidget {
  final Color primaryColor;
  final Color subtitleColor;

  const _WelcomeLogo({
    required this.primaryColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'UAB',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 120,
            height: 1.5,
            fontWeight: FontWeight.w900,
            color: primaryColor,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Lost & Found',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34,
            height: 1,
            fontWeight: FontWeight.w500,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Encuentra tus objetos perdidos\nen el campus universitario',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            height: 1.35,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }
}