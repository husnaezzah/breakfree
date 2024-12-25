import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class AssistancePage extends StatefulWidget {
  const AssistancePage({super.key});

  @override
  _AssistancePageState createState() => _AssistancePageState();
}

class _AssistancePageState extends State<AssistancePage> {
  GoogleMapController? mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  final LatLng _initialLocation = LatLng(2.9362, 101.7046); // Putrajaya coordinates

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _addCustomMarkers();
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
  }

  void _addCustomMarkers() {
    // Define custom marker icons
    BitmapDescriptor policeIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    BitmapDescriptor hospitalIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

    // Add Precinct 11 Putrajaya Police Station marker
    _markers.add(
      Marker(
        markerId: const MarkerId('precinct_11_police'),
        position: const LatLng(2.9362, 101.7046), // Replace with actual coordinates
        icon: policeIcon,
        infoWindow: const InfoWindow(
          title: 'Precinct 11 Putrajaya Police Station',
          snippet: '24 Hours Open',
        ),
      ),
    );

    // Add Putrajaya Hospital marker
    _markers.add(
      Marker(
        markerId: const MarkerId('putrajaya_hospital'),
        position: const LatLng(2.9295, 101.6804), // Replace with actual coordinates
        icon: hospitalIcon,
        infoWindow: const InfoWindow(
          title: 'Putrajaya Hospital',
          snippet: '24 Hours Emergency',
        ),
      ),
    );

    setState(() {
      _isLoading = false;
    });
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

  // View Location Function
  void _viewLocation(LatLng location) {
    mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(location, 15),
    );
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
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Support Points',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        SupportPointCard(
                          title: 'Precinct 11 Putrajaya Police Station',
                          distance: '24 Hours Open',
                          onViewPressed: () {
                            _viewLocation(const LatLng(2.9362, 101.7046));
                          },
                        ),
                        SupportPointCard(
                          title: 'Putrajaya Hospital',
                          distance: '24 Hours Emergency',
                          onViewPressed: () {
                            _viewLocation(const LatLng(2.9295, 101.6804));
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportPointCard extends StatelessWidget {
  final String title;
  final String distance;
  final VoidCallback onViewPressed;

  const SupportPointCard({
    Key? key,
    required this.title,
    required this.distance,
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
          Icons.location_pin,
          size: 40,
          color: const Color.fromARGB(255, 96, 32, 109),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Vicinity: $distance'),
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
