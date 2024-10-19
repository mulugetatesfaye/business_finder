import 'package:business_finder/src/pages/business_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/business_model.dart';
import '../providers/business_providers.dart';
import 'forms/create_business_form.dart';
import 'dart:async';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  late List<BusinessModel> _filteredBusinesses;
  List<BusinessModel> _allBusinesses = [];
  Timer? _debounce;

  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _filteredBusinesses = [];
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce
        ?.cancel(); // Cancel the debounce timer when the widget is disposed
    super.dispose();
  }

  // Fetch current location
  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {}); // Rebuild the widget after getting the position
    } catch (e) {
      // Handle the error of getting location
      print("Could not get location: $e");
    }
  }

  void _filterBusinesses(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBusinesses = List.from(_allBusinesses);
      } else {
        _filteredBusinesses = _allBusinesses
            .where((business) =>
                business.name.toLowerCase().contains(query.toLowerCase()) ||
                business.location.address
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onSearchChanged(String query) {
    // Cancel any existing timer
    _debounce?.cancel();
    // Start a new timer
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterBusinesses(query); // Call filtering after a delay
    });
  }

  Future<void> _refreshBusinesses() async {
    // Trigger the provider to fetch the latest businesses
    ref.invalidate(businessNotifierProvider);
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

  @override
  Widget build(BuildContext context) {
    final businessesAsync = ref.watch(businessNotifierProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateBusinessPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: businessesAsync.when(
        data: (businesses) {
          _allBusinesses = businesses;

          // Only filter and set the filtered businesses if the current position is known
          if (_currentPosition != null) {
            if (_searchController.text.isEmpty) {
              _filteredBusinesses = businesses;
            }
          }
          return _buildRefreshableList();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  // Widget that builds the pull-to-refresh functionality
  Widget _buildRefreshableList() {
    return RefreshIndicator(
      onRefresh:
          _refreshBusinesses, // The function that will be called on refresh
      child: _buildCustomScrollView(),
    );
  }

  // CustomScrollView with Search Input and Business List
  Widget _buildCustomScrollView() {
    return CustomScrollView(
      slivers: [
        // Collapsible SliverAppBar
        const SliverAppBar(
          backgroundColor: Colors.white,
          title: Text(
            'የት',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          pinned: true,
        ),
        _buildSearchBar(),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= _filteredBusinesses.length) {
                return Container(); // Safeguard against overflow
              }
              final business = _filteredBusinesses[index];
              return _buildBusinessCard(
                  business); // Use the BusinessCard widget here
            },
            childCount: _filteredBusinesses.length,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search for businesses...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ),
    );
  }

  // Widget to build each business tile using the custom BusinessCard widget
  Widget _buildBusinessCard(BusinessModel business) {
    double distanceValue = _calculateDistance(business);
    String formattedDistance = '${distanceValue.toStringAsFixed(1)} km';
    return BusinessCard(
      title: business.name,
      address: business.location.address,
      rating: 2.0,
      reviewsCount: 12,
      status: 'Open now',
      distance: formattedDistance,
      isSponsored: false,
      imageUrl: business.imageUrl,
      business: business,
    );
  }
}

class BusinessCard extends StatelessWidget {
  final BusinessModel business;
  final String title;
  final String address;
  final double rating;
  final int reviewsCount;
  final String status;
  final String distance;
  final bool isSponsored;
  final String imageUrl;

  const BusinessCard({
    super.key,
    required this.title,
    required this.address,
    required this.rating,
    required this.reviewsCount,
    required this.status,
    required this.distance,
    required this.isSponsored,
    required this.imageUrl,
    required this.business,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BusinessDetailPage(
            business: business,
          ),
        ));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Business Image or Logo
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              const SizedBox(width: 8.0),

              // Main Card Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Sponsored label
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (isSponsored)
                          Container(
                            margin: const EdgeInsets.only(left: 8.0),
                            padding: const EdgeInsets.symmetric(
                              vertical: 2.0,
                              horizontal: 8.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Text(
                              'SPONSORED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4.0),

                    // Rating and Reviews
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        const SizedBox(width: 4.0),
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          '($reviewsCount)',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4.0),

                    // Address
                    Text(
                      address,
                      style: const TextStyle(color: Colors.black87),
                    ),

                    const SizedBox(height: 4.0),

                    // Status (Open/Closed)
                    Row(
                      children: [
                        Text(
                          status,
                          style: TextStyle(
                            color: status.toLowerCase() == 'open now'
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (status.toLowerCase() == 'open now')
                          const Text(
                            ', Closes at midnight',
                            style: TextStyle(color: Colors.black54),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Distance
              Text(
                distance,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
