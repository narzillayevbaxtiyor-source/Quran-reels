/// Reciter selection screen for choosing Quran recitation style.
///
/// Displays a grid of available reciters with preview capability
/// and allows the user to select their preferred reciter.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/audio_provider.dart';

/// Screen for selecting a Quran reciter.
class ReciterSelectionScreen extends ConsumerStatefulWidget {
  const ReciterSelectionScreen({super.key});

  @override
  ConsumerState<ReciterSelectionScreen> createState() =>
      _ReciterSelectionScreenState();
}

class _ReciterSelectionScreenState
    extends ConsumerState<ReciterSelectionScreen> {
  String? _selectedReciterId;
  bool _isLoading = false;

  /// List of popular reciters with metadata.
  static const List<Map<String, dynamic>> _recitersList = [
    {
      'identifier': 'ar.alafasy',
      'name': 'Mishary Rashid Alafasy',
      'nameArabic': 'مشاري راشد العفاسي',
      'description': 'Mashhur Quvaytlik qori',
      'style': 'Mujawwad',
    },
    {
      'identifier': 'ar.husary',
      'name': 'Mahmoud Khalil Al-Husary',
      'nameArabic': 'محمود خليل الحصري',
      'description': 'Misrlik mashhur qori',
      'style': 'Murattal',
    },
    {
      'identifier': 'ar.abdulbasit',
      'name': 'Abdul Basit Abdus Samad',
      'nameArabic': 'عبد الباسط عبد الصمد',
      'description': 'Oltin ovozli Misrlik qori',
      'style': 'Mujawwad',
    },
    {
      'identifier': 'ar.sudais',
      'name': 'Abdul Rahman Al-Sudais',
      'nameArabic': 'عبد الرحمن السديس',
      'description': "Masjid Al-Haram imomi",
      'style': 'Murattal',
    },
    {
      'identifier': 'ar.ahmedajamy',
      'name': 'Ahmed Al-Ajamy',
      'nameArabic': 'أحمد العجمي',
      'description': "Saudiyalik mashhur qori",
      'style': 'Murattal',
    },
    {
      'identifier': 'ar.aymanswoaid',
      'name': 'Ayman Sowaid',
      'nameArabic': 'أيمن سويد',
      'description': 'Tajvid mutaxassisi',
      'style': 'Murattal',
    },
    {
      'identifier': 'ar.minshawi',
      'name': 'Mohamed Siddiq Al-Minshawi',
      'nameArabic': 'محمد صديق المنشاوي',
      'description': 'Misrlik mashhur qori',
      'style': 'Mujawwad',
    },
    {
      'identifier': 'ar.mahermuaiqly',
      'name': 'Maher Al-Muaiqly',
      'nameArabic': 'ماهر المعيقلي',
      'description': "Masjid Al-Haram imomi",
      'style': 'Murattal',
    },
  ];

  @override
  void initState() {
    super.initState();
    final currentReciter = ref.read(audioProvider).currentReciter;
    _selectedReciterId = currentReciter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audioState = ref.watch(audioProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Qori tanlash',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current selection
          _buildCurrentSelection(audioState, theme),
          const SizedBox(height: 24),
          // Reciters grid
          Text(
            'Barcha qorilar',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          ..._recitersList.map((reciter) => _buildReciterTile(
                reciter: reciter,
                isSelected: _selectedReciterId == reciter['identifier'],
                theme: theme,
                onTap: () => _selectReciter(reciter['identifier'] as String),
              )),
          const SizedBox(height: 32),
          // Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppTheme.primaryColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tanlagan qoringiz barcha audio ijrosi uchun ishlatiladi. '
                    'Istalgan vaqtda o\'zgartirishingiz mumkin.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSelection(AudioState audioState, ThemeData theme) {
    final currentReciter = _recitersList.firstWhere(
      (r) => r['identifier'] == _selectedReciterId,
      orElse: () => _recitersList.first,
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            const Text(
              'Joriy qori',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              currentReciter['name'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              currentReciter['nameArabic'] as String,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontFamily: 'Uthmani',
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${currentReciter['style']} uslubi',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReciterTile({
    required Map<String, dynamic> reciter,
    required bool isSelected,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? const BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Reciter avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  color: isSelected ? Colors.white : AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reciter['name'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppTheme.primaryColor : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reciter['description'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Arabic name and select indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    reciter['nameArabic'] as String,
                    style: const TextStyle(
                      fontFamily: 'Uthmani',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryColor,
                      size: 22,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        reciter['style'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectReciter(String identifier) async {
    setState(() {
      _isLoading = true;
      _selectedReciterId = identifier;
    });

    // Update the audio provider
    ref.read(audioProvider.notifier).setReciter(identifier);

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Qori muvaffaqiyatli o\'zgartirildi'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.primaryColor,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
