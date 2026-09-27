class Kos {
  final int id;
  final String title;
  final String description;
  final int pricePerMonth;
  final String genderType;
  final double? latitude;
  final double? longitude;
  final String address;
  final bool isAvailable;
  final Owner? owner;
  final List<KosImage> images;
  final List<KosFacility> facilities;

  Kos({
    required this.id,
    required this.title,
    required this.description,
    required this.pricePerMonth,
    required this.genderType,
    this.latitude,
    this.longitude,
    required this.address,
    required this.isAvailable,
    this.owner,
    required this.images,
    required this.facilities,
  });

  factory Kos.fromJson(Map<String, dynamic> json) {
    return Kos(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pricePerMonth: json['price_per_month'] ?? 0,
      genderType: json['gender_type'] ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      address: json['address'] ?? '',
      isAvailable: json['is_available'] ?? true,
      owner: json['owner'] != null ? Owner.fromJson(json['owner']) : null,
      images: (json['images'] as List?)?.map((e) => KosImage.fromJson(e)).toList() ?? [],
      facilities: (json['facilities'] as List?)?.map((e) => KosFacility.fromJson(e)).toList() ?? [],
    );
  }
}

class Owner {
  final int id;
  final String name;
  final String email;
  final String? phone;

  Owner({required this.id, required this.name, required this.email, this.phone});

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
    );
  }
}

class KosImage {
  final int id;
  final String imagePath;
  final String? url;

  KosImage({required this.id, required this.imagePath, this.url});

  factory KosImage.fromJson(Map<String, dynamic> json) {
    return KosImage(
      id: json['id'],
      imagePath: json['image_path'] ?? '',
      url: json['url'],
    );
  }
}

class KosFacility {
  final int id;
  final String facilityName;

  KosFacility({required this.id, required this.facilityName});

  factory KosFacility.fromJson(Map<String, dynamic> json) {
    return KosFacility(
      id: json['id'],
      facilityName: json['facility_name'] ?? '',
    );
  }
}
