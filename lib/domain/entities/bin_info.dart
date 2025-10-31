import 'package:equatable/equatable.dart';

/// BIN Information entity
class BinInfo extends Equatable {
  final String country;
  final String bin;
  final String phone;
  final String website;
  final String bank;
  final String level;
  final String brand;
  final String type;

  const BinInfo({
    required this.country,
    required this.bin,
    required this.phone,
    required this.website,
    required this.bank,
    required this.level,
    required this.brand,
    required this.type,
  });

  /// Create BinInfo from JSON
  factory BinInfo.fromJson(Map<String, dynamic> json) {
    return BinInfo(
      country: json['country']?.toString() ?? '',
      bin: json['bin']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      website: json['website']?.toString() ?? '',
      bank: json['bank']?.toString() ?? '',
      level: json['level']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'bin': bin,
      'phone': phone,
      'website': website,
      'bank': bank,
      'level': level,
      'brand': brand,
      'type': type,
    };
  }

  /// Get formatted level display
  String get formattedLevel {
    if (level.isEmpty) return 'N/A';
    return level.replaceAll('_', ' ').toUpperCase();
  }

  /// Get formatted brand icon
  String get brandIcon {
    switch (brand.toUpperCase()) {
      case 'VISA':
        return '💳';
      case 'MASTERCARD':
        return '💳';
      case 'AMEX':
      case 'AMERICAN EXPRESS':
        return '💳';
      case 'DISCOVER':
        return '💳';
      default:
        return '💳';
    }
  }

  /// Check if has contact information
  bool get hasContactInfo => phone.isNotEmpty || website.isNotEmpty;

  @override
  List<Object?> get props => [
        country,
        bin,
        phone,
        website,
        bank,
        level,
        brand,
        type,
      ];

  BinInfo copyWith({
    String? country,
    String? bin,
    String? phone,
    String? website,
    String? bank,
    String? level,
    String? brand,
    String? type,
  }) {
    return BinInfo(
      country: country ?? this.country,
      bin: bin ?? this.bin,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      bank: bank ?? this.bank,
      level: level ?? this.level,
      brand: brand ?? this.brand,
      type: type ?? this.type,
    );
  }
}

