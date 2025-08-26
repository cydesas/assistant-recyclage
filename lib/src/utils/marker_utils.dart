import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../data/models/bin.dart';
import '../data/models/geo_coordinates.dart';
import '../data/models/marker_category.dart';
import '../data/services/bin_service.dart';

class MarkerUtils {
  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    final byteData = await fi.image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Échec de la conversion de l\'image en bytes.');
    }
    return byteData.buffer.asUint8List();
  }

  static Future navigateToNearestGlassBin(BuildContext context) async {
    final currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final glassBins = await BinService.getBinData('assets/mock_glass_bins.json');

    glassBins.retainWhere((bin) => bin.category == MarkerCategory.Verre);

    print('Nombre de bacs à verre trouvés : ${glassBins.length}');

    Bin? nearestBin;
    double? nearestDistance;

    for (final bin in glassBins) {
      final double distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        bin.coordinates.lat,
        bin.coordinates.lon,
      );

      if (nearestDistance == null || distance < nearestDistance) {
        nearestDistance = distance;
        nearestBin = bin;
      }
    }

    print('Bac à verre le plus proche : ${nearestBin?.locationName} (distance : $nearestDistance m)');

    if (nearestBin != null) {
      GoRouter.of(context).go('/localisation/${nearestBin.coordinates.lat}/${nearestBin.coordinates.lon}');
    } else {
      print('Aucun bac à verre trouvé à proximité.');
    }
  }
}
