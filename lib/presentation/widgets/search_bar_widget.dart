/// Reusable search bar widget with suggestions and clear functionality.
///
/// Provides a styled search input bar that can be embedded in
/// screens throughout the app.
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A reusable search bar widget.
///
/// Displays a rounded search field with optional hint text,
/// recent suggestions, and clear button.
class QuranSearchBar extends StatefulWidget {
  /// The search controller for text input.
  final TextEditingController controller;

  /// Placeholder text shown when empty.
  final String hintText;

  /// Recent search suggestions to show.
  final List<String> recentSearches;

  /// Called when the search query changes.
  final ValueChanged<String>? onChanged;

  /// Called when the search is submitted.
  final ValueChanged<String>? onSubmitted;

  /// Called when the search is cleared.
  final VoidCallback? onClear;

  /// Called when a recent suggestion is tapped.
  final ValueChanged<String>? onSuggestionTap;

  /// Whether to show suggestions dropdown.
  final bool showSuggestions;

  /// Focus node for the search field.
  final FocusNode? focusNode;

  const QuranSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Sura yoki oyat izlash...',
    this.recentSearches = const [],
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onSuggestionTap,
    this.showSuggestions = true,
    this.focusNode,
  });

  @override
  State<QuranSearchBar> createState() => _QuranSearchBarState();
}

class _QuranSearchBarState extends State<QuranSearchBar> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = widget.controller.text.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search input
        Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused
                  ? AppTheme.primaryColor
                  : AppTheme.primaryColor.withOpacity(0.2),
              width: _isFocused ? 2 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.search,
                  key: ValueKey(_isFocused),
                  color: _isFocused
                      ? AppTheme.primaryColor
                      : Colors.grey.shade400,
                ),
              ),
              suffixIcon: hasText
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onClear?.call();
                        setState(() {});
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            textInputAction: TextInputAction.search,
            onChanged: (value) {
              setState(() {});
              widget.onChanged?.call(value);
            },
            onSubmitted: widget.onSubmitted,
          ),
        ),
        // Suggestions dropdown
        if (widget.showSuggestions &&
            _isFocused &&
            widget.recentSearches.isNotEmpty &&
            !hasText)
          _buildSuggestions(theme),
      ],
    );
  }

  Widget _buildSuggestions(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Yaqinda qidirilganlar',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ...widget.recentSearches.take(5).map(
                (search) => ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.history,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                  title: Text(
                    search,
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    widget.controller.text = search;
                    widget.onSuggestionTap?.call(search);
                    setState(() {});
                  },
                ),
              ),
        ],
      ),
    );
  }
}
