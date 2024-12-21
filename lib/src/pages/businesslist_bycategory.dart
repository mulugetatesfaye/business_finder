import 'package:business_finder/src/pages/business_detail_page.dart';
import 'package:business_finder/src/pages/business_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BusinessListPage extends ConsumerWidget {
  final String categoryId;

  const BusinessListPage({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessesByCategoryProvider(categoryId));

    return Scaffold(
      appBar: AppBar(title: const Text('Businesses')),
      body: businessesAsync.when(
        data: (businesses) {
          return ListView.builder(
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final business = businesses[index];
              return ListTile(
                title: Text(business.name),
                subtitle: Text(business.categoryId!),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BusinessDetailPage(businessModel: business),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
