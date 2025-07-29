class AlgaeLog {
  final int? id;
  final DateTime date;
  final String waterColor;
  final double temperature;
  final double pH;
  final double lightHours;
  final String? photoPath;
  final String? notes;
  final String? type;
  final bool isWaterChanged;
  final DateTime? nextWaterChangeDate;
  final bool isFertilized;
  final DateTime? nextFertilizeDate;
  final double? waterVolume;
  final double? concentration; // 新增：藻類濃度 (mg/L)

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
    this.nextWaterChangeDate,
    this.isFertilized = false,
    this.nextFertilizeDate,
    this.waterVolume,
    this.concentration,
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
      'nextWaterChangeDate': nextWaterChangeDate?.toIso8601String(),
      'isFertilized': isFertilized ? 1 : 0,
      'nextFertilizeDate': nextFertilizeDate?.toIso8601String(),
      'waterVolume': waterVolume,
      'concentration': concentration,
    };
  }

  factory AlgaeLog.fromMap(Map<String, dynamic> map) {
    return AlgaeLog(
      id: map['id'],
      date: DateTime.parse(map['date']),
      waterColor: map['waterColor'],
      temperature: map['temperature'],
      pH: map['pH'],
      lightHours: map['lightHours'] is int ? (map['lightHours'] as int).toDouble() : map['lightHours'] as double,
      photoPath: map['photoPath'],
      notes: map['notes'],
      type: map['type'],
      isWaterChanged: (map['isWaterChanged'] ?? 0) == 1,
      nextWaterChangeDate: map['nextWaterChangeDate'] != null ? DateTime.parse(map['nextWaterChangeDate']) : null,
      isFertilized: (map['isFertilized'] ?? 0) == 1,
      nextFertilizeDate: map['nextFertilizeDate'] != null ? DateTime.parse(map['nextFertilizeDate']) : null,
      waterVolume: map['waterVolume'] != null ? (map['waterVolume'] is int ? (map['waterVolume'] as int).toDouble() : map['waterVolume'] as double) : null,
      concentration: map['concentration'] != null ? (map['concentration'] is int ? (map['concentration'] as int).toDouble() : map['concentration'] as double) : null,
    );
  }

  AlgaeLog copyWith({
    int? id,
    DateTime? date,
    String? waterColor,
    double? temperature,
    double? pH,
    double? lightHours,
    String? photoPath,
    String? notes,
    String? type,
    bool? isWaterChanged,
    DateTime? nextWaterChangeDate,
    bool? isFertilized,
    DateTime? nextFertilizeDate,
    double? waterVolume,
    double? concentration,
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
      nextWaterChangeDate: nextWaterChangeDate ?? this.nextWaterChangeDate,
      isFertilized: isFertilized ?? this.isFertilized,
      nextFertilizeDate: nextFertilizeDate ?? this.nextFertilizeDate,
      waterVolume: waterVolume ?? this.waterVolume,
      concentration: concentration ?? this.concentration,
    );
  }
}