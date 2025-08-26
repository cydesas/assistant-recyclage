class PEFInfo {
  final double efTotal;
  final double efTransportation;
  final double efProcessing;
  final double efPackaging;
  final double efConsumption;
  final double efDistribution;
  final double efAgriculture;

  PEFInfo({
    required this.efTotal,
    required this.efTransportation,
    required this.efProcessing,
    required this.efPackaging,
    required this.efConsumption,
    required this.efDistribution,
    required this.efAgriculture,
  });

  factory PEFInfo.fromJson(Map<String, dynamic> json) {
    return PEFInfo(
      efTotal: json['ef_total'].toDouble(),
      efTransportation: json['ef_transportation'].toDouble(),
      efProcessing: json['ef_processing'].toDouble(),
      efPackaging: json['ef_packaging'].toDouble(),
      efConsumption: json['ef_consumption'].toDouble(),
      efDistribution: json['ef_distribution'].toDouble(),
      efAgriculture: json['ef_agriculture'].toDouble(),
    );
  }

}