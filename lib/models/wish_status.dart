enum WishStatus {
  wishing('wishing', '💭 İstiyorum'),
  starting('starting', '🌱 Başlıyorum'),
  fulfilled('fulfilled', '✨ Gerçek oldu');

  final String code;
  final String label;

  const WishStatus(this.code, this.label);

  static WishStatus fromCode(String? code) {
    if (code == null) return WishStatus.wishing;
    return WishStatus.values.firstWhere(
      (e) => e.code == code || e.name == code,
      orElse: () => WishStatus.wishing,
    );
  }
}
