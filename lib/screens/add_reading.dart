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
  String pulse = '';
  String? selectedLaterality;
  String? selectedProfile;
  DateTime selectedDate = DateTime.now();
  final List<String> lateralityOptions = ['Left Arm', 'Right Arm'];
  List<String> profileOptions = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profiles = await _dbHelper.getAllProfiles();
    setState(() {
      profileOptions = profiles.map((p) => p['name'] as String).toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Blood Pressure Reading'),
        backgroundColor: Colors.blue.shade300,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
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
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
                controller: TextEditingController(
                    text: DateFormat('yyyy-MM-dd').format(selectedDate)),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Select date' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Systolic (mmHg)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => systolic = v,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Diastolic (mmHg)'),
                keyboardType: TextInputType.number,
                onChanged: (v) => diastolic = v,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Pulse'),
                keyboardType: TextInputType.number,
                onChanged: (v) => pulse = v,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedLaterality,
                items: lateralityOptions
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedLaterality = v),
                decoration: InputDecoration(labelText: 'Laterality'),
                validator: (v) => v == null ? 'Required' : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedProfile,
                items: profileOptions
                    .map((v) => DropdownMenuItem(
                          value: v,
                          child: Text(v),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => selectedProfile = v),
                decoration: InputDecoration(labelText: 'Profile'),
                validator: (v) => v == null ? 'Required' : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade300,
                    padding: EdgeInsets.symmetric(vertical: 16)),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final reading = BloodPressureReading(
                      systolic: int.parse(systolic),
                      diastolic: int.parse(diastolic),
                      pulse: pulse.isNotEmpty
                          ? int.parse(pulse)
                          : null, // Changed from heartRate to pulse
                      laterality:
                          selectedLaterality!, // Changed from lateralitySide
                      profile: selectedProfile!, // Changed from profileName
                      date:
                          selectedDate, // Change 'dateTime' to 'date' (or the correct name)
                    );

                    try {
                      await _dbHelper.insertReading(reading.toMap());
                      Navigator.pop(context, true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error saving reading')));
                    }
                  }
                },
                child: Text('Save Reading'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
