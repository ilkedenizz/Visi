import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_colors.dart';
import '../models/wishlist_item.dart';
import 'visi_image.dart';

class WishlistListTile extends StatelessWidget {
  final WishlistItem item;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const WishlistListTile({
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              // Thumbnail Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 76,
                  height: 76,
                  child: VisiImage(imageUrl: item.imagePath),
                ),
              ),
              const SizedBox(width: 14),

              // Wish Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.type.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.cherryAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (item.price > 0)
                          Text(
                            _formatPrice(item.price, item.currency),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        else
                          Text(
                            item.status.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                        if (item.targetDate != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : AppColors.blushPink,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${item.targetDate!.year}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.cherryAccent,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Favorite Heart Button
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onFavoriteToggle();
                },
                icon: AnimatedSwitcher(
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
                    color: item.isFavorite
                        ? AppColors.cherryAccent
                        : (isDark ? Colors.white60 : AppColors.lightTextMuted),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
