import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class AssistancePage extends StatefulWidget {
  const AssistancePage({super.key});

  @override
  _AssistancePageState createState() => _AssistancePageState();
}

class _AssistancePageState extends State<AssistancePage> {
  GoogleMapController? mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = true;

  final LatLng _initialLocation = LatLng(2.9362, 101.7046); // Putrajaya coordinates

  // List to store support points
  List<Widget> _supportPoints = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    });

    // Once the position is fetched, update the markers and support points
    _addCustomMarkers();
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    // Use Geolocator to calculate distance between two points in meters
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    ) / 1000; // Convert meters to kilometers
  }

  void _addCustomMarkers() {
    if (_currentPosition == null) return; // Don't proceed if current location is not available

    // Define custom marker icons
    BitmapDescriptor policeIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    BitmapDescriptor hospitalIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

    // Coordinates of the support points
    LatLng policeStation = LatLng(2.9470, 101.6775); // Corrected Precinct 11 Police Station coordinates
    LatLng hospital = LatLng(2.9431, 101.7190); // Corrected Putrajaya Hospital coordinates

    // Calculate distance from user's current position to support points
    double policeStationDistance = _calculateDistance(
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      policeStation,
    );
    double hospitalDistance = _calculateDistance(
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      hospital,
    );

    // Add Precinct 11 Putrajaya Police Station marker
    _markers.add(
      Marker(
        markerId: const MarkerId('precinct_11_police'),
        position: policeStation,
        icon: policeIcon,
        infoWindow: const InfoWindow(
          title: 'Police Station Presint 11',
          snippet: '24 Hours Open',
        ),
      ),
    );

    // Add Putrajaya Hospital marker
    _markers.add(
      Marker(
        markerId: const MarkerId('putrajaya_hospital'),
        position: hospital,
        icon: hospitalIcon,
        infoWindow: const InfoWindow(
          title: 'Putrajaya Hospital Presint 7',
          snippet: '24 Hours Emergency',
        ),
      ),
    );

    setState(() {
      _isLoading = false;
    });

    // Add support point cards with distances
    _supportPoints = [
      SupportPointCard(
        title: 'Police Station Presint 11',
        distance: '${policeStationDistance.toStringAsFixed(2)} km',
        icon: Icons.local_police,
        onViewPressed: () {
          _viewLocationWithRoute(policeStation);
        },
      ),
      SupportPointCard(
        title: 'Putrajaya Hospital Presint 7',
        distance: '${hospitalDistance.toStringAsFixed(2)} km',
        icon: Icons.local_hospital,
        onViewPressed: () {
          _viewLocationWithRoute(hospital);
        },
      ),
    ];
  }

  // View Location Function with Route
  Future<void> _viewLocationWithRoute(LatLng destination) async {
    if (_currentPosition == null) return;

    final String url =
        'https://router.project-osrm.org/route/v1/driving/${_currentPosition!.longitude},${_currentPosition!.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];

      final List<LatLng> points = coordinates
          .map((coordinate) => LatLng(coordinate[1], coordinate[0]))
          .toList();

      setState(() {
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: PolylineId(destination.toString()),
          color: Colors.blue,
          width: 5,
          points: points,
        ));

        mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: points.reduce((a, b) => LatLng(
                a.latitude < b.latitude ? a.latitude : b.latitude,
                a.longitude < b.longitude ? a.longitude : b.longitude,
              )),
              northeast: points.reduce((a, b) => LatLng(
                a.latitude > b.latitude ? a.latitude : b.latitude,
                a.longitude > b.longitude ? a.longitude : b.longitude,
              )),
            ),
            50,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "BreakFree.",
          style: GoogleFonts.poppins(
            color: Color.fromARGB(255, 251, 247, 247),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: ModalRoute.of(context)?.settings.name == '/home'
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
              ),
        backgroundColor: const Color.fromARGB(255, 96, 32, 109),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _initialLocation,
                    zoom: 12.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  markers: _markers,
                  polylines: _polylines,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              ' Nearest Support Points',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: _supportPoints,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_currentPosition != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }
}

class SupportPointCard extends StatelessWidget {
  final String title;
  final String distance;
  final IconData icon;
  final VoidCallback onViewPressed;

  const SupportPointCard({
    Key? key,
    required this.title,
    required this.distance,
    required this.icon,
    required this.onViewPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 40,
          color: const Color.fromARGB(255, 96, 32, 109),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Distance: $distance'),
        trailing: ElevatedButton(
          onPressed: onViewPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 96, 32, 109),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'View',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}