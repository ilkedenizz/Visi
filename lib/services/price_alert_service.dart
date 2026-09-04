import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/price_alert.dart';
import '../models/wishlist_item.dart';
import '../providers/price_alert_provider.dart';
import 'price_alert_notification_service.dart';
import 'price_checker_service.dart';

class PriceAlertService {
  static Future<PriceCheckResult> checkWishlistItemPrice(
    WishlistItem item,
    WidgetRef ref,
  ) async {
    final url = item.productUrl?.trim();
    if (url == null || url.isEmpty) {
      return const PriceCheckResult(
        status: PriceCheckStatus.unsupported,
        errorMessage: 'Ürün bağlantısı bulunamadı.',
      );
    }

    // Perform price check
    final result = await PriceCheckerService.checkPrice(url);

    if (result.isSuccess && result.price != null && result.price! > 0) {
      final currentAlert = ref.read(priceAlertForWishProvider(item.id));
      final newPrice = result.price!;
      final now = DateTime.now();

      if (currentAlert == null || currentAlert.lastKnownPrice == null) {
        // FIRST CHECK: Record lastKnownPrice, no notification
        await ref.read(priceAlertProvider.notifier).setAlertForWish(
              wishId: item.id,
              enabled: currentAlert?.enabled ?? true,
              currentPrice: newPrice,
              targetPrice: newPrice,
            );
      } else {
        final oldPrice = currentAlert.lastKnownPrice!;

        if (newPrice < oldPrice) {
          // PRICE DROP!
          await ref.read(priceAlertProvider.notifier).setAlertForWish(
                wishId: item.id,
                enabled: true,
                currentPrice: newPrice,
                targetPrice: currentAlert.targetPrice ?? newPrice,
              );

          // Update status to priceDrop in notifier state
          final updatedAlerts = ref.read(priceAlertProvider).asData?.value ?? [];
          final idx = updatedAlerts.indexWhere((a) => a.wishId == item.id);
          if (idx != -1) {
            updatedAlerts[idx] = updatedAlerts[idx].copyWith(
              status: PriceAlertStatus.priceDrop,
              lastCheckedAt: now,
            );
          }

          // Trigger local notification
          final currency = result.currency ?? item.currency;
          final formattedPrice = newPrice.toStringAsFixed(newPrice.truncateToDouble() == newPrice ? 0 : 2);
          await PriceAlertNotificationService.showPriceDrop(
            title: '🍒 Fiyat düştü!',
            body: '${item.title} artık $currency$formattedPrice (Önceki: $currency${oldPrice.toStringAsFixed(0)})',
          );
        } else {
          // SAME OR HIGHER PRICE
          await ref.read(priceAlertProvider.notifier).setAlertForWish(
                wishId: item.id,
                enabled: currentAlert.enabled,
                currentPrice: newPrice,
                targetPrice: currentAlert.targetPrice,
              );

          final updatedAlerts = ref.read(priceAlertProvider).asData?.value ?? [];
          final idx = updatedAlerts.indexWhere((a) => a.wishId == item.id);
          if (idx != -1) {
            updatedAlerts[idx] = updatedAlerts[idx].copyWith(
              status: PriceAlertStatus.idle,
              lastCheckedAt: now,
            );
          }
        }
      }
    }

    return result;
  }
}
