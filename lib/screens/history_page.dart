import 'package:flutter/material.dart';
import 'editreadingpage.dart';
import '../database/database_helper.dart';
import '../models/blood_pressure_reading.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<int, List<BloodPressureReading>> groupedReadings = {};
  List<Map<String, dynamic>> profiles = [];
  final Map<int, String> _profileNames = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final readings = await _dbHelper.getAllReadings();
    profiles = await _dbHelper.getProfiles();
    
    // Create profile name lookup
    _profileNames.clear();
    for (final profile in profiles) {
      _profileNames[profile['id'] as int] = profile['name'] as String;
    }

    // Group readings by profile ID
    final grouped = <int, List<BloodPressureReading>>{};
    for (var readingMap in readings) {
      final reading = BloodPressureReading.fromMap(readingMap);
      final profileId = reading.profileId ?? 0; // 0 = no profile
      
      if (!grouped.containsKey(profileId)) {
        grouped[profileId] = [];
      }
      grouped[profileId]!.add(reading);
    }

    setState(() => groupedReadings = grouped);
  }

  String _getProfileName(int profileId) {
    return _profileNames[profileId] ?? 'Unknown Profile';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.blue.shade300,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView.builder(
          itemCount: groupedReadings.keys.length,
          itemBuilder: (context, index) {
            final profileId = groupedReadings.keys.elementAt(index);
            final readings = groupedReadings[profileId]!;
            
            return Card(
              margin: const EdgeInsets.all(8),
              child: ExpansionTile(
                title: Text(
                  profileId == 0 ? 'No Profile' : _getProfileName(profileId),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: readings.map((reading) => ListTile(
                  title: Text(
                    '${reading.systolic}/${reading.diastolic} mmHg',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Heart Rate: ${reading.heartRate ?? "N/A"}'),
                      Text(DateFormat('yyyy-MM-dd – HH:mm')
                          .format(reading.dateTime)),
                      Text('Arm Side: ${reading.armSide}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditReadingPage(
                            reading: reading.toMap(),
                            documentId: reading.id!,
                          ),
                        ),
                      );
                      if (result == true) _loadData();
                    },
                  ),
                )).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}