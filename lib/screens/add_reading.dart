import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/database_helper.dart';
import '../../models/blood_pressure_reading.dart';
import 'profile_page.dart';

class AddReadingPage extends StatefulWidget {
  const AddReadingPage({super.key});

  @override
  _AddReadingPageState createState() => _AddReadingPageState();
}

class _AddReadingPageState extends State<AddReadingPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String systolic = '';
  String diastolic = '';
  String heartRate = '';
  String? selectedArmSide;
  int? selectedProfileId;
  DateTime selectedDate = DateTime.now();
  final List<String> armSideOptions = ['Left', 'Right'];
  List<Map<String, dynamic>> profileOptions = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profiles = await _dbHelper.getProfiles();
    setState(() {
      profileOptions = profiles;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Blood Pressure Reading'),
        backgroundColor: Colors.blue.shade300,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  ProfilePage()),
              );
              _loadProfiles();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Date',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                controller: TextEditingController(
                    text: DateFormat('yyyy-MM-dd – HH:mm').format(selectedDate)),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Select date' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Systolic (mmHg)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => systolic = v,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Diastolic (mmHg)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => diastolic = v,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Heart Rate'),
                keyboardType: TextInputType.number,
                onChanged: (v) => heartRate = v,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedArmSide,
                items: armSideOptions
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedArmSide = v),
                decoration: const InputDecoration(labelText: 'Arm Side'),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedProfileId,
                items: profileOptions
                    .map((profile) => DropdownMenuItem(
                          value: profile['id'] as int,
                          child: Text(profile['name'] as String),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedProfileId = v),
                decoration: const InputDecoration(labelText: 'Profile'),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final reading = BloodPressureReading(
                      systolic: int.parse(systolic),
                      diastolic: int.parse(diastolic),
                      heartRate: heartRate.isNotEmpty
                          ? int.parse(heartRate)
                          : null,
                      armSide: selectedArmSide!,
                      dateTime: selectedDate,
                      profileId: selectedProfileId,
                    );

                    try {
                      await _dbHelper.insertReading(reading.toMap());
                      Navigator.pop(context, true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Error saving reading')));
                    }
                  }
                },
                child: const Text('Save Reading'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}