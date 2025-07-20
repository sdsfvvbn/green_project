class AlgaeProfile {
  int? id;
  String species;
  String? name;
  int ageDays;
  double length;
  double width;
  String waterSource;
  String lightType;
  String? lightTypeDescription;
  String? lightIntensityLevel;
  int waterChangeFrequency;
  double waterVolume;
  String fertilizerType;
  String? fertilizerDescription;

  AlgaeProfile({
    this.id,
    required this.species,
    this.name,
    required this.ageDays,
    required this.length,
    required this.width,
    required this.waterSource,
    required this.lightType,
    this.lightTypeDescription,
    this.lightIntensityLevel,
    required this.waterChangeFrequency,
    required this.waterVolume,
    required this.fertilizerType,
    this.fertilizerDescription,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'species': species,
      'name': name,
      'ageDays': ageDays,
      'length': length,
      'width': width,
      'waterSource': waterSource,
      'lightType': lightType,
      'lightTypeDescription': lightTypeDescription,
      'lightIntensityLevel': lightIntensityLevel,
      'waterChangeFrequency': waterChangeFrequency,
      'waterVolume': waterVolume,
      'fertilizerType': fertilizerType,
      'fertilizerDescription': fertilizerDescription,
    };
  }

  factory AlgaeProfile.fromMap(Map<String, dynamic> map) {
    return AlgaeProfile(
      id: map['id'] as int?,
      species: map['species'] as String,
      name: map['name'] as String?,
      ageDays: map['ageDays'] as int,
      length: map['length'] is int ? (map['length'] as int).toDouble() : map['length'] as double,
      width: map['width'] is int ? (map['width'] as int).toDouble() : map['width'] as double,
      waterSource: map['waterSource'] as String,
      lightType: map['lightType'] as String,
      lightTypeDescription: map['lightTypeDescription'] as String?,
      lightIntensityLevel: map['lightIntensityLevel'] as String?,
      waterChangeFrequency: map['waterChangeFrequency'] as int,
      waterVolume: map['waterVolume'] is int ? (map['waterVolume'] as int).toDouble() : map['waterVolume'] as double,
      fertilizerType: map['fertilizerType'] as String,
      fertilizerDescription: map['fertilizerDescription'] as String?,
    );
  }
} 