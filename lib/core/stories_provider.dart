import 'package:flutter/foundation.dart';
import '../features/stories/data/stories_repository.dart';
import '../features/stories/models/prophet_story.dart';

class StoriesProvider with ChangeNotifier {
  final StoriesRepository _repository = StoriesRepository();
  List<ProphetStory> _stories = [];
  bool _isLoading = false;
  String? _error;

  List<ProphetStory> get stories => _stories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  StoriesProvider() {
    loadStories();
  }

  Future<void> loadStories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stories = await _repository.getProphetsStories();
    } catch (e) {
      _error = 'Failed to load stories: \$e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ProphetStory? getStoryById(String id) {
    try {
      return _stories.firstWhere((story) => story.id == id);
    } catch (_) {
      return null;
    }
  }
}
