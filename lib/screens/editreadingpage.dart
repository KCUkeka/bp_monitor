import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/blood_pressure_reading.dart';

class EditReadingPage extends StatefulWidget {
  final Map<String, dynamic> reading;
  final int documentId;

  const EditReadingPage({
    super.key,
    required this.reading,
    required this.documentId,
  });

  @override
  _EditReadingPageState createState() => _EditReadingPageState();
}

class _EditReadingPageState extends State<EditReadingPage> {
  late TextEditingController systolicController;
  late TextEditingController diastolicController;
  late TextEditingController heartRateController;
  late DateTime selectedDate;
  String? selectedArmSide;
  int? selectedProfileId;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> profileOptions = [];
  final List<String> armSideOptions = ['Left', 'Right'];

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Initialize form values from existing reading
    systolicController = TextEditingController(
      text: widget.reading['systolic'].toString()
    );
    diastolicController = TextEditingController(
      text: widget.reading['diastolic'].toString()
    );
    heartRateController = TextEditingController(
      text: widget.reading['heartRate']?.toString() ?? ''
    );
    selectedDate = DateTime.parse(widget.reading['dateTime']);
    selectedArmSide = widget.reading['armSide'];
    selectedProfileId = widget.reading['profileId'];
  }

  Future<void> _loadData() async {
    final profiles = await _dbHelper.getProfiles();
    setState(() {
      profileOptions = profiles;
      // Set initial profile if not already set
      selectedProfileId ??= profiles.isNotEmpty 
          ? profiles.first['id'] as int 
          : null;
    });
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
      );
      
      if (pickedTime != null) {
        setState(() {
          selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Reading')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: systolicController,
              decoration: const InputDecoration(labelText: 'Systolic (mmHg)'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: diastolicController,
              decoration: const InputDecoration(labelText: 'Diastolic (mmHg)'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: heartRateController,
              decoration: const InputDecoration(labelText: 'Heart Rate'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value!.isNotEmpty && int.tryParse(value) == null) {
                  return 'Enter valid number';
                }
                return null;
              },
            ),
            ListTile(
              title: Text(DateFormat('yyyy-MM-dd – HH:mm').format(selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDateTime(context),
            ),
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
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Save Changes'),
              onPressed: () async {
                final heartRate = heartRateController.text.trim();
                
                final updatedReading = BloodPressureReading(
                  id: widget.documentId,
                  systolic: int.parse(systolicController.text),
                  diastolic: int.parse(diastolicController.text),
                  heartRate: heartRate.isNotEmpty 
                      ? int.parse(heartRate) 
                      : null,
                  armSide: selectedArmSide ?? 'Left',
                  dateTime: selectedDate,
                  profileId: selectedProfileId,
                );

                try {
                  await _dbHelper.updateReading(updatedReading.toMap());
                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating reading: $e')));
                }
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete Reading'),
              onPressed: () async {
                try {
                  await _dbHelper.deleteReading(widget.documentId);
                  Navigator.pop(context, true);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting reading: $e')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}