class BloodPressureReading {
  final int? id;
  final int systolic;
  final int diastolic;
  final int? pulse; // Should match this name
  final String laterality; // Should match this name
  final String profile; // Should match this name
  final DateTime date; // Should match this name

  BloodPressureReading({
    this.id,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    required this.laterality,
    required this.profile,
    required this.date, // Not dateTime
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'laterality': laterality,
      'profile': profile,
      'date': date.toIso8601String(), // Key matches database column
    };
  }

  factory BloodPressureReading.fromMap(Map<String, dynamic> map) {
    return BloodPressureReading(
      id: map['id'],
      systolic: map['systolic'],
      diastolic: map['diastolic'],
      pulse: map['pulse'],
      laterality: map['laterality'],
      profile: map['profile'],
      date: DateTime.parse(map['date']), // Matches database column
    );
  }
}