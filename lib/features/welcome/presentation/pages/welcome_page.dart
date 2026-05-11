import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
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
    final t = AppStrings.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _WelcomeLogo(),
                const SizedBox(height: 64),
                CustomButton(
                  text: t.loginButton,
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
                  text: t.registerButton,
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
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Column(
      children: [
        Text(
          'UAB',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 100,
            height: 1.2,
            fontWeight: FontWeight.w900,
            color: primaryColor,
            letterSpacing: -2,
          ),
        ),
        Text(
          'Lost & Found',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 28,
            height: 1,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          t.welcomeTagline,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}