import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _profileController = TextEditingController();
  List<String> profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profileMaps = await _dbHelper.getAllProfiles();
    setState(() {
      profiles = profileMaps.map((p) => p['name'] as String).toList();
    });
  }

  Future<void> _addProfile(String name) async {
    await _dbHelper.insertProfile(name);
    await _loadProfiles();
  }

  Future<void> _deleteProfile(String name) async {
    final profiles = await _dbHelper.getAllProfiles();
    final profile = profiles.firstWhere(
      (p) => p['name'] == name,
      orElse: () => {},
    );
    
    if (profile.isNotEmpty) {
      await _dbHelper.deleteProfile(profile['id']);
      await _loadProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Profiles'),
        backgroundColor: Colors.blue.shade300,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _profileController,
              decoration: InputDecoration(
                labelText: 'Add New Profile',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    if (_profileController.text.isNotEmpty) {
                      await _addProfile(_profileController.text);
                      _profileController.clear();
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  return ListTile(
                    title: Text(profile),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProfile(profile),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}