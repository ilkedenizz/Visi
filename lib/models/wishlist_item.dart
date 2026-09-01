import 'dart:convert';

enum ItemPriority { low, medium, high }

extension ItemPriorityExtension on ItemPriority {
  String get label {
    switch (this) {
      case ItemPriority.low:
        return 'Düşük';
      case ItemPriority.medium:
        return 'Orta';
      case ItemPriority.high:
        return 'Yüksek';
    }
  }

  static ItemPriority fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'high':
      case 'yüksek':
        return ItemPriority.high;
      case 'medium':
      case 'orta':
        return ItemPriority.medium;
      case 'low':
      case 'düşük':
      default:
        return ItemPriority.low;
    }
  }
}

class WishlistItem {
  final String id;
  final String title;
  final String? imagePath;
  final double price;
  final String currency;
  final String? store;
  final String? productUrl;
  final String collectionId;
  final String? notes;
  final ItemPriority priority;
  final bool isFavorite;
  final DateTime createdAt;

  const WishlistItem({
    required this.id,
    required this.title,
    this.imagePath,
    required this.price,
    this.currency = '₺',
    this.store,
    this.productUrl,
    required this.collectionId,
    this.notes,
    this.priority = ItemPriority.medium,
    this.isFavorite = false,
    required this.createdAt,
  });

  WishlistItem copyWith({
    String? id,
    String? title,
    String? imagePath,
    double? price,
    String? currency,
    String? store,
    String? productUrl,
    String? collectionId,
    String? notes,
    ItemPriority? priority,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      store: store ?? this.store,
      productUrl: productUrl ?? this.productUrl,
      collectionId: collectionId ?? this.collectionId,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imagePath': imagePath,
      'price': price,
      'currency': currency,
      'store': store,
      'productUrl': productUrl,
      'collectionId': collectionId,
      'notes': notes,
      'priority': priority.name,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      id: map['id'] as String,
      title: map['title'] as String,
      imagePath: map['imagePath'] as String?,
      price: (map['price'] as num).toDouble(),
      currency: (map['currency'] as String?) ?? '₺',
      store: map['store'] as String?,
      productUrl: map['productUrl'] as String?,
      collectionId: map['collectionId'] as String,
      notes: map['notes'] as String?,
      priority: ItemPriorityExtension.fromString(map['priority'] as String?),
      isFavorite: (map['isFavorite'] as bool?) ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory WishlistItem.fromJson(String source) =>
      WishlistItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WishlistItem &&
        other.id == id &&
        other.title == title &&
        other.imagePath == imagePath &&
        other.price == price &&
        other.currency == currency &&
        other.store == store &&
        other.productUrl == productUrl &&
        other.collectionId == collectionId &&
        other.notes == notes &&
        other.priority == priority &&
        other.isFavorite == isFavorite &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        imagePath.hashCode ^
        price.hashCode ^
        currency.hashCode ^
        store.hashCode ^
        productUrl.hashCode ^
        collectionId.hashCode ^
        notes.hashCode ^
        priority.hashCode ^
        isFavorite.hashCode ^
        createdAt.hashCode;
  }
}
