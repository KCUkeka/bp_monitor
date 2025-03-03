import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _profileController = TextEditingController();
  List<Map<String, dynamic>> profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profileMaps = await _dbHelper.getProfiles();
    setState(() => profiles = profileMaps);
  }

  Future<void> _addProfile(String name) async {
    if (name.isEmpty) return;
    await _dbHelper.insertProfile(name);
    _profileController.clear();
    await _loadProfiles();
  }

  Future<void> _deleteProfile(int id) async {
    await _dbHelper.deleteProfile(id);
    await _loadProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Profiles'),
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
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addProfile(_profileController.text.trim()),
                ),
              ),
              onSubmitted: (value) => _addProfile(value.trim()),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: profiles.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  return ListTile(
                    title: Text(
                      profile['name'] as String,
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProfile(profile['id'] as int),
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