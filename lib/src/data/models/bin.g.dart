// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bin _$BinFromJson(Map<String, dynamic> json) => Bin(
      binId: json['binId'] as String,
      locationName: json['locationName'] as String,
      isAvailable: json['isAvailable'] as String,
      capacity: json['capacity'] as int,
      currentFillLevel: json['currentFillLevel'] as int,
      coordinates:
          GeoCoordinates.fromJson(json['coordinates'] as Map<String, dynamic>),
      category: $enumDecode(_$MarkerCategoryEnumMap, json['category']),
      districtName: json['districtName'] as String?,
      districtCode: json['districtCode'] as String?,
    );

Map<String, dynamic> _$BinToJson(Bin instance) => <String, dynamic>{
      'binId': instance.binId,
      'locationName': instance.locationName,
      'isAvailable': instance.isAvailable,
      'capacity': instance.capacity,
      'currentFillLevel': instance.currentFillLevel,
      'coordinates': instance.coordinates,
      'category': _$MarkerCategoryEnumMap[instance.category]!,
      'districtName': instance.districtName,
      'districtCode': instance.districtCode,
    };

const _$MarkerCategoryEnumMap = {
  MarkerCategory.Verre: 'Verre',
  MarkerCategory.Electronique: 'Electronique',
};
