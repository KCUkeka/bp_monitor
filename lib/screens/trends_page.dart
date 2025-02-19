import 'package:flutter/material.dart';

class TrendsPage extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> profileReadings;

  // Constructor to accept profile readings
  const TrendsPage({Key? key, required this.profileReadings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Pressure Trends'),
        backgroundColor: Colors.blue.shade300,
      ),
      body: profileReadings.isEmpty
          ? Center(child: Text('No readings available.'))
          : ListView.builder(
              itemCount: profileReadings.keys.length,
              itemBuilder: (context, index) {
                String profileName = profileReadings.keys.elementAt(index);
                List<Map<String, dynamic>> readings = profileReadings[profileName]!;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileName,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        // Use ExpansionTile to show readings
                        ExpansionTile(
                          title: Text('Show Readings'),
                          children: readings.map((reading) {
                            return ListTile(
                              title: Text('Systolic: ${reading['systolic']} mmHg'),
                              subtitle: Text('Diastolic: ${reading['diastolic']} mmHg'),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
