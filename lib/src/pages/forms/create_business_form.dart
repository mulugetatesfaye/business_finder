import 'dart:io';

import 'package:business_finder/src/models/business_model.dart';
import 'package:business_finder/src/pages/map_selection_page.dart';
import 'package:business_finder/src/services/business_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

class CreateBusinessPage extends ConsumerStatefulWidget {
  const CreateBusinessPage({super.key});

  @override
  _CreateBusinessPageState createState() => _CreateBusinessPageState();
}

class _CreateBusinessPageState extends ConsumerState<CreateBusinessPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  // Image-related variables
  File? _selectedImage;
  bool _isLoading = false; // Track loading state

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
  String country = 'Ethiopia'; // Pre-set to Ethiopia
  String postalCode = '';

  LatLng _initialPosition = const LatLng(9.03, 38.74); // Default: Addis Ababa

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    latitudeController.text = latitude.toString();
    longitudeController.text = longitude.toString();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled) {
      // Location services are not enabled, handle accordingly.
      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle accordingly.
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      latitude = position.latitude;
      longitude = position.longitude;
      latitudeController.text = latitude.toString();
      longitudeController.text = longitude.toString();
    });
  }

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
    'Jijiga',
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the selected image
                    if (_selectedImage != null)
                      Image.file(_selectedImage!, height: 200, width: 200),
                    const SizedBox(height: 10),

                    // Button to select an image
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Select Image from Gallery'),
                    ),
                    _buildTextField('Business Name', (value) => name = value),
                    _buildTextField(
                        'Description', (value) => description = value),
                    _buildDropdown(
                      'Category',
                      categories,
                      (value) => categoryId = value!,
                    ),
                    _buildTextField(
                        'Contact Number', (value) => contactNumber = value),
                    _buildTextField('Email', (value) => email = value),
                    _buildTextField('Website', (value) => website = value),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      icon: const Icon(Icons.pin_drop),
                      onPressed: () async {
                        final LatLng? pickedLocation = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapPickerPage(
                                initialPosition: _initialPosition),
                          ),
                        );

                        if (pickedLocation != null) {
                          setState(() {
                            latitude = pickedLocation.latitude;
                            longitude = pickedLocation.longitude;
                            latitudeController.text = latitude.toString();
                            longitudeController.text = longitude.toString();
                          });
                        }
                      },
                      label: const Text('Select Location on Map'),
                    ),

                    const SizedBox(height: 10),
                    // Row for Latitude and Longitude
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: latitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              latitude = double.tryParse(value) ?? 0.0;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: longitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              longitude = double.tryParse(value) ?? 0.0;
                            },
                          ),
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
          if (_isLoading) // Show loading overlay
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  // Function to pick and crop the image
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadImageToFirebase(File imageFile) async {
    try {
      String fileName =
          path.basename(imageFile.path); // Extract filename from path
      String storagePath =
          'business_images/$fileName'; // Define the upload path

      // Upload the image to Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      final uploadTask = ref.putFile(imageFile);

      // Wait until the upload is complete
      final snapshot = await uploadTask.whenComplete(() => {});

      // Get the download URL
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
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
  Future<void> _saveBusiness() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      if (_selectedImage != null) {
        imageUrl = await uploadImageToFirebase(_selectedImage!);
      }

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
        ),
        createdAt: DateTime.now(),
      );

      await ref.read(businessServiceProvider).createBusiness(business);

      Navigator.pop(context); // Close the page after saving
    } catch (e) {
      print('Error saving business: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save business')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }
}
