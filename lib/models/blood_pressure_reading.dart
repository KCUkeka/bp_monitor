class BloodPressureReading {
  final int? id;
  final int systolic;
  final int diastolic;
  final int? heartRate;  // Changed from pulse
  final String armSide;  // Changed from laterality
  final int? profileId;  // Changed from profile (now int ID instead of String name)
  final DateTime dateTime;  // Changed from date

  BloodPressureReading({
    this.id,
    required this.systolic,
    required this.diastolic,
    this.heartRate,
    required this.armSide,
    this.profileId,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'systolic': systolic,
      'diastolic': diastolic,
      'heartRate': heartRate,       // Matches database column
      'armSide': armSide,           // Matches database column
      'profileId': profileId,       // Matches database column
      'dateTime': dateTime.toIso8601String(),  // Matches database column
    };
  }

  factory BloodPressureReading.fromMap(Map<String, dynamic> map) {
    return BloodPressureReading(
      id: map['id'],
      systolic: map['systolic'],
      diastolic: map['diastolic'],
      heartRate: map['heartRate'],
      armSide: map['armSide'],
      profileId: map['profileId'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }

  // Helper method if you need to combine with profile name
  String getProfileName(List<Map<String, dynamic>> profiles) {
    if (profileId == null) return 'No Profile';
    final profile = profiles.firstWhere(
      (p) => p['id'] == profileId,
      orElse: () => {'name': 'Unknown'},
    );
    return profile['name'];
  }
}