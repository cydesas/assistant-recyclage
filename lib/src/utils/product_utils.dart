import 'dart:ui' as ui;
import 'package:http/http.dart' as http;

import 'dart:ui' as ui;

class ProductUtils {
  final String _deviceLocale;

  ProductUtils() : _deviceLocale = ui.window.locale.languageCode;

  double convertQuantityToGramsOrLiters(String quantityStr) {
    List<String> parts = quantityStr.split(' ');
    double quantity = double.parse(parts[0]);
    String unit = parts[1];

    switch (unit) {
      case 'kg':
        return quantity * 1000;
      case 'g':
        return quantity;
      case 'l':
        return quantity * 1000;
      case 'ml':
        return quantity;
      case 'cl':
        return quantity * 10;
      default:
        return quantity;
    }
  }

  String formatQuantityForDisplay(String quantityStr) {
    List<String> parts = quantityStr.split(' ');
    double quantityInGramsOrLiters = convertQuantityToGramsOrLiters(quantityStr);
    String originalUnit = parts[1].toLowerCase();

    if (originalUnit == 'g' || originalUnit == 'kg') {
      return quantityInGramsOrLiters >= 1000
          ? '${(quantityInGramsOrLiters / 1000).toStringAsFixed(2)} kg'
          : '${quantityInGramsOrLiters.toStringAsFixed(0)} g';
    } else if (originalUnit == 'l' || originalUnit == 'ml' || originalUnit == 'cl') {
      return quantityInGramsOrLiters >= 1000
          ? '${(quantityInGramsOrLiters / 1000).toStringAsFixed(2)} l'
          : '${quantityInGramsOrLiters.toStringAsFixed(0)} ml';
    }
    return quantityInGramsOrLiters.toString();
  }

  String getMaterialTranslation(String material) {
    Map<String, Map<String, String>> translations = {
      'en:plastic': {
        'de': 'Kunststoff',
        'el': 'Πλαστικό',
        'fr': 'Plastique',
        'nl': 'Plastic',
        'pt': 'Plástico',
        'hu': 'Műanyag',
      },
      'en:recyclable-material': {
        'de': 'Wiederverwertbares Material',
        'fr': 'Matériau recyclable',
        'pt': 'Material reciclável',
        'hu': 'Újrahasznosítható anyag',
      },
      'en:recyclable-plastic': {
        'de': 'Wiederverwert',
        'fr': 'Plastique recyclable',
        'ja': 'プラマーク',
        'pt': 'Plástico reciclável',
        'hu': 'Újrahasznosítható műanyag',
      },
    };

    return translations[material]?['fr'] ?? material;
  }

  String getShapeTranslation(String shape) {
    Map<String, Map<String, String>> translations = {
      'en:aerosol': {
        'de': 'Aerosol',
        'el': 'Αεροζόλ',
        'fr': 'Aérosol',
        'nl': 'Drijfgas',
        'pt': 'Aerossol',
        'hu': 'Aeroszolos doboz',
      },
      'en:bottle': {
        'de': 'Flasche',
        'el': 'Μπουκάλι',
        'fr': 'Bouteille',
        'nl': 'Fles',
        'pt': 'Garrafa',
        'hu': 'Palack',
      },
      'en:bag': {
        'de': 'Tüte, Sack',
        'el': 'Σακούλα',
        'fr': 'Sachet',
        'nl': 'Zak',
        'pt': 'Saco',
        'hu': 'Zacskó',
      },
      'en:bowl': {
        'de': 'Schüssel',
        'el': 'Μπολ',
        'fr': 'Bol',
        'pt': 'Tigela',
        'hu': 'Tál',
      },
      'en:box': {
        'de': 'Kasten',
        'el': 'Κουτί',
        'nl': 'Boos',
        'fr': 'Boîte',
        'pt': 'Caixa',
        'hu': 'Doboz',
      },
      'en:jar': {
        'de': 'Krug',
        'el': 'Βάζο',
        'fr': 'Bocal',
        'nl': 'Pot',
        'hu': 'Befőttes üveg',
        'pt': 'Jarro',
      },
      'en:tray': {
        'de': 'Körbchen, Schale',
        'fr': 'Barquette',
        'hu': 'Tálca',
      },
      'en:film': {
        'de': 'Folie',
        'el': 'Μεμβράνη',
        'fr': 'Film',
        'nl': 'Film',
        'hu': 'Film',
        'pt': 'Película',
      },
      'en:lid': {
        'de': 'Deckel',
        'el': 'Καπάκι',
        'fr': 'Couvercle',
        'nl': 'Deksel',
        'pt': 'Tampa',
        'hu': 'Fedél',
      },
      'en:individual-packaging': {
        'de': 'Individuelle Verpackung',
        'fr': 'Emballage individuel',
        'el': 'Ατομική συσκευασία',
        'pt': 'Embalagem individual',
        'hu': 'Egyéni csomagolás',
      },
      'en:cork': {
        'de': 'Kork',
        'el': 'Φελλός',
        'fr': 'Bouchon',
        'nl': 'Dop',
        'pt': 'Cortiça',
        'hu': 'Dugó',
      },
      'en:tube': {
        'fr': 'Tube',
        'hu': 'Cső',
        'pt': 'Tubo',
      },
      'en:can': {
        'de': 'Dose',
        'fr': 'Canette',
        'pt': 'Lata',
        'hu': 'Konzervdoboz',
      },
    };

    return translations[shape]?['fr'] ?? shape.split(':')[1];
  }

  String getRecyclingTranslation(String recycling) {
    Map<String, Map<String, String>> translations = {
      'en:recycle': {
        'de': 'Recycling',
        'el': 'Ανακύκλωση',
        'fr': 'Poubelle jaune',
        'nl': 'Recycling',
        'pt': 'Reciclagem',
        'hu': 'Újrahasznosítás',
      },
      'en:recycle-in-glass-bin': {
        'de': 'Recycling im Glasbehälter',
        'fr': 'Benne à verre',
        'pt': 'Reciclagem no contentor de vidro',
        'hu': 'Újrahasznosítás üveggyűjtőben',
      },
    };

    return translations[recycling]?['fr'] ?? recycling;
  }

  // Méthode pour obtenir les logos de labels à partir des noms de labels
  // Exemple d'objet reçu :
  // ["en:green-dot","pt:ecoponto-amarelo","pt:ponto-amarelo"]
  // Voici un exemple d'URL pour obtenir le logo d'un label :
  // 	https://static.openfoodfacts.org/images/lang/pt/labels/ecoponto-amarelo.90x90.svg
  Future<List<String>> getLabelLogos(List<String>? labels) async {
    List<String> validLogos = [];

    if (labels == null) return validLogos;

    for (var label in labels) {
      String countryCode = label.split(':')[0];
      String logo = label.split(':')[1];
      String url =
          'https://fr.openfoodfacts.org/images/lang/$countryCode/labels/$logo.90x90.svg';

      final response = await http.head(Uri.parse(url));

      print('URL : $url');
      print('Response : $response');
      print('Status code : ${response.statusCode}');

      if (response.statusCode != 404) {
        validLogos.add(url);
      }
    }

    return validLogos;
  }
}
