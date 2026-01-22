import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/app_icons.dart';
import '../widgets/custom_appbar.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: CustomAppBar(
        title: context.tr('profile'),
        showThemeToggle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppConstants.primaryColor.withOpacity(
                        0.1,
                      ),
                      child: Icon(
                        AppIcons.user,
                        size: 50,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.displayName ??
                          user?.email?.split('@')[0] ??
                          context.tr('user'),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? context.tr('not_logged_in'),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    if (user != null && !user.emailVerified) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppConstants.warningColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: AppConstants.warningColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              context.tr('email_not_verified'),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppConstants.warningColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Account Info
            _ProfileSection(
              title: context.tr('account_info'),
              children: [
                _ProfileTile(
                  icon: AppIcons.email,
                  title: context.tr('email'),
                  subtitle: user?.email ?? context.tr('not_logged_in'),
                ),
                if (user != null) ...[
                  _ProfileTile(
                    icon: Icons.verified_user_rounded,
                    title: context.tr('email'),
                    subtitle: user.emailVerified
                        ? context.tr('verified')
                        : context.tr('not_verified'),
                    trailing: user.emailVerified
                        ? Icon(
                            Icons.check_circle,
                            color: AppConstants.successColor,
                          )
                        : TextButton(
                            onPressed: () async {
                              final authProvider = context.read<AuthProvider>();
                              final success = await authProvider
                                  .sendEmailVerification();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? context.tr(
                                              'email_verification_sent',
                                            )
                                          : context.tr(
                                              authProvider.errorMessage ??
                                                  'error_occurred',
                                            ),
                                    ),
                                    backgroundColor: success
                                        ? AppConstants.successColor
                                        : AppConstants.errorColor,
                                  ),
                                );
                              }
                            },
                            child: Text(context.tr('confirm')),
                          ),
                  ),
                ],
                _ProfileTile(
                  icon: Icons.access_time_rounded,
                  title: context.tr('created_at'),
                  subtitle:
                      _formatCreatedAt(user?.metadata.creationTime) ??
                      context.tr('no_data'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Actions
            _ProfileSection(
              title: context.tr('security'),
              children: [
                _ProfileTile(
                  icon: Icons.lock_reset_rounded,
                  title: context.tr('change_password'),
                  subtitle: context.tr('change_password'),
                  onTap: () {
                    _showChangePasswordDialog(context);
                  },
                ),
                _ProfileTile(
                  icon: Icons.delete_outline_rounded,
                  title: context.tr('delete_account'),
                  subtitle: context.tr('delete_account_confirm'),
                  isDestructive: true,
                  onTap: () {
                    _showDeleteAccountDialog(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String? _formatCreatedAt(dynamic createdAt) {
    if (createdAt == null) {
      return null;
    }

    try {
      DateTime date;
      if (createdAt is String) {
        date = DateTime.parse(createdAt);
      } else if (createdAt is DateTime) {
        date = createdAt;
      } else {
        return null;
      }

      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return null;
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('change_password')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: InputDecoration(
                  labelText: context.tr('current_password'),
                  hintText: context.tr('current_password'),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: context.tr('new_password'),
                  hintText: context.tr('new_password'),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: context.tr('confirm_password'),
                  hintText: context.tr('confirm_password'),
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('passwords_not_match')),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('invalid_password')),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final authProvider = context.read<AuthProvider>();
              final success = await authProvider.changePassword(
                oldPasswordController.text,
                newPasswordController.text,
              );

              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? context.tr('password_changed')
                          : context.tr(
                              authProvider.errorMessage ??
                                  'password_change_failed',
                            ),
                    ),
                    backgroundColor: success
                        ? AppConstants.successColor
                        : AppConstants.errorColor,
                  ),
                );
              }
            },
            child: Text(context.tr('update')),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('delete_account')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.tr('delete_account_confirm')),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: context.tr('password'),
                  hintText: context.tr('password'),
                  helperText: context.tr('enter_password_to_confirm'),
                ),
                obscureText: true,
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('please_enter_password')),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final authProvider = context.read<AuthProvider>();
              final success = await authProvider.deleteAccount(
                passwordController.text,
              );

              if (context.mounted) {
                Navigator.pop(ctx);
                if (success) {
                  Navigator.pushReplacementNamed(
                    context,
                    AppConstants.routeLogin,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.tr('account_deleted')),
                      backgroundColor: AppConstants.successColor,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.tr(
                          authProvider.errorMessage ??
                              'account_deletion_failed',
                        ),
                      ),
                      backgroundColor: AppConstants.errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
