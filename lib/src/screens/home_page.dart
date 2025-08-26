import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../data/co2_savings_counter.dart';
import '../data/services/product_service.dart';

class CO2SavingsChart extends StatelessWidget {
  final Map<String, Map<String, double>> savingsData;
  final String period;

  const CO2SavingsChart({super.key, required this.savingsData, required this.period});

  @override
  Widget build(BuildContext context) {
    final List<BarChartGroupData> barGroups = _buildBarGroups(savingsData);

    return AspectRatio(
      aspectRatio: 1,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) =>
                    Text(_getBottomTitle(value.toInt())),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) =>
                    Text('${value.toInt()} kg CO2'),
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(Map<String, Map<String, double>> savingsData) {
    final List<BarChartGroupData> barGroups = [];
    savingsData.forEach((date, materials) {
      List<BarChartRodStackItem> rodStacks = [];
      double cumulativeSavings = 0;
      for (var entry in materials.entries) {
        final color = _getColorForMaterial(entry.key);
        cumulativeSavings += entry.value;
        rodStacks.add(BarChartRodStackItem(cumulativeSavings - entry.value, cumulativeSavings, color));
      }

      barGroups.add(BarChartGroupData(
        x: int.parse(date.substring(date.length - 2)),
        barRods: [
          BarChartRodData(
            toY: cumulativeSavings,
            rodStackItems: rodStacks,
            width: 22,
            borderRadius: BorderRadius.zero,
          ),
        ],
      ));
    });

    return barGroups;
  }

  Color _getColorForMaterial(String material) {
    switch (material) {
      case 'en:plastic':
        return Colors.blue;
      case 'en:paper-and-plastic':
        return Colors.blue;
      case 'en:glass':
        return Colors.green;
      case 'en:clear-glass':
        return Colors.green;
      case 'en:heavy-aluminium':
        return Colors.red;
      case 'en:non-corrugated-cardboard':
        return Colors.brown;
      case 'en:corrugated-cardboard':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  String _getBottomTitle(int index) {
    DateTime date;
    switch (period) {
      case 'daily':
        date = DateTime.now().subtract(Duration(days: index));
        return DateFormat('dd/MM').format(date);
      case 'weekly':
        date = DateTime.now().subtract(Duration(days: index));
        return DateFormat('dd/MM').format(date);
      case 'monthly':
        date = DateTime.now().subtract(Duration(days: index * 30));
        return DateFormat('MMMM').format(date);
      case 'annual':
        date = DateTime(DateTime.now().year - index);
        return DateFormat('yyyy').format(date);
      default:
        return 'Période $index';
    }
  }

  static Widget buildChartLegend() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Plastique', Colors.blue),
            const SizedBox(width: 16),
            _buildLegendItem('Verre', Colors.green),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Aluminium', Colors.grey),
            const SizedBox(width: 16),
            _buildLegendItem('Carton', Colors.brown),
          ],
        ),
      ],
    );
  }

  static Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }


}


class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedPeriod = 'daily';

  Future<void> _scanQRCode() async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(Icons.scanner),
                    title: Text('Scanner Produit'),
                    onTap: () => _performScan('Scanner Produit', 1)),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Recyclage'),
                  onTap: () => _requestItemCount(),
                ),
              ],
            ),
          );
        });
  }

  Future<void> _requestItemCount() async {
    Navigator.pop(context); // Ferme le menu
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nombre d\'objets recyclés'),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Entrez le nombre d'objets"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Confirmer'),
              onPressed: () {
                final int itemCount = int.tryParse(_controller.text) ?? 1;
                Navigator.of(context).pop();
                _performScan('Recyclage', itemCount);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _performScan(String mode, int itemCount) async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Annuler",
        true,
        ScanMode.QR,
      );
      if (barcodeScanRes == '-1') return;

      if (mode == 'Recyclage') {
        List<SavingRecord> savingsRecords =
            await ProductService.calculateCO2Savings(barcodeScanRes, itemCount);

        for (var record in savingsRecords) {
          await CO2SavingsCounter.addSavingRecord(record);
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Économie de CO2 mise à jour pour ${savingsRecords.length} matériaux!')));
        setState(() {});
      } else if (mode == 'Scanner Produit') {
        // Rediriger vers la page du produit
        GoRouter.of(context).go('/product/$barcodeScanRes');
      }
    } catch (e) {
      print('Erreur lors du scan: $e');
    }
  }

  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        GoRouter.of(context).push("/guide");
        break;
      case 2:
        GoRouter.of(context).push("/localisation");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedPeriod,
              onChanged: (String? newValue) {
                setState(() {
                  selectedPeriod = newValue!;
                });
              },
              items: <String>['daily', 'weekly', 'monthly', 'annual']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, Map<String, double>>>(
              future: CO2SavingsCounter.getCO2SavingsByPeriodAndMaterial(
                  selectedPeriod),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Erreur de chargement"));
                }
                if (snapshot.data!.isEmpty) {
                  return const Center(child: Text("Aucune donnée disponible"));
                }
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Les valeurs affichées représentent l'économie en kg/CO2*",
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                     CO2SavingsChart.buildChartLegend(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: CO2SavingsChart(
                          savingsData: snapshot.data!,
                          period: selectedPeriod,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scanQRCode,
        tooltip: 'Scanner QR Code',
        child: Icon(Icons.qr_code_scanner),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Guide',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Localisation',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onNavItemTapped,
      ),
    );
  }
}
