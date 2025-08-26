import 'dart:convert';
import 'package:http/http.dart' as http;

import '../co2_savings_counter.dart';
import '../models/product.dart';
import '../models/packaging.dart';

class ProductService {
  static Future<Product> getProductData(String barcode) async {
    final url = Uri.parse('https://france.openfoodfacts.org/api/v0/product/$barcode.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final productData = jsonResponse['product'];
      final product = Product.fromJson(productData);
      return product;
    } else {
      throw Exception('Failed to load product data');
    }
  }

  static Future<List<SavingRecord>> calculateCO2Savings(String barcode, int itemCount) async {
    final product = await getProductData(barcode);

    // Taux d'économie de CO2 par kg pour chaque matériau d'emballage
    // 1 kg de plastique économise 2,3 kg de CO2 (https://clikeco.com/le-recyclage-du-plastique/)
    // 1 kg de verre économise 0,621 kg de CO2 (https://www.smictom-centreouest35.fr/le-recyclage-du-verre/)
    // 1 kg d'aluminium économise 9 kg de CO2 (https://ferrosplanes.com/fr/recyclage-aluminium-avantages-processus/#:~:text=Le%20recyclage%20de%20l'aluminium,par%20tout%20l'aluminium%20recycl%C3%A9.)
    // 1 kg de carton économise 2,5 kg de CO2 (https://www.urbyn.co/fiche-dechets/recyclage-carton/)
    Map<String, double> co2SavingsPerKg = {
      "en:plastic": 2.3,
      "en:glass": 0.621,
      "en:clear-glass": 0.621,
      "en:heavy-aluminium":9.0,
      "en:non-corrugated-cardboard": 2.5,
      "en:corrugated-cardboard": 2.5, // Ici, pas de metrics donc on met la même valeur que le carton non-ondulé
      "en:paper-and-plastic": 2.4, // Ici, pas de metrics donc on prend une moyenne entre le papier et le plastique
      "en:unknown": 0
    };

    List<SavingRecord> savingsRecords = [];

    // Calcul les économies de CO2 pour chaque matériau
    product.packagings?.forEach((pack) {
      double? co2SavingRate = co2SavingsPerKg[pack.material];
      if (co2SavingRate != null) {
        double materialCo2Savings = co2SavingRate * (pack.weightMeasured / 1000) * itemCount;
        savingsRecords.add(SavingRecord(
          date: DateTime.now(),
          savings: materialCo2Savings,
          materialType: pack.material,
          itemCount: itemCount,
        ));
      }
    });

    return savingsRecords;
  }

}
