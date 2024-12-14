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
  bool _isLoading = true;

  final LatLng _initialLocation = LatLng(3.0738, 101.5183);

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
      _fetchNearbyPoliceStations(position.latitude, position.longitude);
    });
  }

  // Modify to fetch only nearby police stations from OpenStreetMap (Nominatim)
  Future<void> _fetchNearbyPoliceStations(double latitude, double longitude) async {
    const int radius = 1000; // Search radius in meters
    final String placeType = 'police';

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?format=json&q=$placeType&lat=$latitude&lon=$longitude&radius=$radius&addressdetails=1'
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        print('API Response for $placeType: ${response.body}');
        if (data.isNotEmpty) {
          setState(() {
            _markers.clear();
            for (var place in data) {
              final name = place['display_name'];
              final lat = double.parse(place['lat']);
              final lon = double.parse(place['lon']);
              
              // Add marker for each police station
              _markers.add(
                Marker(
                  markerId: MarkerId('$lat$lon'),
                  position: LatLng(lat, lon),
                  infoWindow: InfoWindow(
                    title: name,
                    snippet: 'Police Station',
                  ),
                ),
              );
            }
          });
        } else {
          print('No results found for $placeType.');
        }
      } catch (e) {
        print('Error decoding JSON response for $placeType: $e');
      }
    } else {
      print('Failed to fetch places for $placeType. Status code: ${response.statusCode}');
    }

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

  // Update the marker on the map when "View" button is pressed
  void _viewLocation(LatLng location) {
    mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(location, 15),
    );
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
              'Nearby Support Points',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : _markers.isNotEmpty
                      ? ListView.builder(
                          itemCount: _markers.length,
                          itemBuilder: (context, index) {
                            final marker = _markers.elementAt(index);
                            return SupportPointCard(
                              title: marker.infoWindow.title ?? 'Unknown Name',
                              distance: marker.infoWindow.snippet ?? 'No address available',
                              onViewPressed: () {
                                _viewLocation(marker.position);
                              },
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            'No nearby police stations found.',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
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
          Icons.local_police,
          size: 40,
          color: Colors.purple,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Vicinity: $distance'),
        trailing: ElevatedButton(
          onPressed: onViewPressed,
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
