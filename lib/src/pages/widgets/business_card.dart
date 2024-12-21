import 'package:business_finder/src/models/business_model.dart';
import 'package:business_finder/src/pages/business_detail_page.dart';
import 'package:flutter/material.dart';

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
            businessModel: business,
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
