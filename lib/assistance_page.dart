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

    _addCustomMarkers();
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    ) / 1000; // Convert meters to kilometers
  }

  void _addCustomMarkers() {
    if (_currentPosition == null) return;

    BitmapDescriptor policeIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    BitmapDescriptor hospitalIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

    LatLng gombakPolice = LatLng(3.218796, 101.71331);
    LatLng primaSriGombakPolice = LatLng(3.236619, 101.69982);
    LatLng tamanMelawatiPolice = LatLng(3.212182, 101.747218);
    LatLng columbiaAsiaHospital = LatLng(3.2010, 101.7183);
    LatLng damaiServiceHospital = LatLng(3.1701, 101.6950);
    LatLng kualaLumpurHospital = LatLng(3.171362, 101.701736);

    _markers.add(
      Marker(
        markerId: const MarkerId('gombak_police'),
        position: gombakPolice,
        icon: policeIcon,
        infoWindow: const InfoWindow(
          title: 'Gombak Police Station',
        ),
      ),
    );

     _markers.add(
      Marker(
        markerId: const MarkerId('prima_sri_gombak_police'),
        position: primaSriGombakPolice,
        icon: policeIcon,
        infoWindow: const InfoWindow(
          title: 'Prima Sri Gombak Police Station',
        ),
      ),
    );

      _markers.add(
      Marker(
        markerId: const MarkerId('taman_melawati_police'),
        position: tamanMelawatiPolice,
        icon: policeIcon,
        infoWindow: const InfoWindow(
          title: 'Taman Melawati Police Station',
        ),
      ),
    );

     _markers.add(
      Marker(
        markerId: const MarkerId('columbia_asia_hospital'),
        position: columbiaAsiaHospital,
        icon: hospitalIcon,
        infoWindow: const InfoWindow(
          title: 'Columbia Asia Hospital',
        ),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('damai_service_hospital'),
        position: damaiServiceHospital,
        icon: hospitalIcon,
        infoWindow: const InfoWindow(
          title: 'Damai Service Hospital HQ',
        ),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId('kuala_lumpur_hospital'),
        position: kualaLumpurHospital,
        icon: hospitalIcon,
        infoWindow: const InfoWindow(
          title: 'Kuala Lumpur Hospital',
        ),
      ),
    );

    setState(() {
      _isLoading = false;
    });

    _supportPoints = [
      SupportPointCard(
        title: 'Gombak Police Station',
        icon: Icons.local_police,
        onViewPressed: () {
          _viewLocationWithRoute(gombakPolice);
        },
        description: 'Open 24 Hours',
      ),
      SupportPointCard(
        title: 'Prima Sri Gombak Police Station',
        icon: Icons.local_police,
        onViewPressed: () {
          _viewLocationWithRoute(primaSriGombakPolice);
        },
        description: 'Open 24 Hours',
      ),
      SupportPointCard(
        title: 'Taman Melawati Police Station',
        icon: Icons.local_police,
        onViewPressed: () {
          _viewLocationWithRoute(tamanMelawatiPolice);
        },
        description: 'Open 24 Hours',
      ),
      SupportPointCard(
        title: 'Columbia Asia Hospital',
        icon: Icons.local_hospital,
        onViewPressed: () {
          _viewLocationWithRoute(columbiaAsiaHospital);
        },
        description: 'Emergency Services Available',
      ),
      SupportPointCard(
        title: 'Damai Service Hospital HQ',
        icon: Icons.local_hospital,
        onViewPressed: () {
          _viewLocationWithRoute(damaiServiceHospital);
        },
        description: 'Specialist Services Available',
      ),
      SupportPointCard(
        title: 'Kuala Lumpur Hospital',
        icon: Icons.local_hospital,
        onViewPressed: () {
          _viewLocationWithRoute(kualaLumpurHospital);
        },
        description: 'Emergency Services Available',
      ),
    ];
  }

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
            fontSize: 24,
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
            Center(
              child: Text(
              'Tap on the map pins to view details, get directions, or open Google Maps for more options.',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
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
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/sos');
          },
          backgroundColor: Colors.red,
          shape: const CircleBorder(),
          child: Text(
            'SOS',
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: ModalRoute.of(context)?.settings.name == '/home' ?  Color(0xFFAD8FC6) : Colors.black,
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
              ),
              SizedBox(width: 40), // Space for the SOS button in the center
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: ModalRoute.of(context)?.settings.name == '/profile' ? Color(0xFFAD8FC6) : Colors.black,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
              ),
            ],
          ),
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
  final IconData icon;
  final VoidCallback onViewPressed;
  final String description;

  const SupportPointCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.onViewPressed,
    required this.description, 
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
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
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