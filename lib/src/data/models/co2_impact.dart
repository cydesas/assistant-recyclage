class CO2Impact {
  final double co2Total;
  final double co2Agriculture;
  final double co2Consumption;
  final double co2Distribution;
  final double co2Packaging;
  final double co2Processing;
  final double co2Transportation;

  CO2Impact({
    required this.co2Total,
    required this.co2Agriculture,
    required this.co2Consumption,
    required this.co2Distribution,
    required this.co2Packaging,
    required this.co2Processing,
    required this.co2Transportation,
  });

  factory CO2Impact.fromJson(Map<String, dynamic> json) {
    return CO2Impact(
      co2Total: json['co2_total'].toDouble(),
      co2Agriculture: json['co2_agriculture'].toDouble(),
      co2Consumption: json['co2_consumption'].toDouble(),
      co2Distribution: json['co2_distribution'].toDouble(),
      co2Packaging: json['co2_packaging'].toDouble(),
      co2Processing: json['co2_processing'].toDouble(),
      co2Transportation: json['co2_transportation'].toDouble(),
    );
  }
}