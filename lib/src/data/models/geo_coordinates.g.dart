// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo_coordinates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoCoordinates _$GeoCoordinatesFromJson(Map<String, dynamic> json) =>
    GeoCoordinates(
      lon: (json['lon'] as num).toDouble(),
      lat: (json['lat'] as num).toDouble(),
    );

Map<String, dynamic> _$GeoCoordinatesToJson(GeoCoordinates instance) =>
    <String, dynamic>{
      'lon': instance.lon,
      'lat': instance.lat,
    };
