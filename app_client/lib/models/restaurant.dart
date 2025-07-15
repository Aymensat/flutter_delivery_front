class Restaurant {
  final String id;
  final String name;
  final List<String> images;
  final String description;
  final String address;
  final String contact;
  final String workingHours;
  final String cuisine;
  final double latitude;
  final double longitude;
  final double rating;
  final String? imageUrl;
  final OpeningHours? openingHours;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Restaurant({
    required this.id,
    required this.name,
    required this.images,
    required this.description,
    required this.address,
    required this.contact,
    required this.workingHours,
    required this.cuisine,
    required this.latitude,
    required this.longitude,
    required this.rating,
    this.imageUrl,
    this.openingHours,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id'],
      name: json['name'],
      images: List<String>.from(json['images'] ?? []),
      description: json['description'],
      address: json['address'],
      contact: json['contact'],
      workingHours: json['workingHours'],
      cuisine: json['cuisine'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      rating: json['rating'].toDouble(),
      imageUrl: json['imageUrl'],
      openingHours: json['openingHours'] != null
          ? OpeningHours.fromJson(json['openingHours'])
          : null,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class OpeningHours {
  final String open;
  final String close;

  OpeningHours({required this.open, required this.close});

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(open: json['open'], close: json['close']);
  }
}
