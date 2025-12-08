import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  WeatherModel? _weather;
  List<String> _favorites = [];

  WeatherModel? get weather => _weather;
  List<String> get favorites => _favorites;

  WeatherProvider() {
    loadFavorites();
  }

  //Fetch weather by city name
  Future<void> fetchWeather(String city) async {
    _weather = await _apiService.fetchWeather(city);
    notifyListeners();
  }

  //Fetch weather by current coordinates
  Future<void> fetchWeatherByCoordinates(double lat, double lon) async {
    _weather = await _apiService.fetchWeatherByCoordinates(lat, lon);
    notifyListeners();
  }

  //Add city to favorites
  void addFavorite(String city) {
    if (!_favorites.contains(city)) {
      _favorites.add(city);
      saveFavorites();
      notifyListeners();
    }
  }

  //Remove city from favorites
  void removeFavorite(String city) {
    _favorites.remove(city);
    saveFavorites();
    notifyListeners();
  }

  //Load favorites from SharedPreferences
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favorites = prefs.getStringList('favorites') ?? [];
    notifyListeners();
  }

  //Save favorites to SharedPreferences
  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorites', _favorites);
  }
}

