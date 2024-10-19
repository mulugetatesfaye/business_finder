import 'dart:async';
import 'package:business_finder/src/models/business_model.dart';
import 'package:business_finder/src/services/business_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final BusinessService _businessService = BusinessService();
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();

  List<BusinessModel> _businesses = [];
  List<BusinessModel> _filteredBusinesses = [];

  bool _isSearching = false;
  Position? _currentPosition;

  double _searchRadius = 5.0; // Radius in kilometers

  final CameraPosition _initialPosition = const CameraPosition(
    target:
        LatLng(9.0192, 38.7525), // Placeholder before getting user's location
    zoom: 14.0,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      final locationData = await _getUserLocation();

      setState(() {
        _currentPosition = Position(
          latitude: locationData.latitude!,
          longitude: locationData.longitude!,
          timestamp: DateTime.now(),
          accuracy: locationData.accuracy ?? 0,
          altitude: locationData.altitude ?? 0,
          heading: locationData.heading ?? 0,
          speed: locationData.speed ?? 0,
          speedAccuracy: locationData.speedAccuracy ?? 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      });

      // Animate to user's current location
      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(locationData.latitude!, locationData.longitude!),
            zoom: 17.0,
          ),
        ),
      );

      // Fetch businesses
      final businesses = await _businessService.fetchBusinessesOnce();
      if (businesses.isNotEmpty) {
        _businesses = businesses;

        // Filter businesses within the specified radius
        _businesses = _businesses.where((business) {
          final distance = _calculateDistance(business);
          return distance <= _searchRadius; // Filter by radius
        }).toList();

        // Sort filtered businesses by distance in ascending order
        _businesses.sort((a, b) {
          final distanceA = _calculateDistance(a);
          final distanceB = _calculateDistance(b);
          return distanceA.compareTo(distanceB); // Ascending order
        });

        _filteredBusinesses = List.from(_businesses);
        _loadBusinessMarkers(_businesses); // Load markers
      }
    } catch (e) {
      print('Error initializing map: $e');
    }
  }

  Future<LocationData> _getUserLocation() async {
    final location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) throw Exception('Location services are disabled.');
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception('Location permissions are denied.');
      }
    }

    return await location.getLocation();
  }

  void _loadBusinessMarkers(List<BusinessModel> businesses) {
    setState(() {
      _markers.addAll(
        businesses.map((business) {
          return Marker(
            markerId: MarkerId(business.businessId),
            position: LatLng(
              business.location.latitude,
              business.location.longitude,
            ),
            infoWindow: InfoWindow(
              title: business.name,
              snippet: business.location.address,
              onTap: () => _showBusinessDetails(business),
            ),
            icon: AssetMapBitmap(
              'assets/map-marker.png',
              width: 30,
              height: 30,
            ),
          );
        }).toList(),
      );
    });
  }

  double _calculateDistance(BusinessModel business) {
    if (_currentPosition == null) return 0.0;

    return Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          business.location.latitude,
          business.location.longitude,
        ) /
        1000; // Convert meters to kilometers
  }

  void _moveToLocation(BusinessModel business) async {
    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            business.location.latitude,
            business.location.longitude,
          ),
          zoom: 17.0,
        ),
      ),
    );
  }

  void _showBusinessDetails(BusinessModel business) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(business.name),
        content: Text(
          'Address: ${business.location.address}\nContact: ${business.contactNumber}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredBusinesses = _businesses
          .where((business) =>
              business.name.toLowerCase().contains(query.toLowerCase()) ||
              business.location.address
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'የት',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildMapAndListView(),
          if (_isSearching) _buildSearchOverlay(),
        ],
      ),
    );
  }

  Widget _buildMapAndListView() {
    return Column(
      children: [
        // Map takes half the screen height
        Flexible(
          flex: 7,
          child: GoogleMap(
            mapType: MapType.terrain,
            initialCameraPosition: _initialPosition,
            myLocationEnabled: true,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ),
        // List view takes the remaining space
        Flexible(
          flex: 4,
          child: ListView.separated(
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey[200],
            ),
            padding: const EdgeInsets.all(8.0), // Add padding around the list
            itemCount: _businesses.length,
            itemBuilder: (context, index) {
              final business = _businesses[index];
              final distance = _calculateDistance(business).toStringAsFixed(2);

              return InkWell(
                onTap: () => _moveToLocation(business),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Circular business image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          business.imageUrl,
                          width: 30,
                          height: 30,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12.0),

                      // Business name and address
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              business.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 4.0),
                                Expanded(
                                  child: Text(
                                    business.location.address,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow
                                        .ellipsis, // Handle long addresses
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Distance and additional icon
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$distance km',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          const Icon(Icons.arrow_forward_ios,
                              size: 16, color: Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchOverlay() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        children: [
          // Search Input Field
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Close search and return to the map and list view
                  setState(() {
                    _isSearching = false;
                  });
                },
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,

                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 4),
                    hintText: 'Search...',
                    border: InputBorder.none,
                  ),
                  onChanged: _onSearchChanged,
                  autofocus: true, // Automatically open the keyboard
                ),
              ),
            ],
          ),
          const Divider(),

          // Filtered Business List
          Expanded(
            child: ListView.builder(
              itemCount: _filteredBusinesses.length,
              itemBuilder: (context, index) {
                final business = _filteredBusinesses[index];
                final distance =
                    _calculateDistance(business).toStringAsFixed(2);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(business.imageUrl),
                  ),
                  title: Text(
                    business.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(business.location.address,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: Text(
                    '$distance km',
                    style: const TextStyle(color: Colors.green, fontSize: 14),
                  ),
                  onTap: () {
                    setState(() {
                      _isSearching = false;
                    });
                    _moveToLocation(business);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Method to build the drawer
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drawer Header
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.orangeAccent,
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'User Name', // Placeholder for the user's name
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Search Radius Slider
          ListTile(
            title: const Text('Search Radius (km)'),
            subtitle: Slider(
              min: 1,
              max: 20,
              divisions: 19,
              label: _searchRadius.toStringAsFixed(1),
              value: _searchRadius,
              onChanged: (value) {
                setState(() {
                  _searchRadius = value;
                  _initializeMap(); // Re-fetch businesses with the new radius
                });
              },
            ),
          ),
          // List of placeholder items
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              // Handle navigation
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Handle navigation
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              // Handle navigation
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              // Handle logout
              Navigator.pop(context); // Close the drawer
            },
          ),
        ],
      ),
    );
  }
}
