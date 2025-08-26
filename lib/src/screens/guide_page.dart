import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../data/recycling_logo.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({super.key, required this.title});

  final String title;

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: ExpansionPanelList.radio(
          // Pas besoin de gérer l'état d'ouverture ici, ExpansionPanelList.radio s'en charge
          children: RecyclingLogoCategory.values.map<ExpansionPanelRadio>((category) {
            return ExpansionPanelRadio(
              value: category.index, // Utilisez l'index de la catégorie comme valeur unique
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(title: Text(category.label));
              },
              body: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: category.logos.length,
                itemBuilder: (context, index) {
                  final logo = category.logos[index];
                  return GestureDetector(
                    onTap: () => _showRecyclingLogoDetails(context, logo),
                    child: SvgPicture.asset(logo.imagePath),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showRecyclingLogoDetails(BuildContext context, RecyclingLogo logo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(logo.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                SvgPicture.asset(logo.imagePath),
                const SizedBox(height: 10),
                Text(logo.description),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
