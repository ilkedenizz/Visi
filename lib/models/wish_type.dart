enum WishType {
  toDo('toDo', '✨ Yapmak', 'Bir aktivite veya hedef'),
  toLearn('toLearn', '🧠 Öğrenmek', 'Yeni bir beceri veya bilgi'),
  toVisit('toVisit', '🌍 Gitmek', 'Seyahat veya yeni bir mekan'),
  toOwn('toOwn', '🛍️ Sahip Olmak', 'Fiziksel veya dijital bir şey'),
  dream('dream', '💭 Hayal', 'Kişisel hayal veya vizyon');

  final String code;
  final String label;
  final String description;

  const WishType(this.code, this.label, this.description);

  String get emoji => label.split(' ').first;
  String get displayName => label.split(' ').sublist(1).join(' ');

  static WishType fromCode(String? code) {
    if (code == null) return WishType.toOwn;
    return WishType.values.firstWhere(
      (e) => e.code == code || e.name == code,
      orElse: () => WishType.toOwn,
    );
  }
}
