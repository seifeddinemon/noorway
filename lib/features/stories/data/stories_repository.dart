import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/prophet_story.dart';

class StoriesRepository {
  Future<List<ProphetStory>> getProphetsStories() async {
    final String response =
        await rootBundle.loadString('assets/data/prophets_stories.json');
    final List<dynamic> data = json.decode(response);

    return data.map((json) => ProphetStory.fromJson(json)).toList();
  }
}
