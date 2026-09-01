import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilter;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.onFilterTap,
    this.hasActiveFilter = false,
    this.hintText = 'Dilek veya mağaza ara...',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onChanged,
            style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        if (onFilterTap != null) ...[
          const SizedBox(width: 10),
          Material(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasActiveFilter
                        ? AppColors.cherryAccent
                        : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                  ),
                ),
                child: Badge(
                  isLabelVisible: hasActiveFilter,
                  backgroundColor: AppColors.cherryAccent,
                  smallSize: 8,
                  child: Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: hasActiveFilter
                        ? AppColors.cherryAccent
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
