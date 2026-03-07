class NameOfAllah {
  final int id;
  final String nameAr;
  final String nameEn;
  final String meaning;

  NameOfAllah({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.meaning,
  });

  factory NameOfAllah.fromJson(Map<String, dynamic> json) {
    return NameOfAllah(
      id: json['id'],
      nameAr: json['name_ar'],
      nameEn: json['name_en'],
      meaning: json['meaning'],
    );
  }
}
