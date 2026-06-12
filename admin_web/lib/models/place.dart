class Place {
  final int id;
  final int categoryId;
  final String nameFr;
  final String nameAr;
  final String nameEn;
  final String? descriptionFr;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? googleMapsUrl;
  final double? latitude;
  final double? longitude;
  final String? image;
  final int isActive;
  final String? categoryNameFr;
  final String? categoryNameAr;
  final String? categoryNameEn;

  Place({
    required this.id,
    required this.categoryId,
    required this.nameFr,
    required this.nameAr,
    required this.nameEn,
    this.descriptionFr,
    this.descriptionAr,
    this.descriptionEn,
    this.googleMapsUrl,
    this.latitude,
    this.longitude,
    this.image,
    this.isActive = 1,
    this.categoryNameFr,
    this.categoryNameAr,
    this.categoryNameEn,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      categoryId: json['category_id'] is int ? json['category_id'] : int.parse(json['category_id'].toString()),
      nameFr: json['name_fr']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      descriptionFr: json['description_fr']?.toString(),
      descriptionAr: json['description_ar']?.toString(),
      descriptionEn: json['description_en']?.toString(),
      googleMapsUrl: json['google_maps_url']?.toString(),
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      image: json['image']?.toString(),
      isActive: json['is_active'] is int ? json['is_active'] : int.parse(json['is_active'].toString()),
      categoryNameFr: json['category_name_fr']?.toString(),
      categoryNameAr: json['category_name_ar']?.toString(),
      categoryNameEn: json['category_name_en']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'name_fr': nameFr,
      'name_ar': nameAr,
      'name_en': nameEn,
      'description_fr': descriptionFr,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'google_maps_url': googleMapsUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
