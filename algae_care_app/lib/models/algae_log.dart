class AlgaeLog {
  final int? id;
  final DateTime date;
  final String waterColor;
  final double temperature;
  final double pH;
  final int lightHours;
  final String? photoPath;
  final List<String>? photoPaths;
  final String? notes;
  final String? type;
  final bool isWaterChanged;
  final DateTime? nextWaterChangeDate;
  final List<String>? actions;

  AlgaeLog({
    this.id,
    required this.date,
    required this.waterColor,
    required this.temperature,
    required this.pH,
    required this.lightHours,
    this.photoPath,
    this.photoPaths,
    this.notes,
    this.type,
    this.isWaterChanged = false,
    this.nextWaterChangeDate,
    this.actions,
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
      'photoPaths': photoPaths?.join(','),
      'notes': notes,
      'type': type,
      'isWaterChanged': isWaterChanged ? 1 : 0,
      'nextWaterChangeDate': nextWaterChangeDate?.toIso8601String(),
      'actions': actions?.join(','),
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
      photoPaths: map['photoPaths'] != null && map['photoPaths'] != '' ? (map['photoPaths'] as String).split(',') : null,
      notes: map['notes'],
      type: map['type'],
      isWaterChanged: (map['isWaterChanged'] ?? 0) == 1,
      nextWaterChangeDate: map['nextWaterChangeDate'] != null ? DateTime.parse(map['nextWaterChangeDate']) : null,
      actions: map['actions'] != null && map['actions'] != '' ? (map['actions'] as String).split(',') : null,
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
    List<String>? photoPaths,
    String? notes,
    String? type,
    bool? isWaterChanged,
    DateTime? nextWaterChangeDate,
    List<String>? actions,
  }) {
    return AlgaeLog(
      id: id ?? this.id,
      date: date ?? this.date,
      waterColor: waterColor ?? this.waterColor,
      temperature: temperature ?? this.temperature,
      pH: pH ?? this.pH,
      lightHours: lightHours ?? this.lightHours,
      photoPath: photoPath ?? this.photoPath,
      photoPaths: photoPaths ?? this.photoPaths,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      isWaterChanged: isWaterChanged ?? this.isWaterChanged,
      nextWaterChangeDate: nextWaterChangeDate ?? this.nextWaterChangeDate,
      actions: actions ?? this.actions,
    );
  }
} 