import 'package:business_finder/src/models/tender_model.dart';
import 'package:business_finder/src/pages/forms/create_tender.dart';
import 'package:business_finder/src/pages/tender_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../services/tender_service.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  _VendorDashboardState createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  final TenderService _tenderService = TenderService();
  late Future<List<Tender>> _tendersFuture;

  @override
  void initState() {
    super.initState();
    _tendersFuture = _fetchOpenTenders();
  }

  Future<List<Tender>> _fetchOpenTenders() async {
    try {
      return await _tenderService.getOpenTendersOnce();
    } catch (e) {
      throw Exception("Failed to load tenders: ${e.toString()}");
    }
  }

  Future<void> _refreshTenders() async {
    setState(() {
      _tendersFuture = _fetchOpenTenders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tenders"),
        centerTitle: true,
        elevation: 0.0,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const TenderForm(),
                ));
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: FutureBuilder<List<Tender>>(
        future: _tendersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          } else {
            return RefreshIndicator(
              onRefresh: _refreshTenders,
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final tender = snapshot.data![index];
                  return _buildTenderCard(tender);
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTenderCard(Tender tender) {
    return GestureDetector(
      onTap: () {
        // Navigate to the detail page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TenderDetailPage(
                tender: tender), // Replace with your detail page widget
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Country flag and title
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tender.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Categories/Tags Section (mockup)
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Category 1', // Replace with dynamic data
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Category 2', // Replace with dynamic data
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Description (2 lines max)
              Text(
                tender.description ?? 'No description available.',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Publish and Closing Dates Row
              Row(
                children: [
                  _buildDateInfo(
                    FontAwesomeIcons.calendarDays,
                    "Publish Date",
                    tender.createdAt,
                  ),
                  const SizedBox(width: 12),
                  _buildDateInfo(
                    FontAwesomeIcons.calendarXmark,
                    "Closing Date",
                    tender.deadline,
                    isClosingDate: true,
                  ),
                ],
              ),
              Divider(
                color: Colors.grey[300],
              ),

              // Budget and Share/Favorite Icons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getTenderStatus(tender.deadline),
                    style: TextStyle(
                      fontSize: 16,
                      color: _getStatusColor(
                          tender.deadline), // Set color based on status
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.share,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          // TODO: Implement favorite logic
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get the tender status
  String _getTenderStatus(DateTime? closingDate) {
    if (closingDate == null) {
      return "N/A";
    }
    final isClosed = closingDate.isBefore(DateTime.now());
    return isClosed ? "Closed" : "Open";
  }

  // Helper method to get the color for the status
  Color _getStatusColor(DateTime? closingDate) {
    if (closingDate == null) {
      return Colors.black54; // Default color if no closing date
    }
    final isClosed = closingDate.isBefore(DateTime.now());
    return isClosed
        ? Colors.red
        : Colors.green; // Red for closed, green for open
  }

  Widget _buildDateInfo(IconData icon, String label, DateTime? date,
      {bool isClosingDate = false}) {
    Color textColor = Colors.black54;

    if (isClosingDate && date != null) {
      final daysRemaining = date.difference(DateTime.now()).inDays;

      // Check if the closing date is 1 day or less
      if (daysRemaining <= 1) {
        textColor = Colors.red; // Change color to red if 1 day or less
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          date != null ? _formatDate(date) : 'N/A',
          style: TextStyle(
              fontSize: 14, color: textColor), // Use dynamic text color
        ),
      ],
    );
  }

  // Helper method to build Date Info Row

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            "Something went wrong:\n$error",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _refreshTenders,
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No open tenders available right now.",
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}
