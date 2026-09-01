import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/collection_model.dart';
import 'visi_image.dart';

class CollectionCard extends StatelessWidget {
  final CollectionModel collection;
  final int itemCount;
  final VoidCallback onTap;

  const CollectionCard({
    super.key,
    required this.collection,
    required this.itemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Cover Image or Gradient Background
              Positioned.fill(
                child: VisiImage(imageUrl: collection.coverImage),
              ),

              // Gradient Overlay for Text Readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.70),
                      ],
                    ),
                  ),
                ),
              ),

              // Top Right Item Count Pill
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Text(
                    '$itemCount ürün',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Bottom Title and Emoji
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          collection.emoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            collection.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
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
