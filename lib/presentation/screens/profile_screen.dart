/// Profile screen showing user details and settings.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../providers/auth_provider.dart';

/// User profile and settings screen.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Profile Card
          if (authState.isAuthenticated)
            _buildUserProfileCard(theme, authState)
          else
            _buildLoginCard(theme),
          const SizedBox(height: 24),
          // Settings Section
          _buildSectionHeader(theme, 'Sozlamalar'),
          const SizedBox(height: 8),
          // Theme settings
          _buildThemeTile(theme, themeMode, ref),
          // Reciter settings
          _buildReciterTile(theme),
          // Playback speed
          _buildPlaybackSpeedTile(theme),
          // About section
          const SizedBox(height: 24),
          _buildSectionHeader(theme, 'Ilova haqida'),
          const SizedBox(height: 8),
          _buildAboutTile(theme, 'Ilova haqida', Icons.info_outline, () {}),
          _buildAboutTile(
              theme, 'Fikr bildirish', Icons.feedback_outlined, () {}),
          _buildAboutTile(theme, 'Baholash', Icons.star_outline, () {}),
          _buildAboutTile(
              theme, 'Maxfiylik siyosati', Icons.privacy_tip_outlined, () {}),
          _buildAboutTile(
              theme, 'Foydalanish shartlari', Icons.description_outlined, () {}),
          const Divider(height: 32),
          // Version info
          Center(
            child: Text(
              'QuranReels v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Logout
          if (authState.isAuthenticated) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => ref.read(authProvider.notifier).signOut(),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Chiqish',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard(ThemeData theme, AuthState authState) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppTheme.primaryColor,
              backgroundImage: authState.user?.photoUrl != null
                  ? NetworkImage(authState.user!.photoUrl!)
                  : null,
              child: authState.user?.photoUrl == null
                  ? Text(
                      (authState.user?.displayName ?? 'F')
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authState.user?.displayName ?? 'Foydalanuvchi',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authState.user?.email ?? '',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.account_circle,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              'Tizimga kiring',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Xatcho\'plaringizni saqlash va sinxronizatsiya qilish uchun',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to auth screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Kirish / Ro\'yxatdan o\'tish',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildThemeTile(
      ThemeData theme, AppThemeMode currentMode, WidgetRef ref) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            const SizedBox(width: 8),
            const Icon(Icons.palette_outlined, size: 22),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Mavzu', style: TextStyle(fontSize: 15)),
            ),
            // Theme toggle buttons
            SegmentedButton<AppThemeMode>(
              segments: AppThemeMode.values.map((mode) {
                return ButtonSegment<AppThemeMode>(
                  value: mode,
                  icon: Icon(mode.icon, size: 18),
                  label: Text(
                    mode.label,
                    style: const TextStyle(fontSize: 11),
                  ),
                );
              }).toList(),
              selected: {currentMode},
              onSelectionChanged: (selected) {
                ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(selected.first);
              },
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildReciterTile(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.mic_outlined, size: 22),
        title: const Text('Qori', style: TextStyle(fontSize: 15)),
        subtitle: Text(
          'Mishary Alafasy',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Show reciter selection
        },
      ),
    );
  }

  Widget _buildPlaybackSpeedTile(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.speed_outlined, size: 22),
        title: const Text('Ijro tezligi', style: TextStyle(fontSize: 15)),
        subtitle: Text(
          '1.0x',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  Widget _buildAboutTile(
      ThemeData theme, String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(top: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 22),
        title: Text(title, style: const TextStyle(fontSize: 15)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
