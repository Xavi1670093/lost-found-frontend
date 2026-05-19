import 'package:flutter/material.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';

class LanguageSelectorWidget extends StatelessWidget {
  final AppSettingsController settingsController;

  const LanguageSelectorWidget({
    super.key,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocale = settingsController.locale;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final languages = [
      {'code': 'es', 'label': 'ES'},
      {'code': 'ca', 'label': 'CA'},
      {'code': 'en', 'label': 'EN'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: languages.map((lang) {
        final isSelected = currentLocale.languageCode == lang['code'];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: GestureDetector(
            onTap: () {
              if (!isSelected) {
                settingsController.setLocale(Locale(lang['code']!));
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isDark ? Colors.grey[850] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Text(
                lang['label']!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
