import 'package:business_finder/src/models/business_model.dart';
import 'package:flutter/material.dart';

class BusinessDetailPage extends StatelessWidget {
  const BusinessDetailPage({super.key, required this.business});

  final BusinessModel business;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with business logo and name
            Container(
              color: Colors.orangeAccent,
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      business.imageUrl, // Replace with the business image URL
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          business.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Proper Fish & Chips!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Ratings and reviews
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return const Icon(
                        Icons.star,
                        color: Colors.orangeAccent,
                        size: 24,
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '4.6',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '(16 Ratings)',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),

            const Divider(),

            // Business attributes
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BusinessAttribute(
                    icon: Icons.diamond,
                    label: 'First Class Service',
                  ),
                  _BusinessAttribute(
                    icon: Icons.monetization_on,
                    label: 'Affordable Prices',
                  ),
                  _BusinessAttribute(
                    icon: Icons.business,
                    label: 'Local Business',
                  ),
                ],
              ),
            ),

            const Divider(),

            // Call, Website, Map buttons
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _BusinessActionButton(
                    icon: Icons.phone,
                    label: 'Call',
                  ),
                  _BusinessActionButton(
                    icon: Icons.language,
                    label: 'Website',
                  ),
                  _BusinessActionButton(
                    icon: Icons.map,
                    label: 'Map',
                  ),
                ],
              ),
            ),

            const Divider(),

            // Contact information and address
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    '+251-962437819',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '123 St. Fiyel bet, Addis Ababa, Ethiopia',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Open/Closed status
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.red,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Closed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
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

class _BusinessAttribute extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BusinessAttribute({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.grey),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class _BusinessActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _BusinessActionButton({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
