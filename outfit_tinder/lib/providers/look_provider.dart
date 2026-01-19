import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/look.dart';

class LookProvider extends ChangeNotifier {
  List<Look> _looks = [];
  bool _isDarkMode = false;
  String _searchQuery = '';
  String _filterStyle = 'All';

  List<Look> get looks {
    List<Look> filtered = _looks;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((look) =>
              look.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              look.style.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply style filter
    if (_filterStyle != 'All') {
      filtered =
          filtered.where((look) => look.style == _filterStyle).toList();
    }

    return filtered;
  }

  List<Look> get allLooks => _looks;
  bool get isDarkMode => _isDarkMode;
  String get searchQuery => _searchQuery;
  String get filterStyle => _filterStyle;

  // Get list of unique styles
  List<String> get availableStyles {
    final styles = _looks.map((look) => look.style).toSet().toList();
    styles.sort();
    return ['All', ...styles];
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStyle(String style) {
    _filterStyle = style;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _saveDarkModePreference();
    notifyListeners();
  }

  void addLook(Look look) {
    _looks.add(look);
    _saveLooks();
    notifyListeners();
  }

  void updateLook(Look updatedLook) {
    final index = _looks.indexWhere((look) => look.id == updatedLook.id);
    if (index != -1) {
      _looks[index] = updatedLook;
      _saveLooks();
      notifyListeners();
    }
  }

  void deleteLook(String id) {
    _looks.removeWhere((look) => look.id == id);
    _saveLooks();
    notifyListeners();
  }

  void reorderLooks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final look = _looks.removeAt(oldIndex);
    _looks.insert(newIndex, look);
    _saveLooks();
    notifyListeners();
  }

  void swipeLook(String id, bool isLiked) {
    final index = _looks.indexWhere((look) => look.id == id);
    if (index != -1) {
      _looks[index] = _looks[index].copyWith(
        swipeCount: _looks[index].swipeCount + 1,
        isFavorite: isLiked ? true : _looks[index].isFavorite,
      );
      _saveLooks();
      notifyListeners();
    }
  }

  // Save looks to shared preferences
  Future<void> _saveLooks() async {
    final prefs = await SharedPreferences.getInstance();
    final looksJson = _looks.map((look) => look.toJson()).toList();
    await prefs.setString('looks', jsonEncode(looksJson));
  }

  // Load looks from shared preferences
  Future<void> loadLooks() async {
    final prefs = await SharedPreferences.getInstance();
    final looksString = prefs.getString('looks');
    if (looksString != null) {
      final List<dynamic> looksJson = jsonDecode(looksString);
      _looks = looksJson.map((json) => Look.fromJson(json)).toList();
      notifyListeners();
    }
  }

  // Save dark mode preference
  Future<void> _saveDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  // Load dark mode preference
  Future<void> loadDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // Initialize with sample data
  void initializeSampleData() {
    if (_looks.isEmpty) {
      _looks = [
        Look(
          id: '1',
          name: 'Casual Weekend',
          style: 'Minimal',
          confidenceLevel: 4,
        ),
        Look(
          id: '2',
          name: 'Street Style',
          style: 'Street',
          confidenceLevel: 3,
        ),
        Look(
          id: '3',
          name: 'Korean Chic',
          style: 'Korean',
          confidenceLevel: 5,
        ),
      ];
      _saveLooks();
      notifyListeners();
    }
  }
}
