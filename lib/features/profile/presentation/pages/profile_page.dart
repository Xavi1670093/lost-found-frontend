import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/settings/app_settings_controller.dart';
import 'package:unilost_found/shared/widgets/custom_card.dart';
import 'package:unilost_found/shared/widgets/skeleton_loader.dart';
import 'user_posts_page.dart';

class ProfilePage extends StatefulWidget {
  final AppSettingsController settingsController;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.settingsController,
    required this.onLogout,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
    }

    final DatabaseReference userRef = FirebaseDatabase.instance.ref('users/${user.uid}');

    return StreamBuilder<DatabaseEvent>(
      stream: userRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSkeleton(theme);
        }

        String userName = t.loading;
        String userRole = t.studentRole;
        String centerId = "UAB";

        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          final data = Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
          userName = data['name'] ?? t.defaultUserName;
          userRole = data['role'] == 'admin' ? t.adminRole : t.studentRole;
          centerId = (data['center_id'] ?? "uab").toString().toLowerCase();
        }

        return AnimatedBuilder(
          animation: widget.settingsController,
          builder: (context, _) {
            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  child: Icon(Icons.person_rounded, size: 50, color: theme.colorScheme.primary),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _showEditNameDialog(userName, userRef),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: theme.colorScheme.secondary, shape: BoxShape.circle),
                                    child: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            userName,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ?? "",
                            style: TextStyle(color: Colors.white.withOpacity(0.8)),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "$userRole | $centerId",
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSectionTitle(t.myActivity, theme),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionCard(
                                Icons.inventory_2_outlined,
                                t.myFindings,
                                theme.colorScheme.primary,
                                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserPostsPage(type: 'found'))),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionCard(
                                Icons.search_rounded,
                                t.myLosses,
                                theme.colorScheme.secondary,
                                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserPostsPage(type: 'lost'))),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                        _buildSectionTitle(t.settingsTitle, theme),
                        const SizedBox(height: 12),
                        
                        CustomCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              SwitchListTile(
                                secondary: Icon(Icons.dark_mode_outlined, color: theme.colorScheme.primary),
                                title: Text(t.darkMode),
                                value: widget.settingsController.isDarkMode,
                                onChanged: (v) => widget.settingsController.setDarkMode(v),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: Icon(Icons.language_outlined, color: theme.colorScheme.primary),
                                title: Text(t.language),
                                subtitle: Text(_languageLabel(context, widget.settingsController.locale.languageCode)),
                                trailing: DropdownButton<String>(
                                  value: widget.settingsController.locale.languageCode,
                                  underline: const SizedBox(),
                                  items: [
                                    DropdownMenuItem(value: 'es', child: Text(t.spanish)),
                                    DropdownMenuItem(value: 'ca', child: Text(t.catalan)),
                                    DropdownMenuItem(value: 'en', child: Text(t.english)),
                                  ],
                                  onChanged: (v) => v != null ? widget.settingsController.setLocale(Locale(v)) : null,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                        Center(
                          child: TextButton.icon(
                            onPressed: widget.onLogout,
                            icon: const Icon(Icons.logout_rounded, color: Colors.red),
                            label: Text(t.logout, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              backgroundColor: Colors.red.withOpacity(0.05),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditNameDialog(String currentName, DatabaseReference ref) {
    final t = AppStrings.of(context);
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(t.editNameTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: t.newNameLabel,
            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await ref.update({'name': controller.text.trim(), 'updated_at': DateTime.now().millisecondsSinceEpoch});
                if (mounted) Navigator.pop(context);
              }
            },
            child: Text(t.save),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelMedium?.copyWith(
        letterSpacing: 1.2,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, Color color, VoidCallback onTap) {
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSkeleton(ThemeData theme) {
    return Scaffold(
      body: Column(
        children: [
          SkeletonLoader(
            height: 250,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: 150, height: 20),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: SkeletonLoader(height: 100, borderRadius: BorderRadius.circular(16))),
                    const SizedBox(width: 16),
                    Expanded(child: SkeletonLoader(height: 100, borderRadius: BorderRadius.circular(16))),
                  ],
                ),
                const SizedBox(height: 32),
                SkeletonLoader(width: 150, height: 20),
                const SizedBox(height: 16),
                SkeletonLoader(height: 120, borderRadius: BorderRadius.circular(16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _languageLabel(BuildContext context, String code) {
    final t = AppStrings.of(context);
    switch (code) {
      case 'ca': return t.catalan;
      case 'en': return t.english;
      default: return t.spanish;
    }
  }
}
