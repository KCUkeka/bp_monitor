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

  Map<String, List<BloodPressureReading>> profileReadings = {};
  String? selectedProfile;

  @override
  void initState() {
    super.initState();
    _fetchProfileReadings();
  }

  Future<void> _fetchProfileReadings() async {
    final readings = await _dbHelper.getAllReadings();
    final grouped = <String, List<BloodPressureReading>>{};

    for (var readingMap in readings) {
      final reading = BloodPressureReading.fromMap(readingMap);
      if (!grouped.containsKey(reading.profile)) {
        grouped[reading.profile] = [];
      }
      grouped[reading.profile]!.add(reading);
    }

    setState(() {
      profileReadings = grouped;
      if (grouped.isNotEmpty) {
        selectedProfile = grouped.keys.first;
      }
    });
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
            MaterialPageRoute(builder: (context) => AddReadingPage()),
          );
          _fetchProfileReadings();
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
          profileReadings: profileReadings.map((key, value) =>
              MapEntry(key, value.map((reading) => reading.toMap()).toList())),
        );
      case 2:
        return ProfilePage();
      default:
        return HistoryPage();
    }
  }
}
