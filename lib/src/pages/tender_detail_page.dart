import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/tender_model.dart';

class TenderDetailPage extends StatelessWidget {
  final Tender tender;

  const TenderDetailPage({super.key, required this.tender});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tender.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border, color: Colors.amber),
            onPressed: () {
              // TODO: Implement favorite functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country and Categories

            const SizedBox(height: 20),

            // Description Section
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tender.description ?? "No description available.",
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),

            // Budget and Date Information
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard(
                  FontAwesomeIcons.solidMoneyBillAlt,
                  "Budget",
                  tender.budget != null ? "${tender.budget} Br" : "N/A",
                  Colors.green,
                ),
                _buildInfoCard(
                  FontAwesomeIcons.calendarAlt,
                  "Published On",
                  _formatDate(tender.createdAt),
                  Colors.blue,
                ),
                _buildInfoCard(
                  FontAwesomeIcons.calendarTimes,
                  "Closing On",
                  _formatDate(tender.deadline),
                  Colors.redAccent,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Call to Action (Submit Bid Button)
            SizedBox(
              width: double.maxFinite,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement bid submission logic
                },
                icon: const Icon(FontAwesomeIcons.paperPlane, size: 18),
                label: const Text(
                  "Submit Bid",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Additional Notes Section (Optional)
            const Text(
              "Additional Notes",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Feel free to contact us for further inquiries or clarifications about the tender.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return "${date.day}-${date.month}-${date.year}";
  }
}
