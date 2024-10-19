import 'package:business_finder/src/models/business_model.dart';
import 'package:business_finder/src/services/business_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class CreateBusinessPage extends ConsumerStatefulWidget {
  const CreateBusinessPage({super.key});

  @override
  _CreateBusinessPageState createState() => _CreateBusinessPageState();
}

class _CreateBusinessPageState extends ConsumerState<CreateBusinessPage> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String description = '';
  String categoryId = '';
  String contactNumber = '';
  String email = '';
  String? website;
  String imageUrl = '';
  double latitude = 0.0;
  double longitude = 0.0;
  String address = '';
  String city = '';
  String state = '';
  String country = 'Ethiopia'; // Pre-set to USA
  String postalCode = '';

  // Sample Data
  final List<String> categories = [
    'Restaurant',
    'Coffee Shop',
    'Grocery Store',
    'Clothing Store',
    'Tech Store',
  ];

  final List<String> cities = [
    'Addis Ababa',
    'Hawassa',
    'Mekele',
    'Gonder',
    'Bahirdar',
    'Adama',
    'Jimma',
    'Shire',
    'Semera',
    'Semera',
  ];

  final List<String> states = [
    'Addis Ababa',
    'Oromiya',
    'Tigray',
    'Amhara',
    'Debub',
    'Afar',
    'Gambela',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Business',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Business Name', (value) => name = value),
                _buildTextField('Description', (value) => description = value),
                _buildDropdown(
                  'Category',
                  categories,
                  (value) => categoryId = value!,
                ),
                _buildTextField(
                    'Contact Number', (value) => contactNumber = value),
                _buildTextField('Email', (value) => email = value),
                _buildTextField(
                    'Website (Optional)', (value) => website = value),
                _buildTextField('Image URL', (value) => imageUrl = value),

                // Row for Latitude and Longitude
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField('Latitude',
                          (value) => latitude = double.parse(value)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField('Longitude',
                          (value) => longitude = double.parse(value)),
                    ),
                  ],
                ),

                _buildTextField('Address', (value) => address = value),

                // Row for City and State
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        'City',
                        cities,
                        (value) => city = value!,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDropdown(
                        'State',
                        states,
                        (value) => state = value!,
                      ),
                    ),
                  ],
                ),

                // Row for Postal Code and Country
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                          'Postal Code', (value) => postalCode = value),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTextField(
                          'Country', (value) => country = value),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _saveBusiness,
                    child: const Text('Add Business'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dropdown Widget
  Widget _buildDropdown(
      String label, List<String> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) =>
            value == null || value.isEmpty ? 'Please select a $label' : null,
      ),
    );
  }

  // Text Field Widget
  Widget _buildTextField(String label, Function(String) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onSaved: (value) => onSaved(value ?? ''),
        validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  // Save Business Logic
  void _saveBusiness() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final business = BusinessModel(
        businessId: const Uuid().v4(),
        ownerId: FirebaseAuth.instance.currentUser!.uid,
        name: name,
        description: description,
        categoryId: categoryId,
        contactNumber: contactNumber,
        email: email,
        website: website,
        imageUrl: imageUrl,
        location: LocationModel(
          latitude: latitude,
          longitude: longitude,
          address: address,
          city: city,
          state: state,
          country: country,
          postalCode: postalCode,
        ),
        createdAt: DateTime.now(),
      );

      ref.read(businessServiceProvider).createBusiness(business);

      Navigator.pop(context);
    }
  }
}
