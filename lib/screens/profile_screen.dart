import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/app_icons.dart';
import '../widgets/custom_appbar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Profil',
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
                      backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                      child: Icon(
                        AppIcons.user,
                        size: 50,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.displayName ?? 'Kullanıcı',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? 'Offline Mod',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (user?.emailVerified == false) ...[
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
                              'E-posta doğrulanmamış',
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
              title: 'Hesap Bilgileri',
              children: [
                _ProfileTile(
                  icon: AppIcons.email,
                  title: 'E-posta',
                  subtitle: user?.email ?? 'Offline Mod',
                ),
                if (user != null) ...[
                  _ProfileTile(
                    icon: Icons.verified_user_rounded,
                    title: 'E-posta Doğrulama',
                    subtitle: user.emailVerified ? 'Doğrulanmış' : 'Doğrulanmamış',
                    trailing: user.emailVerified
                        ? Icon(Icons.check_circle, color: AppConstants.successColor)
                        : TextButton(
                            onPressed: () {
                              // TODO: Email verification
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('E-posta doğrulama özelliği yakında eklenecek'),
                                ),
                              );
                            },
                            child: const Text('Doğrula'),
                          ),
                  ),
                ],
                _ProfileTile(
                  icon: Icons.access_time_rounded,
                  title: 'Üyelik Tarihi',
                  subtitle: user?.metadata.creationTime != null
                      ? '${user!.metadata.creationTime!.day}/${user.metadata.creationTime!.month}/${user.metadata.creationTime!.year}'
                      : 'Bilinmiyor',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Actions
            _ProfileSection(
              title: 'İşlemler',
              children: [
                _ProfileTile(
                  icon: Icons.lock_reset_rounded,
                  title: 'Şifre Değiştir',
                  subtitle: 'Hesap şifrenizi değiştirin',
                  onTap: () {
                    _showChangePasswordDialog(context);
                  },
                ),
                _ProfileTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Hesabı Sil',
                  subtitle: 'Hesabınızı kalıcı olarak silin',
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

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Değiştir'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Mevcut Şifre',
                  hintText: 'Mevcut şifrenizi girin',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Yeni Şifre',
                  hintText: 'Yeni şifrenizi girin',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Yeni Şifre Tekrar',
                  hintText: 'Yeni şifrenizi tekrar girin',
                ),
                obscureText: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Yeni şifreler eşleşmiyor'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (newPasswordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Şifre en az 6 karakter olmalıdır'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // TODO: Implement password change
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Şifre değiştirme özelliği yakında eklenecek'),
                ),
              );
            },
            child: const Text('Değiştir'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz ve tüm verileriniz silinecektir.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hesap silme özelliği yakında eklenecek'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
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
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}

