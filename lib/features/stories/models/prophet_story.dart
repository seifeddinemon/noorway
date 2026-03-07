class ProphetStory {
  final String id;
  final String prophetNameAr;
  final String prophetNameEn;
  final String titleAr;
  final String titleEn;
  final String contentAr;
  final String contentEn;

  ProphetStory({
    required this.id,
    required this.prophetNameAr,
    required this.prophetNameEn,
    required this.titleAr,
    required this.titleEn,
    required this.contentAr,
    required this.contentEn,
  });

  factory ProphetStory.fromJson(Map<String, dynamic> json) {
    return ProphetStory(
      id: json['id'] as String,
      prophetNameAr: json['prophet_name_ar'] as String,
      prophetNameEn: json['prophet_name_en'] as String,
      titleAr: json['title_ar'] as String,
      titleEn: json['title_en'] as String,
      contentAr: json['content_ar'] as String,
      contentEn: json['content_en'] as String,
    );
  }
}
