import 'dart:async';
import 'package:business_finder/src/models/category_model.dart';
import 'package:business_finder/src/pages/widgets/grid_business_card.dart';
import 'package:business_finder/src/services/category_service.dart';
import 'package:business_finder/src/services/location_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/business_model.dart';
import '../providers/business_providers.dart';

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final querySnapshot =
      await FirebaseFirestore.instance.collection('categories').get();
  return querySnapshot.docs.map((doc) {
    return CategoryModel.fromJson(doc.data());
  }).toList();
});

final businessesByCategoryProvider =
    FutureProvider.family<List<BusinessModel>, String>((ref, categoryId) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('businesses')
      .where('categoryId', isEqualTo: categoryId)
      .get();

  return querySnapshot.docs
      .map((doc) => BusinessModel.fromJson(doc.data()))
      .toList();
});

// Riverpod state for managing search queries
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider to filter businesses based on search query
final filteredBusinessesProvider =
    Provider<AsyncValue<List<BusinessModel>>>((ref) {
  final query = ref.watch(searchQueryProvider);
  final asyncBusinesses = ref.watch(businessNotifierProvider);
  final lowerCaseQuery = query.toLowerCase();

  return asyncBusinesses.whenData((data) {
    return data.where((business) {
      final name = business.name.toLowerCase();
      final address = business.location!.address.toLowerCase();
      return name.contains(lowerCaseQuery) || address.contains(lowerCaseQuery);
    }).toList();
  });
});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  Position? _currentPosition;

  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(searchQueryProvider.notifier).state = _searchController.text;
    });
    _fetchCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.removeListener(() {});
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final position = await _locationService.fetchCurrentLocation();
      // Ensure the widget is still mounted before updating state
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      // Ensure the widget is still mounted before showing a Snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _refreshBusinesses() async {
    ref.invalidate(businessNotifierProvider);
  }

  @override
  Widget build(BuildContext context) {
    final businessesAsync = ref.watch(filteredBusinessesProvider);

    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _refreshBusinesses,
          child: businessesAsync.when(
            data: (businesses) => _buildBusinessList(businesses),
            loading: () => _buildLoadingState(),
            error: (error, _) => _buildErrorState(),
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessList(List<BusinessModel> businesses) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: Image.asset(
            'assets/yet_logo.png',
            height: 50,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_active_outlined,
                  color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        _buildSearchBar(),
        SliverToBoxAdapter(child: buildCategorySection()),

        // Only show the business section if there are businesses, otherwise display "No businesses found"
        businesses.isEmpty
            ? SliverToBoxAdapter(child: _buildEmptyState())
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    childAspectRatio: 2 / 2.5,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final business = businesses[index];
                      return GridBusinessCard(
                        business: business,
                        currentPosition:
                            _currentPosition, // Pass the user's location
                      );
                    },
                    childCount: businesses.length,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Failed to load data. Please try again.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshBusinesses,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverPersistentHeader(
      floating: true,
      pinned: true,
      delegate: _SearchBarDelegate(
        searchController: _searchController,
      ),
    );
  }

  Widget buildCategorySection() {
    return Container(
      padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      // color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: CategoryService.categories.map((category) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey[200],
                    child: Icon(
                      category.icon,
                      color: category.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.business,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No businesses found!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController searchController;

  const _SearchBarDelegate({
    required this.searchController,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: 0,
      child: Padding(
        padding:
            const EdgeInsets.only(top: 12.0, bottom: 8, left: 12.0, right: 12),
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'What are you looking for...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear(); // Clear the text field
                    },
                  )
                : null, // Don't show the clear button if the text field is empty
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 80;

  @override
  double get minExtent => 80;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
