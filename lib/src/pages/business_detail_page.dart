import 'package:business_finder/src/models/business_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessDetailPage extends StatelessWidget {
  final BusinessModel? businessModel;

  const BusinessDetailPage({super.key, this.businessModel});

  @override
  Widget build(BuildContext context) {
    final mockData = BusinessModel(
      businessId: '1',
      ownerId: '123',
      name: 'AlpineCabin - Views!',
      description:
          'Enjoy breathtaking views, an outdoor shower, hot tub, and more in this scenic location.',
      categoryId: 'luxury',
      contactNumber: '+123456789',
      email: 'contact@alpinecabin.com',
      website: 'https://alpinecabin.com',
      imageUrl: 'https://via.placeholder.com/800x400',
      location: LocationModel(
        latitude: 34.5322,
        longitude: -83.9847,
        address: '123 Mountain View Rd',
        city: 'Dahlonega',
        state: 'Georgia',
      ),
      averageRating: 5.0,
      reviewCount: 216,
      isFeatured: true,
      createdAt: DateTime.now(),
    );

    final data = businessModel ?? mockData;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.black,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  data.imageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _buildTitleSection(data),
                const Divider(),
                _buildDetailsSection(data),
                const Divider(),
                _buildAmenitiesSection(),
                const Divider(),
                _buildMapSection(data.location!),
              ]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(data),
    );
  }

  Widget _buildBottomNavigationBar(BusinessModel data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Call Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                _makePhoneCall(data.contactNumber!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.phone),
              label: const Text(
                'Call',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8), // Add space between the buttons
          // Message Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // _sendMessage(data.contactNumber);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.star, color: Colors.orange),
              label: const Text(
                'Give Review',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BusinessModel data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 16),
              Text(data.averageRating.toStringAsFixed(1)),
              const SizedBox(width: 8),
              Text('(${data.reviewCount} Reviews)'),
            ],
          ),
          const SizedBox(height: 8),
          Text('${data.location!.city}, ${data.location!.state}'),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BusinessModel data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.description!,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(
              height: 16), // Larger space below the description for clarity
          Text(
            'Contact: ${data.contactNumber}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8), // Space between contact and email
          Text(
            'Email: ${data.email}',
            style: const TextStyle(fontSize: 14),
          ),
          if (data.website != null) ...[
            const SizedBox(height: 8), // Space before website if it exists
            Text(
              'Website: ${data.website!}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection() {
    final amenities = [
      {'icon': Icons.landscape, 'label': 'Mountain view'},
      {'icon': Icons.kitchen, 'label': 'Kitchen'},
      {'icon': Icons.wifi, 'label': 'Wifi'},
      {'icon': Icons.work, 'label': 'Dedicated workspace'},
      {'icon': Icons.local_parking, 'label': 'Free parking'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What this place offers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Column(
            children: amenities.map((amenity) {
              return Padding(
                padding: const EdgeInsets.only(
                    bottom: 12.0), // Adds space between rows
                child: Row(
                  children: [
                    Icon(amenity['icon'] as IconData, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      amenity['label'] as String,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(LocationModel location) {
    final LatLng position = LatLng(location.latitude, location.longitude);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Where you’ll be',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: position,
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('businessLocation'),
                    position: position,
                  ),
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(location.address),
          Text('${location.city}, ${location.state}'),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String number) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: number,
    );

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $number';
    }
  }

  Future<void> _sendMessage(String number) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: number,
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      throw 'Could not send SMS to $number';
    }
  }
}
