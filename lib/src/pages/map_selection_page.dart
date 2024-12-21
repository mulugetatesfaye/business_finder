import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng initialPosition;

  const MapPickerPage({super.key, required this.initialPosition});

  @override
  _MapPickerPageState createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late LatLng _selectedPosition;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.initialPosition,
          zoom: 16.0,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('selected-location'),
            position: _selectedPosition,
            draggable: true,
            onDragEnd: (LatLng newPosition) {
              setState(() {
                _selectedPosition = newPosition;
              });
            },
          ),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.pop(context, _selectedPosition); // Return new position
        },
        label: const Text('Finish Selection'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
