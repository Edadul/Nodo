import 'package:flutter/foundation.dart';

import '../../domain/entities/idea.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_ideas.dart';

enum HomeStatus { initial, loading, ready, error }

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required GetIdeas getIdeas,
    required GetCategories getCategories,
  })  : _getIdeas = getIdeas, // ignore: prefer_initializing_formals
        _getCategories = getCategories; // ignore: prefer_initializing_formals

  final GetIdeas _getIdeas;
  final GetCategories _getCategories;

  HomeStatus status = HomeStatus.initial;
  String selectedCategory = 'TODAS';
  int navIndex = 0;
  List<String> categories = const [];
  List<Idea> ideas = const [];
  String? errorMessage;

  Future<void> load() async {
    status = HomeStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      final loadedCategories = await _getCategories();
      final loadedIdeas = await _getIdeas(category: selectedCategory);

      categories = loadedCategories;
      ideas = loadedIdeas;
      status = HomeStatus.ready;
    } catch (error) {
      status = HomeStatus.error;
      errorMessage = error.toString();
    }

    notifyListeners();
  }

  Future<void> selectCategory(String category) async {
    if (category == selectedCategory) return;

    selectedCategory = category;
    status = HomeStatus.loading;
    notifyListeners();

    try {
      ideas = await _getIdeas(category: category);
      status = HomeStatus.ready;
    } catch (error) {
      status = HomeStatus.error;
      errorMessage = error.toString();
    }

    notifyListeners();
  }

  void selectNav(int index) {
    navIndex = index;
    notifyListeners();
  }
}
