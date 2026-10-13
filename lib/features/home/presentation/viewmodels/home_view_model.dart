import 'package:flutter/foundation.dart';

import '../../domain/entities/idea.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_ideas.dart';

enum HomeStatus { initial, loading, ready, error }

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required GetIdeas getIdeas,
    required GetCategories getCategories,
  })  : _getIdeas = getIdeas,
        _getCategories = getCategories;

  final GetIdeas _getIdeas;
  final GetCategories _getCategories;

  HomeStatus status = HomeStatus.initial;
  String selectedCategory = 'TODAS';
  String searchQuery = '';
  int navIndex = 0;
  List<String> categories = const [];
  List<Idea> _allIdeas = const [];
  String? errorMessage;

  List<Idea> get ideas {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _allIdeas;
    return _allIdeas.where((idea) {
      final haystack = [
        idea.title,
        idea.description,
        ...idea.skills,
        ...idea.categories,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList(growable: false);
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) {
      status = HomeStatus.loading;
      errorMessage = null;
      notifyListeners();
    }

    try {
      final loadedCategories = await _getCategories();
      final loadedIdeas = await _getIdeas(category: selectedCategory);

      categories = loadedCategories;
      _allIdeas = loadedIdeas;
      status = HomeStatus.ready;
    } catch (error) {
      status = HomeStatus.error;
      errorMessage = 'No se pudo cargar el feed. Revisa tu conexión.';
    }

    notifyListeners();
  }

  Future<void> selectCategory(String category) async {
    if (category == selectedCategory) return;

    selectedCategory = category;
    status = HomeStatus.loading;
    notifyListeners();

    try {
      _allIdeas = await _getIdeas(category: category);
      status = HomeStatus.ready;
    } catch (error) {
      status = HomeStatus.error;
      errorMessage = 'No se pudo filtrar. Intenta de nuevo.';
    }

    notifyListeners();
  }

  void setSearchQuery(String value) {
    if (value == searchQuery) return;
    searchQuery = value;
    notifyListeners();
  }

  void clearSearch() {
    if (searchQuery.isEmpty) return;
    searchQuery = '';
    notifyListeners();
  }

  void selectNav(int index) {
    navIndex = index;
    notifyListeners();
  }
}
