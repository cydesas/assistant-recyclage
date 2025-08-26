import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/bin.dart';

class BinService {
  static Future<List<Bin>> getBinData(path) async {
    final jsonString = await rootBundle.loadString(path);
    final List jsonResponse = json.decode(jsonString);
    return jsonResponse.map((binJson) => Bin.fromJson(binJson)).toList();
  }
}
