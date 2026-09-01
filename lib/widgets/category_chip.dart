import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        child: Material(
          color: isSelected
              ? AppColors.cherryAccent
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.cherryAccent
                      : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (emoji != null) ...[
                    Text(emoji!, style: const TextStyle(fontSize: 13)),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
