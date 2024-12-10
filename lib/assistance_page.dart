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
  late GoogleMapController? mapController;
  Position? _currentPoisition;

  final LatLng _initialLocation = LatLng(3.0738, 101.5183);

  @override
  void initState(){
    super.initState();
    _getCurrentLocation();
  }

 Future<void> _getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  // Request location permission
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

  // Get the user's current location
  final position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  setState(() {
    _currentPoisition = position;

    // Ensure mapController is not null before animating the camera
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    }
  });
}
 void _onMapCreated(GoogleMapController controller) {
  mapController = controller;
  if (_currentPoisition != null) {
    mapController!.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(_currentPoisition!.latitude, _currentPoisition!.longitude),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        backgroundColor: Colors.purple[100],
        title: Text(
          'BreakFree.',
          style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Google Map
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
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Nearest Support Points Title
            Text(
              'Nearest Support Points',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Support Points List
            Expanded(
              child: ListView(
                children: const [
                  SupportPointCard(
                    icon: Icons.local_hospital,
                    title: 'Hospital',
                    distance: '0.5km',
                  ),
                  SupportPointCard(
                    icon: Icons.local_police,
                    title: 'Police Station',
                    distance: '1.2km',
                  ),
                  SupportPointCard(
                    icon: Icons.home,
                    title: 'Safe House',
                    distance: '5km',
                  ),
                ],
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
          shape: CircleBorder(),
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
        color: Colors.purple[100],
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.purple),
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),
              SizedBox(width: 40), // Space for the SOS button in the center
              IconButton(
                icon: Icon(Icons.person),
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
}

// Support Point Card Widget
class SupportPointCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String distance;

  const SupportPointCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.distance,
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
          color: Colors.purple,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Distance: $distance'),
        trailing: ElevatedButton(
          onPressed: () {
            // Implement the map view functionality here
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
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