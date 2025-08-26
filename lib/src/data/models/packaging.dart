// "packagings":[
//          {
//             "material":"en:plastic",
//             "number_of_units":"1",
//             "recycling":"en:recycle",
//             "shape":"en:lid",
//             "weight_measured":8.4
//          },
//          {
//             "material":"en:non-corrugated-cardboard",
//             "number_of_units":"1",
//             "recycling":"en:recycle",
//             "shape":"en:backing",
//             "weight_measured":2.2
//          },
//          {
//             "material":"en:aluminium",
//             "number_of_units":"1",
//             "recycling":"en:recycle",
//             "shape":"en:seal",
//             "weight_measured":0.3
//          },
//          {
//             "material":"en:clear-glass",
//             "number_of_units":"1",
//             "quantity_per_unit":"630 g",
//             "quantity_per_unit_unit":"g",
//             "quantity_per_unit_value":"630",
//             "recycling":"en:recycle-in-glass-bin",
//             "shape":"en:pot",
//             "weight_measured":329.3
//          },
//          {
//             "material":"en:paper-and-plastic",
//             "number_of_units":"2",
//             "recycling":"en:recycle",
//             "shape":"en:label",
//             "weight_measured":0.1
//          },
//          {
//             "shape":"en:jar"
//          }
//       ],
// "packagings_materials":{
//          "all":{
//             "weight":340.4,
//             "weight_100g":54.031746031746,
//             "weight_percent":100
//          },
//          "en:glass":{
//             "weight":329.3,
//             "weight_100g":52.2698412698413,
//             "weight_percent":96.7391304347826
//          },
//          "en:metal":{
//             "weight":0.3,
//             "weight_100g":0.0476190476190476,
//             "weight_percent":0.0881316098707403
//          },
//          "en:paper-or-cardboard":{
//             "weight":2.2,
//             "weight_100g":0.349206349206349,
//             "weight_percent":0.646298472385429
//          },
//          "en:plastic":{
//             "weight":8.4,
//             "weight_100g":1.33333333333333,
//             "weight_percent":2.46768507638073
//          },
//          "en:unknown":{
//             "weight":0.2,
//             "weight_100g":0.0317460317460317,
//             "weight_percent":0.0587544065804935
//          }
//       },

class Packaging {
  final String material;
  final dynamic numberOfUnits;
  final String recycling;
  final String shape;
  final double weightMeasured;

  Packaging({
    required this.material,
    this.numberOfUnits,
    required this.recycling,
    required this.shape,
    required this.weightMeasured,
  });

  factory Packaging.fromJson(Map<String, dynamic> json) {
    return Packaging(
      material: json['material'] ?? 'Non spécifié',
      numberOfUnits: _parseNumberOfUnits(json['number_of_units']) ?? 0,
      recycling: json['recycling'] ?? 'Non spécifié',
      shape: json['shape'] ?? 'Non spécifié',
      weightMeasured: json['weight_measured']?.toDouble() ?? 0.0,

    );
  }
}

int _parseNumberOfUnits(dynamic numberOfUnits) {
  if (numberOfUnits == null) {
    return 0;
  }

  if (numberOfUnits is int) {
    return numberOfUnits;
  }

  if (numberOfUnits is String) {
    final parsed = int.tryParse(numberOfUnits);
    return parsed ?? 0;
  }

  return 0;
}
