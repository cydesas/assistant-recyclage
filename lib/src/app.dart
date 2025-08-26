import 'package:assistant_recyclage/src/screens/guide_page.dart';
import 'package:assistant_recyclage/src/screens/product_details_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:assistant_recyclage/src/screens/home_page.dart';
import 'package:assistant_recyclage/src/screens/localisation_page.dart';

import 'data/models/geo_coordinates.dart';

class App extends StatelessWidget {
  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(title: 'Accueil'),
      ),
      // route for the product details page
      GoRoute(
        path: "/product/:barcode",
        builder: (context, state) {
          final barcode = state.pathParameters['barcode'] ?? '';
          if (barcode.isNotEmpty) {
            return ProductPage(barcode: barcode);
          } else {
            return const ProductPage(barcode: '');
          }
        },
      ),
      GoRoute(
        path: "/guide",
        builder: (context, state) => const GuidePage(title: 'Guide'),
      ),
      GoRoute(
        path: "/localisation/:lat/:lon",
        builder: (context, state) {
          final lat = double.tryParse(state.pathParameters['lat'] ?? '');
          final lon = double.tryParse(state.pathParameters['lon'] ?? '');
          if (lat != null && lon != null) {
            return LocationPage(
              title: 'Localisation',
              centerCoordinates: GeoCoordinates(lat: lat, lon: lon),
            );
          } else {
            return const LocationPage(title: 'Localisation');
          }
        }
      ),
      GoRoute(
          path: '/localisation',
          builder: (context, state) => const LocationPage(title: 'Localisation')
      )

    ],
  );

  App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Assistant de Recyclage',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
