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
  Map<String, List<BloodPressureReading>> profileReadings = {};

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    final readings = await _dbHelper.getAllReadings();
    final grouped = <String, List<BloodPressureReading>>{};

    for (var readingMap in readings) {
      final reading = BloodPressureReading.fromMap(readingMap);
      if (!grouped.containsKey(reading.profile)) {
        grouped[reading.profile] = [];
      }
      grouped[reading.profile]!.add(reading);
    }

    setState(() => profileReadings = grouped);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        backgroundColor: Colors.blue.shade300,
      ),
      body: RefreshIndicator(
        onRefresh: _loadReadings,
        child: ListView.builder(
          itemCount: profileReadings.keys.length,
          itemBuilder: (context, index) {
            final profile = profileReadings.keys.elementAt(index);
            return Card(
              margin: EdgeInsets.all(8),
              child: ExpansionTile(
                title: Text(profile,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                children: profileReadings[profile]!
                    .map((reading) => ListTile(
                          title: Text(
                              '${reading.systolic}/${reading.diastolic} mmHg'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pulse: ${reading.pulse ?? "N/A"}'),
                              Text(DateFormat('yyyy-MM-dd')
                                  .format(reading.date)),
                              Text('Laterality: ${reading.laterality}'),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
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
                              if (result == true) _loadReadings();
                            },
                          ),
                        ))
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
