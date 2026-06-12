class Category {
  final int id;
  final String nameFr;
  final String nameAr;
  final String nameEn;
  final String icon;

  Category({
    required this.id,
    required this.nameFr,
    required this.nameAr,
    required this.nameEn,
    this.icon = 'category',
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nameFr: json['name_fr']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'category',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name_fr': nameFr,
      'name_ar': nameAr,
      'name_en': nameEn,
      'icon': icon,
    };
  }
}
