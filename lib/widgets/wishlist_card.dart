import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../models/wish_status.dart';
import '../models/wishlist_item.dart';
import 'visi_image.dart';

class WishlistCard extends StatelessWidget {
  final WishlistItem item;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const WishlistCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  String _formatPrice(double price, String currency) {
    final formatter = NumberFormat('#,##0.##', 'tr_TR');
    return '$currency${formatter.format(price)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isFulfilled = item.status == WishStatus.fulfilled;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFulfilled
              ? AppColors.cherryAccent.withValues(alpha: 0.5)
              : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          width: isFulfilled ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadowColor : AppColors.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Area
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: VisiImage(imageUrl: item.imagePath),
                    ),

                    // Gradient Vignette
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.2),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Type Badge (Top Left)
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 52,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.black87 : Colors.white).withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.type.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ),

                    // Favorite Button (Top Right)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: Material(
                            color: (isDark ? Colors.black54 : Colors.white).withValues(alpha: 0.88),
                            shape: const CircleBorder(),
                            elevation: 1,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                onFavoriteToggle();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 240),
                                  transitionBuilder: (child, anim) => ScaleTransition(
                                    scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                                      CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                                    ),
                                    child: child,
                                  ),
                                  child: Icon(
                                    item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    key: ValueKey(item.isFavorite),
                                    size: 16,
                                    color: item.isFavorite
                                        ? AppColors.cherryAccent
                                        : (isDark ? Colors.white70 : AppColors.lightTextSecondary),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Fulfilled Overlay Badge
                    if (isFulfilled)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.cherryAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '✨ Gerçek oldu',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Info Area
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    if (item.price > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        _formatPrice(item.price, item.currency),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ] else if (item.targetDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Hedef: ${item.targetDate!.year}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
