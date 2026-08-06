/// Settings screen for customizing app behavior.
///
/// Provides settings for:
/// - Theme mode selection
/// - Reciter selection
/// - Playback speed
/// - Audio quality
/// - Notifications
/// - Data management
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../providers/audio_provider.dart';

/// Detailed settings and preferences screen.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final audioState = ref.watch(audioProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sozlamalar',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader('Ko\'rinish', Icons.palette_outlined, theme),
          const SizedBox(height: 8),
          _buildThemeCard(themeMode, ref, theme),
          const SizedBox(height: 24),

          // Audio Section
          _buildSectionHeader('Audio', Icons.music_note_outlined, theme),
          const SizedBox(height: 8),
          _buildReciterCard(audioState, theme),
          const SizedBox(height: 8),
          _buildPlaybackSpeedCard(audioState, ref, theme),
          const SizedBox(height: 8),
          _buildAudioQualityCard(theme),
          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader('Bildirishnomalar', Icons.notifications_outlined, theme),
          const SizedBox(height: 8),
          _buildNotificationCard(theme),
          const SizedBox(height: 24),

          // Data Section
          _buildSectionHeader("Ma'lumotlar", Icons.storage_outlined, theme),
          const SizedBox(height: 8),
          _buildCacheCard(theme),
          const SizedBox(height: 8),
          _buildDataSyncCard(theme),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('Ilova haqida', Icons.info_outline, theme),
          const SizedBox(height: 8),
          _buildAboutCard(theme),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeCard(
      AppThemeMode currentMode, WidgetRef ref, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(currentMode.icon, size: 24, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Mavzu rejimi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    currentMode.label,
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: AppThemeMode.values.map((mode) {
                final isSelected = currentMode == mode;
                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(themeModeProvider.notifier).setThemeMode(mode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        right: mode != AppThemeMode.values.last ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            mode.icon,
                            color: isSelected ? Colors.white : AppTheme.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mode.label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReciterCard(AudioState audioState, ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.mic, color: AppTheme.primaryColor, size: 24),
        ),
        title: const Text('Qori tanlash',
            style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          _getReciterDisplayName(audioState.currentReciter),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to reciter selection
        },
      ),
    );
  }

  Widget _buildPlaybackSpeedCard(
      AudioState audioState, WidgetRef ref, ThemeData theme) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.speed, color: AppTheme.primaryColor, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Ijro tezligi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${audioState.playbackSpeed}x',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: speeds.map((speed) {
                final isSelected =
                    (speed - audioState.playbackSpeed).abs() < 0.01;
                return ChoiceChip(
                  label: Text('${speed}x'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(audioProvider.notifier).setSpeed(speed);
                    }
                  },
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioQualityCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.high_quality, color: AppTheme.primaryColor, size: 24),
        ),
        title: const Text('Audio sifati',
            style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('Yuqori (128kbps)',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  Widget _buildNotificationCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.notifications_active,
                  color: AppTheme.primaryColor, size: 24),
            ),
            title: const Text('Kunlik eslatma',
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('Har kuni bir oyat o\'qing',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            value: true,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) {},
          ),
          const Divider(height: 1, indent: 72),
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.settings_suggest,
                  color: AppTheme.primaryColor, size: 24),
            ),
            title: const Text('Yangi suralar',
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('Yangi tarjimalar haqida xabar',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            value: false,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildCacheCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.cleaning_services_outlined,
              color: AppTheme.primaryColor, size: 24),
        ),
        title: const Text("Keshni tozalash",
            style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('12.5 MB',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        trailing: TextButton(
          onPressed: () {},
          child: const Text('Tozalash'),
        ),
      ),
    );
  }

  Widget _buildDataSyncCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.cloud_sync,
              color: AppTheme.primaryColor, size: 24),
        ),
        title: const Text('Sinxronizatsiya',
            style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text("Xatcho'plarni bulutga saqlash",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        value: true,
        activeColor: AppTheme.primaryColor,
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildAboutCard(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.info_outline,
                  color: AppTheme.primaryColor, size: 24),
            ),
            title: const Text('Versiya',
                style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Text('1.0.0',
                style: TextStyle(color: Colors.grey, fontSize: 14)),
          ),
          const Divider(height: 1, indent: 72),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.star_outline,
                  color: AppTheme.primaryColor, size: 24),
            ),
            title: const Text('Ilovani baholash',
                style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 72),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.share,
                  color: AppTheme.primaryColor, size: 24),
            ),
            title: const Text('Do\'stlarga ulashish',
                style: TextStyle(fontWeight: FontWeight.w500)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  String _getReciterDisplayName(String reciterId) {
    const reciters = {
      'ar.alafasy': 'Mishary Rashid Alafasy',
      'ar.husary': 'Mahmoud Khalil Al-Husary',
      'ar.ahmedajamy': 'Ahmed Al-Ajamy',
      'ar.abdulbasit': 'Abdul Basit',
      'ar.sudais': 'Abdul Rahman Al-Sudais',
    };
    return reciters[reciterId] ?? 'Mishary Alafasy';
  }
}
