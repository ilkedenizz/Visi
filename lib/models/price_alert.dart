import 'dart:convert';
import 'package:uuid/uuid.dart';

enum PriceAlertStatus { idle, checking, priceDrop, error, unsupported }

extension PriceAlertStatusExtension on PriceAlertStatus {
  String get code => toString().split('.').last;
  static PriceAlertStatus fromCode(String? code) {
    switch (code?.toLowerCase()) {
      case 'checking':
        return PriceAlertStatus.checking;
      case 'pricedrop':
        return PriceAlertStatus.priceDrop;
      case 'error':
        return PriceAlertStatus.error;
      case 'unsupported':
        return PriceAlertStatus.unsupported;
      case 'idle':
      default:
        return PriceAlertStatus.idle;
    }
  }
}

class PriceAlert {
  final String id;
  final String wishId;
  final bool enabled;
  final double? lastKnownPrice;
  final DateTime? lastCheckedAt;
  final double? targetPrice;
  final PriceAlertStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  PriceAlert({
    String? id,
    required this.wishId,
    this.enabled = false,
    this.lastKnownPrice,
    this.lastCheckedAt,
    this.targetPrice,
    this.status = PriceAlertStatus.idle,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  PriceAlert copyWith({
    String? id,
    String? wishId,
    bool? enabled,
    double? lastKnownPrice,
    DateTime? lastCheckedAt,
    double? targetPrice,
    PriceAlertStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PriceAlert(
      id: id ?? this.id,
      wishId: wishId ?? this.wishId,
      enabled: enabled ?? this.enabled,
      lastKnownPrice: lastKnownPrice ?? this.lastKnownPrice,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      targetPrice: targetPrice ?? this.targetPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wishId': wishId,
      'enabled': enabled,
      'lastKnownPrice': lastKnownPrice,
      'lastCheckedAt': lastCheckedAt?.toIso8601String(),
      'targetPrice': targetPrice,
      'status': status.code,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PriceAlert.fromMap(Map<String, dynamic> map) {
    return PriceAlert(
      id: map['id'] as String?,
      wishId: map['wishId'] as String,
      enabled: map['enabled'] as bool? ?? false,
      lastKnownPrice: (map['lastKnownPrice'] as num?)?.toDouble(),
      lastCheckedAt: map['lastCheckedAt'] != null ? DateTime.parse(map['lastCheckedAt'] as String) : null,
      targetPrice: (map['targetPrice'] as num?)?.toDouble(),
      status: PriceAlertStatusExtension.fromCode(map['status'] as String?),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt'] as String) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory PriceAlert.fromJson(String source) =>
      PriceAlert.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PriceAlert &&
        other.id == id &&
        other.wishId == wishId &&
        other.enabled == enabled &&
        other.lastKnownPrice == lastKnownPrice &&
        other.lastCheckedAt == lastCheckedAt &&
        other.targetPrice == targetPrice &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        wishId.hashCode ^
        enabled.hashCode ^
        lastKnownPrice.hashCode ^
        lastCheckedAt.hashCode ^
        targetPrice.hashCode ^
        status.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
