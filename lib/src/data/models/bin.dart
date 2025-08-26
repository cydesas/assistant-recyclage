import 'package:json_annotation/json_annotation.dart';
import 'geo_coordinates.dart';
import 'marker_category.dart';

part 'bin.g.dart';

@JsonSerializable()
class Bin {
  final String binId;
  final String locationName;
  final String isAvailable;
  final int capacity;
  final int currentFillLevel;
  final GeoCoordinates coordinates;
  final MarkerCategory category;
  final String? districtName;
  final String? districtCode;

  Bin({
    required this.binId,
    required this.locationName,
    required this.isAvailable,
    required this.capacity,
    required this.currentFillLevel,
    required this.coordinates,
    required this.category,
    this.districtName,
    this.districtCode,
  });

  factory Bin.fromJson(Map<String, dynamic> json) => _$BinFromJson(json);
}