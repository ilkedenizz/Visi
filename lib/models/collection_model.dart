import 'dart:convert';

class CollectionModel {
  final String id;
  final String name;
  final String? coverImage;
  final String emoji;
  final String? accentColorHex;
  final DateTime createdAt;

  const CollectionModel({
    required this.id,
    required this.name,
    this.coverImage,
    required this.emoji,
    this.accentColorHex,
    required this.createdAt,
  });

  CollectionModel copyWith({
    String? id,
    String? name,
    String? coverImage,
    String? emoji,
    String? accentColorHex,
    DateTime? createdAt,
  }) {
    return CollectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      coverImage: coverImage ?? this.coverImage,
      emoji: emoji ?? this.emoji,
      accentColorHex: accentColorHex ?? this.accentColorHex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'coverImage': coverImage,
      'emoji': emoji,
      'accentColorHex': accentColorHex,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CollectionModel.fromMap(Map<String, dynamic> map) {
    return CollectionModel(
      id: map['id'] as String,
      name: map['name'] as String,
      coverImage: map['coverImage'] as String?,
      emoji: (map['emoji'] as String?) ?? '✨',
      accentColorHex: map['accentColorHex'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory CollectionModel.fromJson(String source) =>
      CollectionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CollectionModel &&
        other.id == id &&
        other.name == name &&
        other.coverImage == coverImage &&
        other.emoji == emoji &&
        other.accentColorHex == accentColorHex &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        coverImage.hashCode ^
        emoji.hashCode ^
        accentColorHex.hashCode ^
        createdAt.hashCode;
  }
}
