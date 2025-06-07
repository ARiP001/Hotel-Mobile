import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'hotel_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/session_manager.dart';
import 'welcome_page.dart';

class TrackingPage extends StatefulWidget {
  final List<Map<String, dynamic>> hotels;
  const TrackingPage({super.key, required this.hotels});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(-7.782250, 110.415417); // default location, Yogyakarta
  Marker? _userMarker;
  String? latText;
  String? longText;
  Set<Marker> _hotelMarkers = {};
  final Map<String, Map<String, dynamic>> _markerIdToHotel = {};

  @override
  void initState() {
    super.initState();
    _checkSession();
    _loadLastLocation();
    requestPermission();
    startTracking();
    _setHotelMarkers();
  }

  Future<void> _checkSession() async {
    final isLoggedIn = await SessionManager.isLoggedIn();
    if (!isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    }
  }

  Future<void> _loadLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('last_lat');
    final lng = prefs.getDouble('last_lng');
    print('Loaded last location: lat=$lat, lng=$lng');
    if (lat != null && lng != null) {
      setState(() {
        _currentPosition = LatLng(lat, lng);
      });
    }
  }

  void _saveLastLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_lat', lat);
    await prefs.setDouble('last_lng', lng);
    print('Saved last location: lat=$lat, lng=$lng');
  }

  Future<void> requestPermission() async {
    var status = await Permission.location.request();
    if (status != PermissionStatus.granted) {
      // Tampilkan alert atau info ke user
      openAppSettings();
    }
  }

  void startTracking() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((position) {
      final newPosition = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentPosition = newPosition;
        latText = position.latitude.toStringAsFixed(6);
        longText = position.longitude.toStringAsFixed(6);
        _userMarker = Marker(
          markerId: const MarkerId('user'),
          position: newPosition,
          infoWindow: const InfoWindow(title: "Kamu di sini"),
        );
      });
      _saveLastLocation(position.latitude, position.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
    });
  }

  void _setHotelMarkers() {
    final markers = <Marker>{};
    _markerIdToHotel.clear();
    for (var hotel in widget.hotels) {
      final geo = hotel['geo'] ?? {};
      final lat = geo['latitude'];
      final lng = geo['longitude'];
      final markerId = hotel['key'] ?? hotel['name'] ?? '';
      if (lat != null && lng != null) {
        _markerIdToHotel[markerId] = hotel;
        markers.add(
          Marker(
            markerId: MarkerId(markerId),
            position: LatLng(lat.toDouble(), lng.toDouble()),
            infoWindow: InfoWindow(
              title: hotel['name'] ?? '-',
              snippet: 'Rating: ${hotel['review_summary']?['rating'] ?? '-'}',
              onTap: () {
                final hotelData = _markerIdToHotel[markerId];
                if (hotelData != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HotelDetailPage(hotel: hotelData),
                    ),
                  );
                }
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
      }
    }
    setState(() {
      _hotelMarkers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Location Tracker"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 12,
            ),
            markers: {
              if (_userMarker != null) _userMarker!,
              ..._hotelMarkers,
            },
            onMapCreated: (controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Lokasi Kamu Sekarang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Text(
                        latText != null && longText != null
                            ? 'Lat: $latText, Lng: $longText'
                            : 'Menunggu lokasi...',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(_currentPosition),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.my_location),
      ),
    );
  }
} 