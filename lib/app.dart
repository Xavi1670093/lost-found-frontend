import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:unilost_found/core/theme/app_theme.dart';
import 'package:unilost_found/features/welcome/presentation/pages/welcome_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unilost_found/shared/utils/app_notifications.dart';
import 'package:unilost_found/shared/widgets/main_navigation_page.dart';
import 'package:unilost_found/shared/widgets/custom_button.dart';
import 'package:unilost_found/shared/widgets/legal_markdown_dialog.dart';

class MyApp extends StatelessWidget {
  final AppSettingsController settingsController;

  const MyApp({
    super.key,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'UniLost & Found',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settingsController.themeMode,
          locale: settingsController.locale,
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: const [
            AppStrings.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            final mediaQueryData = MediaQuery.of(context);
            final clampedScaler = mediaQueryData.textScaler.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.25,
            );
            return MediaQuery(
              data: mediaQueryData.copyWith(
                textScaler: clampedScaler,
              ),
              child: child!,
            );
          },
          home: AppRoot(settingsController: settingsController),
        );
      },
    );
  }
}

class AppRoot extends StatefulWidget {
  final AppSettingsController settingsController;

  const AppRoot({
    super.key,
    required this.settingsController,
  });

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/icon/app_icon.png'), context);
  }

  Widget _buildLoadingScreen(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint("ULF_DEBUG: Error loading app icon: $error");
                      return Icon(
                        Icons.inventory_2_outlined,
                        size: 120,
                        color: theme.colorScheme.primary,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen(context);
        }

        final user = snapshot.data;

        if (user != null && user.emailVerified) {
          return FutureBuilder<bool>(
            future: _checkSessionValidity(),
            builder: (context, sessionSnapshot) {
              if (sessionSnapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingScreen(context);
              }

              if (sessionSnapshot.data == true) {
                return LegalBlockWrapper(
                  settingsController: widget.settingsController,
                  child: MainNavigationPage(settingsController: widget.settingsController),
                );
              } else {
                return WelcomePage(settingsController: widget.settingsController);
              }
            },
          );
        }

        return WelcomePage(settingsController: widget.settingsController);
      },
    );
  }

  Future<bool> _checkSessionValidity() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimestamp = prefs.getInt('login_timestamp');

    if (loginTimestamp == null) {
      // Si no hay marca, la creamos ahora para iniciar el contador
      await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);
      return true;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - loginTimestamp;
    const twoWeeks = 14 * 24 * 60 * 60 * 1000;

    if (diff > twoWeeks) {
      await FirebaseAuth.instance.signOut();
      await prefs.remove('login_timestamp');

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final t = AppStrings.of(context);
          AppNotifications.showError(context, t.sessionExpired);
        });
      }
      return false;
    }

    return true;
  }
}

class LegalBlockWrapper extends StatefulWidget {
  final AppSettingsController settingsController;
  final Widget child;

  const LegalBlockWrapper({
    super.key,
    required this.settingsController,
    required this.child,
  });

  @override
  State<LegalBlockWrapper> createState() => _LegalBlockWrapperState();
}

class _LegalBlockWrapperState extends State<LegalBlockWrapper> {
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _isSaving = false;

  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _showTerms;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _showPrivacy;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
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

  Future<void> _acceptPolicies() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      await FirebaseDatabase.instance.ref('users/${user.uid}/legal').update({
        'termsAccepted': true,
        'privacyAccepted': true,
        'legalAccepted': true,
        'legalAcceptedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("ULF_DEBUG: Error saving legal acceptance: $e");
      if (mounted) {
        final t = AppStrings.of(context);
        AppNotifications.showError(context, t.errorConnection);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return widget.child;

    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('users/${user.uid}/legal').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final data = snapshot.data?.snapshot.value;
        bool accepted = false;
        if (data is Map) {
          accepted = (data['termsAccepted'] == true) && (data['privacyAccepted'] == true);
        }

        if (accepted) {
          return widget.child;
        }

        final t = AppStrings.of(context);
        final theme = Theme.of(context);

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.gavel_rounded,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t.legalUpdateRequiredTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.legalUpdateRequiredDesc,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Checkbox Terms
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
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
                      ),
                      const SizedBox(height: 16),
                      
                      // Checkbox Privacy
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
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
                      ),
                      const SizedBox(height: 40),
                      
                      CustomButton(
                        text: t.acceptAndContinue,
                        isLoading: _isSaving,
                        onPressed: (_termsAccepted && _privacyAccepted) ? _acceptPolicies : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}