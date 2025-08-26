import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/bin.dart';
import '../data/models/geo_coordinates.dart';
import '../data/models/marker_category.dart';
import '../data/services/bin_service.dart';
import '../utils/marker_utils.dart';

class LocationPage extends StatefulWidget {
  final String title;
  final GeoCoordinates? centerCoordinates;

  const LocationPage({
    super.key,
    required this.title,
    this.centerCoordinates,
  });

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  late GoogleMapController mapController;
  LatLng? _selectedMarkerPosition;

  String? _mapStyle;
  final List<Marker> _markers = [];
  Set<Marker> _displayedMarkers = {};

  MarkerCategory? _selectedCategory;
  Position? _center;

  // Expérimental
  Map<MarkerId, MarkerCategory> _markerCategories = {};
  Set<MarkerCategory> _selectedCategories = {};

  //  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final coordinates = widget.centerCoordinates;

      if (coordinates != null) {
        _center = Position(
          latitude: coordinates.lat,
          longitude: coordinates.lon,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      } else {
        _determinePosition().then((position) {
          setState(() {
            _center = position;
          });
        });
      }
      _loadMarkers();
    });
  }

  Future<void> _loadMapStyle() async {
    if (kIsWeb) {
      _mapStyle = await rootBundle.loadString('assets/google_maps_style.txt');
    } else {
      _mapStyle = await rootBundle.loadString('assets/google_maps_style.txt');
    }
  }

  Future<void> _addMarker(Bin bin, BitmapDescriptor icon) async {
    final markerId = MarkerId(bin.binId);
    final marker = Marker(
      markerId: markerId,
      position: LatLng(bin.coordinates.lat, bin.coordinates.lon),
      icon: icon,
      infoWindow: InfoWindow(
        title: bin.locationName,
        snippet: 'Niveau de remplissage : ${bin.currentFillLevel}/${bin.capacity}',
        onTap: () {
          setState(() {
            _selectedMarkerPosition = LatLng(bin.coordinates.lat, bin.coordinates.lon);
          });
        },
      ),
    );
    setState(() {
      _markers.add(marker);
      _markerCategories[markerId] = bin.category;
    });
  }

  Future<void> _loadMarkers() async {
    List<Bin> glassBins = await BinService.getBinData('assets/mock_glass_bins.json');
    final BitmapDescriptor glassBinIcon = await _loadGlassBinIcons();

    List<Bin> batteryBins = await BinService.getBinData('assets/mock_battery_bins.json');
    final BitmapDescriptor batteryBinIcon = await _loadBatteryBinIcons();

    setState(() {
      _markers.clear();
      glassBins.forEach((bin) => _addMarker(bin, glassBinIcon));
      batteryBins.forEach((bin) => _addMarker(bin, batteryBinIcon));
    });

    _displayedMarkers = Set.from(_markers);
  }

  void _filterMarkersByCategory() {
    setState(() {
      Set<Marker> filteredMarkers = {};
      if (_selectedCategories.isEmpty) {
        filteredMarkers = Set.from(_markers);
      } else {
        filteredMarkers = _markers.where((marker) {
          final category = _markerCategories[marker.markerId];
          return _selectedCategories.contains(category);
        }).toSet();
      }

      _displayedMarkers = filteredMarkers;
    });
  }

  void _showCategoryFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Sélectionner les catégories"),
              content: SingleChildScrollView(
                child: ListBody(
                  children: MarkerCategory.values.map((category) {
                    return CheckboxListTile(
                      title: Text(category.toString().split('.').last),
                      value: _selectedCategories.contains(category),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedCategories.add(category);
                          } else {
                            _selectedCategories.remove(category);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Filtrer'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _filterMarkersByCategory();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedCategories.clear();
      _displayedMarkers = Set.from(_markers);
    });
  }

  Future<BitmapDescriptor> _loadGlassBinIcons() async {
    final Uint8List markerIcon =
        await MarkerUtils.getBytesFromAsset('assets/glass_bin.jpg', 50);
    return BitmapDescriptor.fromBytes(markerIcon);
  }

  Future<BitmapDescriptor> _loadBatteryBinIcons() async {
    final Uint8List markerIcon =
        await MarkerUtils.getBytesFromAsset('assets/battery_bin.jpg', 50);
    return BitmapDescriptor.fromBytes(markerIcon);
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Les services de localisation sont désactivés.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permission de localisation refusée.');
      }
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
  }

  Future<void> _launchGoogleMaps(LatLng position) async {
    final Uri url = Uri.https(
      'www.google.com',
      '/maps/search/',
      {'api': '1', 'query': '${position.latitude},${position.longitude}'},
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Impossible de lancer Google Maps';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraPosition = _center != null
        ? CameraPosition(
            target: LatLng(_center!.latitude, _center!.longitude), zoom: 15.0)
        : const CameraPosition(target: LatLng(0, 0), zoom: 0);

    Widget floatingActionButton;
    if (_selectedMarkerPosition != null) {
      floatingActionButton = FloatingActionButton(
        onPressed: () => _launchGoogleMaps(_selectedMarkerPosition!),
        child: Icon(Icons.directions),
        tooltip: 'Voir dans Google Maps',
      );
    } else {
      floatingActionButton = Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showCategoryFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetFilters,
          ),
        ],
      ),
      body: _center == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: cameraPosition,
              markers: Set.of(_displayedMarkers),
              myLocationEnabled: true,
              cloudMapId: kIsWeb ? '335704790b5b243e' : '335704790b5b243e',
            ),
      floatingActionButton: floatingActionButton,
    );
  }
}
