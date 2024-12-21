import 'package:business_finder/src/models/business_model.dart';
import 'package:business_finder/src/pages/business_detail_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GridBusinessCard extends StatelessWidget {
  final BusinessModel business;
  final Position? currentPosition;

  const GridBusinessCard({
    super.key,
    required this.business,
    this.currentPosition,
  });

  double _calculateDistance(BusinessModel business) {
    if (currentPosition == null) return 0.0;

    return Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          business.location!.latitude,
          business.location!.longitude,
        ) /
        1000; // Convert meters to kilometers
  }

  @override
  Widget build(BuildContext context) {
    final distance = '${_calculateDistance(business).toStringAsFixed(1)} km';

    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BusinessDetailPage(
            businessModel: business,
          ),
        ));
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: Colors.black.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack for the image and overlayed info
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: business.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                // Overlay for rating and distance
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.8), // Overlay color
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          business.averageRating.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.pink.withOpacity(0.8), // Overlay color
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          distance,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Business name
                  Text(
                    business.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Category and City
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '${business.categoryId} • ${business.location!.city}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
