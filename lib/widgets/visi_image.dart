import 'dart:io';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'visi_cherry_logo.dart';

/// Boutique Vişi Styled Image Widget
///
/// Gracefully handles network loading, image errors, and missing image URLs
/// with a sophisticated Vişi editorial placeholder instead of broken UI elements.
class VisiImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const VisiImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget child;

    final path = imageUrl?.trim();

    if (path == null || path.isEmpty) {
      child = _buildPlaceholder(isDark);
    } else if (path.startsWith('http://') || path.startsWith('https://')) {
      child = Image.network(
        path,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingState(isDark, loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(isDark),
      );
    } else {
      final file = File(path);
      if (file.existsSync()) {
        child = Image.file(
          file,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(isDark),
        );
      } else {
        child = _buildPlaceholder(isDark);
      }
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }

    return child;
  }

  Widget _buildLoadingState(bool isDark, ImageChunkEvent progress) {
    final cumulative = progress.cumulativeBytesLoaded;
    final total = progress.expectedTotalBytes;
    final value = (total != null && total > 0) ? cumulative / total : null;

    return Container(
      width: width,
      height: height,
      color: isDark ? AppColors.darkSurface : AppColors.blushPink,
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            value: value,
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cherryAccent),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.blushPink.withValues(alpha: 0.7),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            VisiCherryLogo(
              size: 30,
              color: isDark ? AppColors.cherryAccentDark : AppColors.cherryAccent,
            ),
            const SizedBox(height: 6),
            Text(
              'VISI',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
