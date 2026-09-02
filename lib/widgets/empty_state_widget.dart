import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import 'visi_cherry_logo.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? customIcon;

  const EmptyStateWidget({
    super.key,
    this.title = 'Dilek listen seni bekliyor',
    this.message = 'Sevdiğin, hayal ettiğin şeyleri kaydetmeye başla.',
    this.buttonText,
    this.onButtonPressed,
    this.customIcon,
  });

  factory EmptyStateWidget.wishlist({VoidCallback? onAddPressed}) {
    return EmptyStateWidget(
      title: 'Henüz bir dileğin yok.',
      message: 'Sevdiğin, hayal ettiğin parçaları kaydetmeye başla.',
      buttonText: 'İlk Dileğini Ekle',
      onButtonPressed: onAddPressed,
    );
  }

  factory EmptyStateWidget.collections({VoidCallback? onCreatePressed}) {
    return EmptyStateWidget(
      title: 'Koleksiyonların için yer aç.',
      message: 'Dileklerini konulara, tarzlara veya moodboard\'lara göre grupla.',
      buttonText: 'Yeni Koleksiyon Oluştur',
      onButtonPressed: onCreatePressed,
    );
  }

  factory EmptyStateWidget.favorites() {
    return const EmptyStateWidget(
      title: 'Bazı dilekler küçük bir kalbi hak eder.',
      message: 'En çok heyecan duyduğun parçaların üzerindeki kalbe dokunarak favorilerine ekle.',
    );
  }

  factory EmptyStateWidget.search() {
    return const EmptyStateWidget(
      title: 'Aradığın dilek bulunamadı.',
      message: 'Farklı bir arama terimi veya filtre seçeneği deneyebilirsin.',
    );
  }

  factory EmptyStateWidget.error({String? message, VoidCallback? onRetry}) {
    return EmptyStateWidget(
      title: 'Bir şeyler ters gitti.',
      message: message ?? 'Listen yüklenirken küçük bir aksaklık oldu. Lütfen tekrar dene.',
      buttonText: 'Tekrar Dene',
      onButtonPressed: onRetry,
      customIcon: const Icon(Icons.refresh_rounded, size: 40, color: AppColors.cherryAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Decorative Cherry Badge Container
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: isDark ? AppColors.blushPinkDark : AppColors.blushPink,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cherryAccent.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: customIcon ?? const VisiCherryLogo(size: 42, color: AppColors.cherryAccent),
              ),
            ),
            const SizedBox(height: 24),

            // Editorial Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),

            // Body Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                height: 1.45,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),

            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onButtonPressed,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  buttonText!,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cherryAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
