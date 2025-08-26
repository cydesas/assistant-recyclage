import 'package:json_annotation/json_annotation.dart';

part 'geo_coordinates.g.dart';

@JsonSerializable()
class GeoCoordinates {
  final double lon;
  final double lat;

  GeoCoordinates({
    required this.lon,
    required this.lat
  });

  factory GeoCoordinates.fromJson(Map<String, dynamic> json) =>
      _$GeoCoordinatesFromJson(json);
}
