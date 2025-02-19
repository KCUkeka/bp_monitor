import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/blood_pressure_reading.dart';
import 'package:intl/intl.dart';

class EditReadingPage extends StatefulWidget {
  final Map<String, dynamic> reading;
  final int documentId;

  const EditReadingPage({required this.reading, required this.documentId});

  @override
  _EditReadingPageState createState() => _EditReadingPageState();
}

class _EditReadingPageState extends State<EditReadingPage> {
  late TextEditingController systolicController;
  late TextEditingController diastolicController;
  late TextEditingController pulseController;
  late DateTime selectedDate;
  String? selectedLaterality;
  String? selectedProfile;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<String> profileOptions = [];
  final List<String> lateralityOptions = ['Left Arm', 'Right Arm'];

  @override
  void initState() {
    super.initState();
    _loadData();

    systolicController =
        TextEditingController(text: widget.reading['systolic'].toString());
    diastolicController =
        TextEditingController(text: widget.reading['diastolic'].toString());
    pulseController =
        TextEditingController(text: widget.reading['pulse']?.toString() ?? '');
    selectedDate = DateTime.parse(widget.reading['date']);
    selectedLaterality = widget.reading['laterality'];
    selectedProfile = widget.reading['profile'];
  }

  Future<void> _loadData() async {
    final profiles = await _dbHelper.getAllProfiles();
    setState(() {
      profileOptions = profiles.map((p) => p['name'] as String).toList();
      if (!profileOptions.contains(selectedProfile)) {
        profileOptions.add(selectedProfile!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Reading')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: systolicController,
              decoration: InputDecoration(labelText: 'Systolic (mmHg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: diastolicController,
              decoration: InputDecoration(labelText: 'Diastolic (mmHg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: pulseController,
              decoration: InputDecoration(labelText: 'Pulse'),
              keyboardType: TextInputType.number,
            ),
            ListTile(
              title: Text(
                  'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => selectedDate = picked);
                }
              },
            ),
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
            ),
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
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Save Changes'),
              onPressed: () async {
                final updatedReading = BloodPressureReading(
                  id: widget.documentId,
                  systolic: int.parse(systolicController.text),
                  diastolic: int.parse(diastolicController.text),
                  pulse: pulseController.text.isNotEmpty
                      ? int.parse(pulseController.text)
                      : null,
                  laterality: selectedLaterality!,
                  profile: selectedProfile!,
                  date: selectedDate,
                );

                await _dbHelper.updateReading(updatedReading.toMap());
                Navigator.pop(context, true);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Delete Reading'),
              onPressed: () async {
                await _dbHelper.deleteReading(widget.documentId);
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    );
  }
}
