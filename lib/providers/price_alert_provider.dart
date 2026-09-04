import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/price_alert.dart';
import 'storage_provider.dart';

class PriceAlertNotifier extends AsyncNotifier<List<PriceAlert>> {
  @override
  Future<List<PriceAlert>> build() async {
    final repository = ref.watch(storageRepositoryProvider);
    return await repository.loadPriceAlerts();
  }

  PriceAlert? getAlertForWishSync(String wishId) {
    final alerts = state.asData?.value ?? [];
    try {
      return alerts.firstWhere((a) => a.wishId == wishId);
    } catch (_) {
      return null;
    }
  }

  Future<void> setAlertForWish({
    required String wishId,
    required bool enabled,
    double? currentPrice,
    double? targetPrice,
  }) async {
    final alerts = List<PriceAlert>.from(state.asData?.value ?? []);
    final index = alerts.indexWhere((a) => a.wishId == wishId);

    PriceAlert alert;
    if (index != -1) {
      alert = alerts[index].copyWith(
        enabled: enabled,
        lastKnownPrice: currentPrice ?? alerts[index].lastKnownPrice,
        targetPrice: targetPrice ?? alerts[index].targetPrice,
        updatedAt: DateTime.now(),
      );
      alerts[index] = alert;
    } else {
      alert = PriceAlert(
        wishId: wishId,
        enabled: enabled,
        lastKnownPrice: currentPrice,
        targetPrice: targetPrice,
      );
      alerts.add(alert);
    }

    state = AsyncData(alerts);
    final repo = ref.read(storageRepositoryProvider);
    await repo.savePriceAlerts(alerts);
  }

  Future<void> removeAlertForWish(String wishId) async {
    final alerts = List<PriceAlert>.from(state.asData?.value ?? []);
    alerts.removeWhere((a) => a.wishId == wishId);

    state = AsyncData(alerts);
    final repo = ref.read(storageRepositoryProvider);
    await repo.savePriceAlerts(alerts);
  }
}

final priceAlertProvider =
    AsyncNotifierProvider<PriceAlertNotifier, List<PriceAlert>>(() {
  return PriceAlertNotifier();
});

final priceAlertForWishProvider =
    Provider.family<PriceAlert?, String>((ref, wishId) {
  final alertsAsync = ref.watch(priceAlertProvider);
  return alertsAsync.asData?.value
      .where((a) => a.wishId == wishId)
      .firstOrNull;
});
