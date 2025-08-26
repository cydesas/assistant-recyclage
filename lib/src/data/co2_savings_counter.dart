import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';


class CO2SavingsCounter {
  static const _recordsKey = 'savingRecords';

  static Future<List<SavingRecord>> getSavingRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = prefs.getStringList(_recordsKey) ?? [];
    return recordsJson.map((recordJson) => SavingRecord.fromJson(json.decode(recordJson))).toList();
  }

  static Future<void> addSavingRecord(SavingRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    List<SavingRecord> currentRecords = await getSavingRecords();
    currentRecords.add(record);
    final recordsJson = currentRecords.map((record) => json.encode(record.toJson())).toList();
    await prefs.setStringList(_recordsKey, recordsJson);
  }

  static Future<Map<String, Map<String, double>>> getCO2SavingsByPeriodAndMaterial(String period) async {
    List<SavingRecord> records = await getSavingRecords();
    Map<String, Map<String, double>> savingsByPeriod = {};

    for (var record in records) {
      String key;
      switch (period) {
        case 'daily':
          key = DateFormat('yyyy-MM-dd').format(record.date);
          break;
        case 'weekly':
          key = DateFormat('yyyy-ww').format(record.date);
          break;
        case 'monthly':
          key = DateFormat('yyyy-MM').format(record.date);
          break;
        case 'annual':
          key = DateFormat('yyyy').format(record.date);
          break;
        default:
          key = DateFormat('yyyy-MM-dd').format(record.date);
          break;
      }

      if (!savingsByPeriod.containsKey(key)) {
        savingsByPeriod[key] = {};
      }

      if (!savingsByPeriod[key]!.containsKey(record.materialType)) {
        savingsByPeriod[key]![record.materialType] = 0.0;
      }

      double currentSavings = savingsByPeriod[key]![record.materialType]!;
      savingsByPeriod[key]![record.materialType] = currentSavings + record.savings;
    }

    return savingsByPeriod;
  }
}

class SavingRecord {
  final DateTime date;
  final double savings;
  final String materialType;
  final int itemCount;

  SavingRecord({
    required this.date,
    required this.savings,
    required this.materialType,
    required this.itemCount,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'savings': savings,
    'materialType': materialType,
    'itemCount': itemCount,
  };

  static SavingRecord fromJson(Map<String, dynamic> json) => SavingRecord(
    date: DateTime.parse(json['date']),
    savings: json['savings'],
    materialType: json['materialType'],
    itemCount: json['itemCount'],
  );
}
