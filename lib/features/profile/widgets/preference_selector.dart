import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../profile_provider.dart';

class PreferenceSelector extends StatefulWidget {
  final String userId;

  const PreferenceSelector({super.key, required this.userId});

  @override
  State<PreferenceSelector> createState() => _PreferenceSelectorState();
}

class _PreferenceSelectorState extends State<PreferenceSelector> {
  late List<String> _selectedCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(context.read<ProfileProvider>().preferences.favoriteCategories);
  }

  void _updatePreferences() {
    context.read<ProfileProvider>().updateFavoriteCategories(
      userId: widget.userId,
      categories: _selectedCategories,
    );
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
    _updatePreferences();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    
    final allCategories = [
      'general', 'technology', 'business', 'sports', 
      'entertainment', 'health', 'science'
    ];

    final categoryNames = {
      'general': 'Tin chính',
      'technology': 'Công nghệ',
      'business': 'Kinh doanh',
      'sports': 'Thể thao',
      'entertainment': 'Giải trí',
      'health': 'Sức khỏe',
      'science': 'Khoa học',
    };

    final categoryIcons = {
      'general': Icons.public_rounded,
      'technology': Icons.computer_rounded,
      'business': Icons.business_center_rounded,
      'sports': Icons.sports_soccer_rounded,
      'entertainment': Icons.movie_rounded,
      'health': Icons.health_and_safety_rounded,
      'science': Icons.science_rounded,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category_rounded, color: colors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Chủ đề yêu thích',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Chọn các chủ đề bạn quan tâm để cá nhân hóa trải nghiệm',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: allCategories.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    categoryIcons[category],
                    size: 16,
                    color: isSelected ? colors.onPrimary : colors.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    categoryNames[category] ?? category,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? colors.onPrimary : colors.onSurface,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (_) => _toggleCategory(category),
              backgroundColor: colors.surface,
              selectedColor: colors.primary,
              checkmarkColor: colors.onPrimary,
              side: BorderSide(
                color: isSelected ? colors.primary : colors.outline.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.primary.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Đã chọn ${_selectedCategories.length} chủ đề',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}