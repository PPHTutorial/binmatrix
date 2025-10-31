import '../../domain/entities/bin_info.dart';

/// BIN Information model (matches entity for now)
class BinInfoModel extends BinInfo {
  const BinInfoModel({
    required super.country,
    required super.bin,
    required super.phone,
    required super.website,
    required super.bank,
    required super.level,
    required super.brand,
    required super.type,
  });

  factory BinInfoModel.fromJson(Map<String, dynamic> json) {
    return BinInfoModel(
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

  BinInfo toEntity() => BinInfo(
        country: country,
        bin: bin,
        phone: phone,
        website: website,
        bank: bank,
        level: level,
        brand: brand,
        type: type,
      );
}

