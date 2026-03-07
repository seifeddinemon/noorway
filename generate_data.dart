import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() {
  final categories = [
    "morning",
    "evening",
    "after_prayer",
    "sleep",
    "general",
    "hadiths",
  ];
  final sources = [
    "Sahih Bukhari",
    "Sahih Muslim",
    "Tirmidhi",
    "Abu Dawood",
    "An-Nasa'i",
  ];
  final random = Random();

  final samples = {
    "morning": [
      [
        "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ",
        "We have reached the morning...",
      ],
      [
        "اللَّهُمَّ بِكَ أَصْبَحْنَا",
        "O Allah, by Your leave we have reached the morning...",
      ],
      [
        "أَصْبَحْنَا عَلَى فِطْرَةِ الْإِسْلَامِ",
        "We have reached the morning upon the natural religion of Islam...",
      ],
      [
        "يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ",
        "O Ever Living, O Self-Subsisting, by Your mercy I seek help...",
      ],
      [
        "حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ",
        "Allah is sufficient for me; there is no deity except Him...",
      ],
    ],
    "evening": [
      [
        "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ",
        "We have reached the evening...",
      ],
      [
        "اللَّهُمَّ بِكَ أَمْسَيْنَا",
        "O Allah, by Your leave we have reached the evening...",
      ],
      [
        "أَمْسَيْنَا عَلَى فِطْرَةِ الْإِسْلَامِ",
        "We have reached the evening upon the natural religion of Islam...",
      ],
      [
        "اللَّهُمَّ إِنِّي أَمْسَيْتُ أُشْهِدُكَ",
        "O Allah, I have reached the evening and I call You to witness...",
      ],
      [
        "اللَّهُمَّ مَا أَمْسَى بِي مِنْ نِعْمَةٍ",
        "O Allah, whatever blessing has reached me this evening...",
      ],
    ],
    "after_prayer": [
      [
        "أَسْتَغْفِرُ اللَّهَ (ثَلاثاً)",
        "I ask Allah for forgiveness (three times)",
      ],
      [
        "اللَّهُمَّ أَنْتَ السَّلامُ وَمِنْكَ السَّلامُ",
        "O Allah, You are Peace and from You is Peace",
      ],
      [
        "لا إِلَهَ إِلا اللَّه وحده لا شريك له",
        "None has the right to be worshipped but Allah alone",
      ],
      ["سُبْحَانَ اللَّهِ (33)", "Glory be to Allah (33 times)"],
      ["اللَّهُ أَكْبَرُ (33)", "Allah is Most Great (33 times)"],
    ],
    "sleep": [
      [
        "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا",
        "In Your name, O Allah, I die and I live.",
      ],
      [
        "اللَّهُمَّ قِنِي عَذَابَكَ",
        "O Allah, protect me from Your punishment...",
      ],
      [
        "بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي",
        "In Your name, my Lord, I lay my side...",
      ],
      [
        "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا",
        "Praise be to Allah Who fed us...",
      ],
      [
        "اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ",
        "O Allah, I have submitted myself to You...",
      ],
    ],
    "general": [
      [
        "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً",
        "Our Lord, give us in this world that which is good...",
      ],
      [
        "اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى",
        "O Allah, I ask You for guidance and piety...",
      ],
      [
        "يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي",
        "O Turner of hearts, keep my heart firm...",
      ],
      [
        "اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ",
        "O Allah, suffice me with Your lawful...",
      ],
      ["رَبِّ اشْرَحْ لِي صَدْرِي", "My Lord, expand for me my breast..."],
    ],
    "hadiths": [
      [
        "إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ",
        "Actions are but by intentions...",
      ],
      ["الدِّينُ النَّصِيحَةُ", "The religion is sincerity..."],
      [
        "خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ",
        "The best of you are those who learn the Quran...",
      ],
      [
        "مَنْ سَلَكَ طَرِيقًا يَلْتَمِسُ فِيهِ عِلْمًا",
        "Whoever follows a path in pursuit of knowledge...",
      ],
      [
        "لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ",
        "None of you believes until he loves for his brother...",
      ],
    ],
  };

  final List<Map<String, dynamic>> azkarData = [];

  for (final cat in categories) {
    final sampleList = samples[cat] ?? [];
    for (var i = 1; i <= 50; i++) {
      final sample = sampleList[random.nextInt(sampleList.length)];
      azkarData.add({
        "type": cat,
        "text_ar": "${sample[0]} ($i)",
        "text_en": "${sample[1]} [Item $i]",
        "source": sources[random.nextInt(sources.length)],
        "count": 1,
      });
    }
  }

  final file = File('assets/data/azkar.json');
  file.writeAsStringSync(jsonEncode(azkarData));
  stdout.writeln('Generated ${azkarData.length} items.');
}
