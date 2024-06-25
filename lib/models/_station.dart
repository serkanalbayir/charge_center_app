class Station {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final List<String> type; // Burada type List<String> olarak değiştirilmiştir
  final String powerOutput;
  final List<String> socketTypes;
  final String operatingHours;
  final String status;

  Station({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.powerOutput,
    required this.socketTypes,
    required this.operatingHours,
    required this.status,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      address: json['address'] ?? 'No address',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      type: (json['type'] is String) ? [json['type']] : List<String>.from(json['type'] ?? []),
      powerOutput: json['power_output'] ?? 'Unknown',
      socketTypes: List<String>.from(json['socket_types'] ?? []),
      operatingHours: json['operating_hours'] ?? 'Unknown',
      status: json['status'] ?? 'Unknown',
    );
  }
}
