import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'add_reading.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'trends_page.dart';
import '../database/database_helper.dart';
import '../models/blood_pressure_reading.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;
  late Color selectedItem = Colors.blue;
  Color unselectedItem = Colors.grey;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Map<int, List<BloodPressureReading>> groupedReadings = {};
  final Map<int, String> _profileNames = {};
  int? selectedProfileId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final readings = await _dbHelper.getAllReadings();
    final profiles = await _dbHelper.getProfiles();

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

    setState(() {
      groupedReadings = grouped;
      if (grouped.isNotEmpty) {
        selectedProfileId = grouped.keys.first;
      }
    });
  }

  String _getProfileName(int profileId) {
    return profileId == 0 ? 'No Profile' : _profileNames[profileId] ?? 'Unknown Profile';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (value) => setState(() => _index = value),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home,
                  color: _index == 0 ? selectedItem : unselectedItem),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.graph_circle_fill,
                  color: _index == 1 ? selectedItem : unselectedItem),
              label: 'Trends',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person,
                  color: _index == 2 ? selectedItem : unselectedItem),
              label: 'Profiles',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReadingPage()),
          );
          _loadData();
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade200,
                Colors.blue.shade400,
                Colors.blue.shade600,
              ],
              transform: const GradientRotation(3.14 / 4),
            ),
          ),
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      body: _getCurrentPage(),
    );
  }

  Widget _getCurrentPage() {
    switch (_index) {
      case 0:
        return HistoryPage();
      case 1:
        return TrendsPage(
          profileReadings: groupedReadings.map((key, value) => MapEntry(
            _getProfileName(key),
            value.map((reading) => reading.toMap()).toList(),
          )),
        );
      case 2:
        return  ProfilePage();
      default:
        return HistoryPage();
    }
  }
}