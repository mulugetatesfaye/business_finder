import 'dart:async';
import 'package:business_finder/src/models/business_model.dart';
import 'package:business_finder/src/services/business_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final BusinessService _businessService = BusinessService();
  final Set<Marker> _markers = {};

  List<BusinessModel> _businesses = [];
  List<BusinessModel> _filteredBusinesses = [];

  Position? _currentPosition;
  double _searchRadius = 10.0;

  final FloatingSearchBarController _searchBarController =
      FloatingSearchBarController();
  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(9.0192, 38.7525), // Placeholder location
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
      _currentPosition = Position(
        latitude: locationData.latitude!,
        longitude: locationData.longitude!,
        timestamp: DateTime.now(),
        accuracy: locationData.accuracy ?? 0,
        altitude: locationData.altitude ?? 0,
        heading: locationData.heading ?? 0,
        speed: locationData.speed ?? 0,
        speedAccuracy: locationData.speedAccuracy ?? 0,
        headingAccuracy: locationData.headingAccuracy ?? 0,
        altitudeAccuracy: locationData.altitude ?? 0,
      );

      _moveCamera(
          LatLng(locationData.latitude!, locationData.longitude!), 17.0);
      await _fetchAndFilterBusinesses();
    } catch (e) {
      debugPrint('Error initializing map: $e');
    }
  }

  Future<LocationData> _getUserLocation() async {
    final location = Location();

    if (!(await location.serviceEnabled()) &&
        !(await location.requestService())) {
      throw Exception('Location services are disabled.');
    }

    if (await location.hasPermission() == PermissionStatus.denied &&
        await location.requestPermission() != PermissionStatus.granted) {
      throw Exception('Location permissions are denied.');
    }

    return await location.getLocation();
  }

  Future<void> _fetchAndFilterBusinesses() async {
    try {
      final businesses = await _businessService.fetchBusinessesOnce();
      if (businesses.isNotEmpty) {
        setState(() {
          _businesses =
              _filterBusinessesByRadius(businesses); // Filter businesses.
          _filteredBusinesses = List.from(_businesses);
          _loadBusinessMarkers(_filteredBusinesses); // Update markers.
        });
      }
    } catch (e) {
      debugPrint('Error fetching businesses: $e');
    }
  }

  List<BusinessModel> _filterBusinessesByRadius(
      List<BusinessModel> businesses) {
    return businesses
        .where((business) => _calculateDistance(business) <= _searchRadius)
        .toList()
      ..sort((a, b) => _calculateDistance(a).compareTo(_calculateDistance(b)));
  }

  void _showBusinessDetails(BusinessModel business) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(business.name),
        content: Text(
          'Address: ${business.location.address}\n'
          'Contact: ${business.contactNumber}',
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

  void _loadBusinessMarkers(List<BusinessModel> businesses) {
    setState(() {
      _markers.clear();
      _markers.addAll(businesses.map((business) {
        return Marker(
          markerId: MarkerId(business.businessId),
          position:
              LatLng(business.location.latitude, business.location.longitude),
          infoWindow: InfoWindow(
            title: business.name,
            snippet: business.location.address,
            onTap: () => _showBusinessDetails(business),
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        );
      }));
    });
  }

  double _calculateDistance(BusinessModel business) {
    if (_currentPosition == null) return double.infinity;
    return Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          business.location.latitude,
          business.location.longitude,
        ) /
        1000;
  }

  void _moveCamera(LatLng target, double zoom) async {
    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: zoom)),
    );
  }

  void _onSearchQueryChanged(String query) {
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
      resizeToAvoidBottomInset: false,
      drawer: _buildDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildGoogleMap(),
          _buildFloatingSearchBar(),
          Positioned(
            bottom: 16, // Adjust for padding at the bottom
            left: 0,
            right: 0,
            child: _buildBusinessHorizontalList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessHorizontalList() {
    return SizedBox(
      height: 120, // Compact height for the list
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: _filteredBusinesses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final business = _filteredBusinesses[index];
          return _buildFlatBusinessCard(business);
        },
      ),
    );
  }

// Business card with image on the right and subtle shadow for elevation
  Widget _buildFlatBusinessCard(BusinessModel business) {
    return GestureDetector(
      onTap: () {
        _moveCamera(
          LatLng(business.location.latitude, business.location.longitude),
          17.0,
        );
      },
      child: Container(
        width: 300, // Adjusted width for balanced layout
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.08), // Light shadow for subtle elevation
              blurRadius: 8, // Softer shadow
              offset:
                  const Offset(0, 4), // Positioned slightly below the widget
            ),
          ],
        ),
        child: Row(
          children: [
            // Business info on the left
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    business.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    business.location.address,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_pin,
                          size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        '${_calculateDistance(business).toStringAsFixed(2)} km away',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Image on the right with rounded corners
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                business.imageUrl,
                height: 80, // Smaller size to fit design
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      mapType: MapType.terrain,
      initialCameraPosition: _initialPosition,
      myLocationButtonEnabled: true,
      padding: const EdgeInsets.only(top: 90),
      myLocationEnabled: true,
      markers: _markers,
      onMapCreated: (controller) => _controller.complete(controller),
    );
  }

  Widget _buildFloatingSearchBar() {
    return FloatingSearchBar(
      controller: _searchBarController,
      hint: 'Search...',
      openAxisAlignment: 0.0,
      openWidth: 600,
      height: 52,
      elevation: 4.0,
      physics: const BouncingScrollPhysics(),
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: _onSearchQueryChanged,
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ),
      ],
      builder: (context, transition) {
        return Material(
          color: Colors.white,
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8.0),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _filteredBusinesses.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final business = _filteredBusinesses[index];
              return ListTile(
                title: Text(business.name),
                subtitle: Text(business.location.address),
                onTap: () {
                  _moveCamera(
                    LatLng(business.location.latitude,
                        business.location.longitude),
                    17.0,
                  );
                  _searchBarController.close();
                },
              );
            },
          ),
        );
      },
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.orangeAccent),
            child:
                CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          ),
          _buildDrawerItem(Icons.home, 'Home'),
          _buildDrawerItem(Icons.settings, 'Settings'),
          _buildDrawerItem(Icons.info, 'About'),
          _buildDrawerItem(Icons.exit_to_app, 'Logout'),
          _buildRadiusDropdown(),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => Navigator.pop(context),
    );
  }

  ListTile _buildRadiusDropdown() {
    return ListTile(
      leading: const Icon(Icons.radar),
      title: const Text('Radius'),
      trailing: DropdownButton<double>(
        value: _searchRadius,
        icon: const Icon(Icons.arrow_drop_down),
        items: [1.0, 5.0, 10.0, 15.0, 20.0]
            .map((value) => DropdownMenuItem(
                  value: value,
                  child: Text('${value.toInt()} km'),
                ))
            .toList(),
        onChanged: (value) async {
          setState(() {
            _searchRadius = value!;
          });

          await _fetchAndFilterBusinesses(); // Re-fetch and update markers.
        },
      ),
    );
  }
}
