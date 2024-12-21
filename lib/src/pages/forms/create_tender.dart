import 'package:business_finder/src/models/tender_model.dart';
import 'package:business_finder/src/services/tender_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TenderForm extends StatefulWidget {
  const TenderForm({super.key});

  @override
  _TenderFormState createState() => _TenderFormState();
}

class _TenderFormState extends State<TenderForm> {
  final _formKey = GlobalKey<FormState>();
  final TenderService _tenderService = TenderService();

  String? _title;
  String? _description;
  double? _budget;
  DateTime? _deadline;

  bool _isSubmitting = false;

  void _pickDeadline() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    setState(() {
      _deadline = selectedDate;
    });
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    try {
      final newTender = Tender(
        id: FirebaseFirestore.instance.collection('tenders').doc().id,
        userId: FirebaseAuth.instance.currentUser!.uid,
        title: _title!,
        description: _description,
        budget: _budget,
        deadline: _deadline,
        status: 'open',
        createdAt: DateTime.now(),
      );

      await _tenderService.createTender(newTender);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tender created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create tender: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Tender'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Title is required' : null,
                onSaved: (value) => _title = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                onSaved: (value) => _description = value,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Budget (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Budget is required';
                  }
                  final budget = double.tryParse(value);
                  if (budget == null || budget <= 0) {
                    return 'Enter a valid positive budget';
                  }
                  return null;
                },
                onSaved: (value) => _budget = double.parse(value!),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Deadline'),
                subtitle: Text(
                  _deadline != null
                      ? _deadline!.toLocal().toString().split(' ')[0]
                      : 'Select a deadline',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDeadline,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Create Tender'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
