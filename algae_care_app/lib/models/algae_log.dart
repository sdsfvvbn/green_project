class AlgaeLog {
  final int? id;
  final DateTime date;
  final String waterColor;
  final double temperature;
  final double pH;
  final int lightHours;
  final String? photoPath;
  final String? notes;

  AlgaeLog({
    this.id,
    required this.date,
    required this.waterColor,
    required this.temperature,
    required this.pH,
    required this.lightHours,
    this.photoPath,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'waterColor': waterColor,
      'temperature': temperature,
      'pH': pH,
      'lightHours': lightHours,
      'photoPath': photoPath,
      'notes': notes,
    };
  }

  factory AlgaeLog.fromMap(Map<String, dynamic> map) {
    return AlgaeLog(
      id: map['id'],
      date: DateTime.parse(map['date']),
      waterColor: map['waterColor'],
      temperature: map['temperature'],
      pH: map['pH'],
      lightHours: map['lightHours'],
      photoPath: map['photoPath'],
      notes: map['notes'],
    );
  }

  AlgaeLog copyWith({
    int? id,
    DateTime? date,
    String? waterColor,
    double? temperature,
    double? pH,
    int? lightHours,
    String? photoPath,
    String? notes,
  }) {
    return AlgaeLog(
      id: id ?? this.id,
      date: date ?? this.date,
      waterColor: waterColor ?? this.waterColor,
      temperature: temperature ?? this.temperature,
      pH: pH ?? this.pH,
      lightHours: lightHours ?? this.lightHours,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
    );
  }
} 