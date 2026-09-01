import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../models/wishlist_item.dart';
import 'visi_cherry_logo.dart';
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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1,
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
              // Product Image (Dominant area)
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: VisiImage(imageUrl: item.imagePath),
                    ),

                    // Soft Gradient Vignette on bottom of image
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Favorite Heart Button (Subtle & Elegant)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: isDark ? Colors.black54 : Colors.white.withValues(alpha: 0.88),
                        shape: const CircleBorder(),
                        elevation: 1,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onFavoriteToggle();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
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

                    // Priority Accent Badge (If High Priority)
                    if (item.priority == ItemPriority.high)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.cherryAccent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              VisiCherryLogo(size: 9, color: Colors.white),
                              SizedBox(width: 3),
                              Text(
                                'Favori',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Product Info Area
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.store != null && item.store!.isNotEmpty) ...[
                      Text(
                        item.store!.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: isDark ? AppColors.cherryAccentDark : AppColors.cherryAccent,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatPrice(item.price, item.currency),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.primary,
                      ),
                    ),
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
