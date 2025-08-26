import 'packaging.dart';
import 'pef.dart';
import 'co2_impact.dart';

class Product {
  final String? imageUrl;
  final String? name;
  final String? barcode;
  final String? genericName;
  final dynamic quantity;
  final List<String>? packaging;
  final List<String>? brands;
  final String? categories;
  final List<String>? labels;
  final String? productUrl;
  final List<String>? stores;
  final List<String>? countries;
  final String? ecoScoreGrade;
  final List<Packaging>? packagings;
  final PEFInfo? pefInfo;
  final CO2Impact? co2Impact;

  Product({
    this.imageUrl,
    this.name,
    this.barcode,
    this.genericName,
    this.quantity,
    this.packaging,
    this.brands,
    this.categories,
    this.labels,
    this.productUrl,
    this.stores,
    this.countries,
    this.ecoScoreGrade,
    this.packagings,
    this.pefInfo,
    this.co2Impact,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var ecoscoreData = json['ecoscore_data'] ?? {};
    var agribalyse = ecoscoreData['agribalyse'] ?? {};

    return Product(
      imageUrl: json['image_url'] ?? '',
      name: json['product_name'] ?? 'Produit sans nom',
      barcode: json['code'] ?? '',
      genericName: json['generic_name_fr'] ?? 'Dénomination générique non disponible',
      quantity: json['quantity'] ?? 'Quantité non disponible',
      packaging: List<String>.from(json['packaging']?.split(',') ?? []),
      brands: List<String>.from(json['brands']?.split(',') ?? []),
      categories: json['categories'] ?? 'Catégories non disponibles',
      labels: List<String>.from(json['labels_tags'] ?? []),
      productUrl: json['url'] ?? '',
      stores: List<String>.from(json['stores_tags'] ?? []),
      countries: List<String>.from(json['countries_tags'] ?? []),
      ecoScoreGrade: json['ecoscore_grade'] ?? 'Non disponible',
      packagings: (json['packagings'] as List?)?.map((item) => Packaging.fromJson(item)).toList() ?? [],
      pefInfo: PEFInfo.fromJson({
        'ef_total': agribalyse['ef_total']?.toDouble() ?? 0.0,
        'ef_transportation': agribalyse['ef_transportation']?.toDouble() ?? 0.0,
        'ef_processing': agribalyse['ef_processing']?.toDouble() ?? 0.0,
        'ef_packaging': agribalyse['ef_packaging']?.toDouble() ?? 0.0,
        'ef_consumption': agribalyse['ef_consumption']?.toDouble() ?? 0.0,
        'ef_distribution': agribalyse['ef_distribution']?.toDouble() ?? 0.0,
        'ef_agriculture': agribalyse['ef_agriculture']?.toDouble() ?? 0.0,
      }),
      co2Impact: CO2Impact.fromJson({
        'co2_total': agribalyse['co2_total']?.toDouble() ?? 0.0,
        'co2_agriculture': agribalyse['co2_agriculture']?.toDouble() ?? 0.0,
        'co2_consumption': agribalyse['co2_consumption']?.toDouble() ?? 0.0,
        'co2_distribution': agribalyse['co2_distribution']?.toDouble() ?? 0.0,
        'co2_packaging': agribalyse['co2_packaging']?.toDouble() ?? 0.0,
        'co2_processing': agribalyse['co2_processing']?.toDouble() ?? 0.0,
        'co2_transportation': agribalyse['co2_transportation']?.toDouble() ?? 0.0,
      }),
    );
  }

}