class AlgaeLog {
  final int? id;
  final DateTime date;
  final String waterColor;
  final double temperature;
  final double pH;
  final int lightHours;
  final String? photoPath;
  final String? notes;
  final String? type;
  final bool isWaterChanged;

  AlgaeLog({
    this.id,
    required this.date,
    required this.waterColor,
    required this.temperature,
    required this.pH,
    required this.lightHours,
    this.photoPath,
    this.notes,
    this.type,
    this.isWaterChanged = false,
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
      'type': type,
      'isWaterChanged': isWaterChanged ? 1 : 0,
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
      type: map['type'],
      isWaterChanged: (map['isWaterChanged'] ?? 0) == 1,
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
    String? type,
    bool? isWaterChanged,
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
      type: type ?? this.type,
      isWaterChanged: isWaterChanged ?? this.isWaterChanged,
    );
  }
} 