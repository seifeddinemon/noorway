class AzkarItem {
  final String type;
  final String textAr;
  final String textEn;
  final String source;
  final int count;

  AzkarItem({
    required this.type,
    required this.textAr,
    required this.textEn,
    required this.source,
    this.count = 1,
  });

  factory AzkarItem.fromJson(Map<String, dynamic> json) {
    return AzkarItem(
      type: json['type'],
      textAr: json['text_ar'],
      textEn: json['text_en'],
      source: json['source'],
      count: json['count'] ?? 1,
    );
  }
}
