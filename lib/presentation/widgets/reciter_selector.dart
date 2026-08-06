/// Reciter selector widget as a bottom sheet.
///
/// Provides a quick inline UI for switching between reciters
/// without navigating to the full selection screen.
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A bottom sheet widget for quick reciter selection.
class ReciterSelector extends StatelessWidget {
  /// The currently selected reciter identifier.
  final String currentReciter;

  /// Called when a new reciter is selected.
  final ValueChanged<Map<String, dynamic>> onSelected;

  const ReciterSelector({
    super.key,
    required this.currentReciter,
    required this.onSelected,
  });

  /// Static reciters data shared across the app.
  static const List<Map<String, dynamic>> reciters = [
    {
      'identifier': 'ar.alafasy',
      'name': 'Mishary Alafasy',
      'nameArabic': 'مشاري العفاسي',
      'country': 'Quvayt',
    },
    {
      'identifier': 'ar.husary',
      'name': 'Mahmoud Al-Husary',
      'nameArabic': 'محمود الحصري',
      'country': 'Misr',
    },
    {
      'identifier': 'ar.sudais',
      'name': 'Abdul Rahman Al-Sudais',
      'nameArabic': 'عبد الرحمن السديس',
      'country': "Saudiya Arabistoni",
    },
    {
      'identifier': 'ar.abdulbasit',
      'name': 'Abdul Basit',
      'nameArabic': 'عبد الباسط',
      'country': 'Misr',
    },
  ];

  /// Shows the reciter selector as a modal bottom sheet.
  static Future<Map<String, dynamic>?> show(
    BuildContext context,
    String currentReciter,
  ) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ReciterSelector(
          currentReciter: currentReciter,
          onSelected: (reciter) {
            Navigator.pop(context, reciter);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Text(
            'Qori tanlash',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "O'zingizga yoqqan qorini tanlang",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          // Reciter list
          ...reciters.map((reciter) {
            final isSelected = reciter['identifier'] == currentReciter;
            return _ReciterOption(
              name: reciter['name'] as String,
              nameArabic: reciter['nameArabic'] as String,
              country: reciter['country'] as String,
              isSelected: isSelected,
              onTap: () => onSelected(reciter),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Individual reciter option in the selector.
class _ReciterOption extends StatelessWidget {
  final String name;
  final String nameArabic;
  final String country;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReciterOption({
    required this.name,
    required this.nameArabic,
    required this.country,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.3)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Mic icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.mic,
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            // Name and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppTheme.primaryColor : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        country,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        nameArabic,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                          fontFamily: 'Uthmani',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Checkmark
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
