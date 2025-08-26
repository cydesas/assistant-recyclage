import 'dart:convert';
import 'dart:math';

import 'package:assistant_recyclage/src/utils/marker_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../data/models/packaging.dart';
import '../data/models/product.dart';
import '../data/services/product_service.dart';

import '../utils/product_utils.dart';

/*
class ImpactCO2WebView extends StatelessWidget {
  const ImpactCO2WebView({super.key});

  @override
  Widget build(BuildContext context) {
    return WebView(
      // initialUrl: '',
      userAgent:
          'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.96 Mobile Safari/537.36',
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        const String htmlContent = '''
        <!DOCTYPE html>
        <html>
        <body>
        <script name="impact-co2" src="https://impactco2.fr/iframe.js" data-type="comparateur/etiquette" data-search="?theme=default&value=1000&comparisons=email,rechercheweb,streamingvideo,voiturethermique,metro"></script>
        </body>
        </html>
      ''';
        webViewController.loadHtmlString(htmlContent);
      },
    );
  }
}
*/

class ProductPage extends StatefulWidget {
  final String barcode;

  const ProductPage({super.key, required this.barcode});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  bool isLoading = true;
  Product? product;
  late Future<List<String>>? labelLogosFuture;
  bool _displayAsPercentage = true;

  @override
  void initState() {
    super.initState();
    _getProductInfo();
    if (product != null) {
      labelLogosFuture = ProductUtils().getLabelLogos(product!.labels);
    }
  }

  Future<void> _getProductInfo() async {
    if (widget.barcode.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final productData = await ProductService.getProductData(widget.barcode);

    setState(() {
      product = productData;
      if (product != null) {
        labelLogosFuture = ProductUtils().getLabelLogos(product!.labels);
      }
      isLoading = false;
    });
  }

  Widget _buildProductImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(product?.imageUrl ?? 'assets/glass_bin.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      /*
      decoration: BoxDecoration(
        color: Colors.blueGrey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      */
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey[800],
        ),
      ),
    );
  }

  Widget _buildSectionTitleWithHelp(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle(title),
        IconButton(
          icon: Icon(Icons.help_outline),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Score PEF"),
                  content: Text(
                      "Le score PEF (Product Environmental Footprint) est un indicateur qui évalue l'impact environnemental d'un produit sur l'ensemble de son cycle de vie."),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Fermer'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoTile({required String title, String? subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      /*
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      */
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey[800],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              subtitle ?? 'Non disponible',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGeneralInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductImage(),
        const SizedBox(height: 16),
        _buildSectionTitle('Informations Générales'),
        const SizedBox(height: 8),
        _buildInfoTile(title: 'Nom du produit', subtitle: product?.name),
        _buildInfoTile(
            title: 'Dénomination générique', subtitle: product?.genericName),
        _buildInfoTile(title: 'Quantité', subtitle: product?.quantity),
        _buildInfoTile(title: 'Marques', subtitle: product?.brands?.join(', ')),
        _buildInfoTile(title: 'Catégories', subtitle: product?.categories),
        _buildLabelLogos(),
        const Divider(height: 32, thickness: 1),
      ],
    );
  }

  Widget _buildLabelLogos() {
    return FutureBuilder<List<String>>(
      future: labelLogosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Wrap(
            spacing: 10.0,
            children: snapshot.data!
                .map((logoUrl) => Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: SvgPicture.network(logoUrl, width: 50, height: 50),
                    ))
                .toList(),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildEnvironmentalInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Environnement'),
          const SizedBox(height: 10),
          Row(
            children: [
              SvgPicture.network(
                'https://static.openfoodfacts.org/images/attributes/dist/ecoscore-${product?.ecoScoreGrade}.svg',
                height: 50,
                width: 50,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Signification : ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      TextSpan(
                        text:
                            "L'Eco-Score est un score expérimental qui synthétise les impacts environnementaux des produits alimentaires.",
                        style: TextStyle(color: Colors.green[800]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackagingInfo() {
    final bool hasPackagingInfo =
        product?.packagings != null && product!.packagings!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informations sur l\'emballage'),
          if (!hasPackagingInfo)
            Center(
                child: Text('Informations indisponibles',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          if (hasPackagingInfo)
            ...product!.packagings!
                .map((packaging) => _buildPackagingTile(packaging)),
        ],
      ),
    );
  }

  Widget _buildPackagingTile(Packaging packaging) {
    String materialTranslation =
        ProductUtils().getMaterialTranslation(packaging.material);
    String shapeTranslation =
        ProductUtils().getShapeTranslation(packaging.shape);
    String recyclingTranslation =
        ProductUtils().getRecyclingTranslation(packaging.recycling);

    String weight = packaging.weightMeasured == 0.0
        ? 'N/C'
        : '${packaging.weightMeasured.toStringAsFixed(2)} g';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Matériel: ${materialTranslation}, Forme: ${shapeTranslation}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            'Poids: $weight',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            'Recyclage: $recyclingTranslation',
            style: TextStyle(fontSize: 14, color: Colors.green[700]),
          ),
          if (packaging.recycling == 'en:recycle-in-glass-bin')
            ElevatedButton(
              onPressed: () => MarkerUtils.navigateToNearestGlassBin(context),
              child: Text('Trouver le bac à verre le plus proche'),
            ),
        ],
      ),
    );
  }

  Widget _buildPEFInfoChart() {
    var displayValues = _displayAsPercentage
        ? [
            product!.pefInfo!.efAgriculture,
            product!.pefInfo!.efConsumption,
            product!.pefInfo!.efPackaging,
            product!.pefInfo!.efProcessing,
            product!.pefInfo!.efTransportation,
          ].map((value) => value / product!.pefInfo!.efTotal * 100).toList()
        : [
            product!.pefInfo!.efAgriculture,
            product!.pefInfo!.efConsumption,
            product!.pefInfo!.efPackaging,
            product!.pefInfo!.efProcessing,
            product!.pefInfo!.efTransportation,
          ];

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              color: Colors.green,
              value: displayValues[0],
              title: displayValues[0].toStringAsFixed(2) +
                  (_displayAsPercentage ? '%' : ' PEF'),
              radius: 50,
              titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffffffff)),
              showTitle: true,
            ),
            PieChartSectionData(
              color: Colors.blue,
              value: displayValues[1],
              title: displayValues[1].toStringAsFixed(2) +
                  (_displayAsPercentage ? '%' : ' PEF'),
              radius: 50,
              titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffffffff)),
              showTitle: true,
            ),
            PieChartSectionData(
              color: Colors.orange,
              value: displayValues[2],
              title: displayValues[2].toStringAsFixed(2) +
                  (_displayAsPercentage ? '%' : ' PEF'),
              radius: 50,
              titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffffffff)),
              showTitle: true,
            ),
            PieChartSectionData(
              color: Colors.red,
              value: displayValues[3],
              title: displayValues[3].toStringAsFixed(2) +
                  (_displayAsPercentage ? '%' : ' PEF'),
              radius: 50,
              titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffffffff)),
              showTitle: true,
            ),
            PieChartSectionData(
              color: Colors.purple,
              value: displayValues[4],
              title: displayValues[4].toStringAsFixed(2) +
                  (_displayAsPercentage ? '%' : ' PEF'),
              radius: 50,
              titleStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffffffff)),
              showTitle: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Agriculture', Colors.green),
            const SizedBox(width: 16),
            _buildLegendItem('Consommation', Colors.blue),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Emballage', Colors.orange),
            const SizedBox(width: 16),
            _buildLegendItem('Transformation', Colors.red),
            const SizedBox(width: 16),
            _buildLegendItem('Transport', Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(title),
      ],
    );
  }

  Widget _buildSwitchViewMode() {
    return SwitchListTile(
      title: Text(_displayAsPercentage
          ? "Afficher en %"
          : "Afficher les valeurs réelles"),
      value: _displayAsPercentage,
      onChanged: (bool newValue) {
        setState(() {
          _displayAsPercentage = newValue;
        });
      },
    );
  }

  Widget _buildPEFInfoWithLegend() {
    return Column(
      children: [
        _buildPEFInfoChart(),
        const SizedBox(height: 20),
        _buildChartLegend(),
      ],
    );
  }

  Widget _buildLifecycleInfo() {
    final bool hasPEFInfo =
        product?.pefInfo != null && product!.pefInfo!.efTotal > 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitleWithHelp('Analyse du cycle de vie'),
          const SizedBox(height: 10),
          if (!hasPEFInfo)
            Center(
                child: Text('Informations indisponibles',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          if (hasPEFInfo)
            Column(
              children: [
                Text(
                  'Score environnemental PEF : ${(product!.pefInfo!.efTotal * 100).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                _buildSwitchViewMode(),
                const SizedBox(height: 8),
                _buildPEFInfoWithLegend(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCO2ImpactChart() {
    final maxYValue = [
          product!.co2Impact!.co2Agriculture,
          product!.co2Impact!.co2Consumption,
          product!.co2Impact!.co2Packaging,
          product!.co2Impact!.co2Processing,
          product!.co2Impact!.co2Transportation,
        ].reduce(max) *
        100;

    final double roundedMaxYValue = max((maxYValue / 100).ceil() * 100, 100.0);

    var displayValues = _displayAsPercentage
        ? [
            product!.co2Impact!.co2Agriculture,
            product!.co2Impact!.co2Consumption,
            product!.co2Impact!.co2Packaging,
            product!.co2Impact!.co2Processing,
            product!.co2Impact!.co2Transportation,
          ].map((value) => value / product!.co2Impact!.co2Total * 100).toList()
        : [
            product!.co2Impact!.co2Agriculture,
            product!.co2Impact!.co2Consumption,
            product!.co2Impact!.co2Packaging,
            product!.co2Impact!.co2Processing,
            product!.co2Impact!.co2Transportation,
          ];

    String quantityStr = product!.quantity;
    List<String> parts = quantityStr.split(' ');
    int quantityInt = int.parse(parts[0]);

    return AspectRatio(
      aspectRatio: 1.7,
      child: BarChart(
        BarChartData(
          maxY: roundedMaxYValue,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: roundedMaxYValue / 5,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[400],
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text('${value.toInt()} g de CO2',
                      style: TextStyle(color: Colors.black, fontSize: 10));
                },
                interval: roundedMaxYValue / 5,
              ),
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.transparent,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                /*
                final String categories = {
                  0: 'Agriculture',
                  1: 'Consommation',
                  2: 'Emballage',
                  3: 'Transformation',
                  4: 'Transport',
                }[group.x.toInt()]!;
                */
                return BarTooltipItem(
                  // '$categories\n${rod.toY.toStringAsFixed(2)} g de CO2',
                  // '${rod.toY.toStringAsFixed(2)} g',
                  // use displayValues instead of rod.toY
                  _displayAsPercentage
                      ? '${displayValues[group.x.toInt()].toStringAsFixed(2)} %'
                      // : '${(displayValues[group.x.toInt()] * quantityInt).toStringAsFixed(2)} g',
                      : (displayValues[group.x.toInt()] * quantityInt) > 1000
                          ? '${(displayValues[group.x.toInt()] * quantityInt / 1000).toStringAsFixed(2)} kg'
                          : '${(displayValues[group.x.toInt()] * quantityInt).toStringAsFixed(2)} g',
                  TextStyle(
                      color: Colors.brown[800], fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: ((product!.co2Impact!.co2Agriculture * 100)),
                  color: Colors.green,
                  rodStackItems: [
                    BarChartRodStackItem(
                        0,
                        (product!.co2Impact!.co2Agriculture * 100),
                        Colors.green),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ],
              showingTooltipIndicators: [0],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: (product!.co2Impact!.co2Consumption * 100),
                  color: Colors.blue,
                  rodStackItems: [
                    BarChartRodStackItem(
                        0,
                        (product!.co2Impact!.co2Consumption * 100),
                        Colors.blue),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ],
              showingTooltipIndicators: [0],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: (product!.co2Impact!.co2Packaging * 100),
                  color: Colors.orange,
                  rodStackItems: [
                    BarChartRodStackItem(
                        0,
                        (product!.co2Impact!.co2Packaging * 100),
                        Colors.orange),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ],
              showingTooltipIndicators: [0],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(
                  toY: (product!.co2Impact!.co2Processing * 100),
                  color: Colors.red,
                  rodStackItems: [
                    BarChartRodStackItem(0,
                        (product!.co2Impact!.co2Processing * 100), Colors.red),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ],
              showingTooltipIndicators: [0],
            ),
            BarChartGroupData(
              x: 4,
              barRods: [
                BarChartRodData(
                  toY: (product!.co2Impact!.co2Transportation * 100),
                  color: Colors.purple,
                  rodStackItems: [
                    BarChartRodStackItem(
                        0,
                        (product!.co2Impact!.co2Transportation * 100),
                        Colors.purple),
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ],
              showingTooltipIndicators: [0],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCO2ImpactWithLegend() {
    return Column(
      children: [
        _buildCO2ImpactChart(),
        const SizedBox(height: 20),
        _buildChartLegend(),
      ],
    );
  }

  Widget _buildCarbonFootprintInfo() {
    final bool hasCO2Info =
        product?.co2Impact != null && product!.co2Impact!.co2Total > 0.0;

    double quantity = ProductUtils().convertQuantityToGramsOrLiters(product!.quantity);
    String totalCO2Str = ProductUtils().formatQuantityForDisplay(product!.quantity);

    double totalCO2 = product!.co2Impact!.co2Total * quantity;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Empreinte carbone'),
          const SizedBox(height: 10),
          if (!hasCO2Info)
            Center(
                child: Text('Informations indisponibles',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
          if (hasCO2Info)
            Column(
              children: [
                Text(
                  '${(product!.co2Impact!.co2Total * 100).toStringAsFixed(0)} g de CO2 pour 100 g de ce produit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Soit un total de $totalCO2Str de CO2 pour ce produit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                ),
                const SizedBox(height: 16),
                /*
                ElevatedButton(
                  onPressed: () => _showCO2Comparison(context),
                  child: Text("Qu'est-ce que cette valeur représente ?"),
                ),
                */
                _buildSwitchViewMode(),
                const SizedBox(height: 32),
                _buildCO2ImpactWithLegend(),
              ],
            ),
        ],
      ),
    );
  }

  /*
  void _showCO2Comparison(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Comparatif CO2 (source: impactco2.fr)"),
          content: SizedBox(
            height: 800,
            width: 400,
            child: ImpactCO2WebView(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product?.name ?? 'Détails du produit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).push("/"),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (product == null
              ? const Center(
                  child: Text('Aucune donnée disponible pour ce code-barres.'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildProductGeneralInfo(),
                        _buildEnvironmentalInfo(),
                        _buildPackagingInfo(),
                        _buildLifecycleInfo(),
                        _buildCarbonFootprintInfo(),
                      ],
                    ),
                  ),
                )),
    );
  }
}
