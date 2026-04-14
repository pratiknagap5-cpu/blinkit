class AddressModel {
  final int? id;
  final String label; // Home, Work, etc.
  final String address;
  final double latitude;
  final double longitude;

  AddressModel({
    this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id'],
      label: map['label'],
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
