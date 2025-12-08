import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  Map<String, WeatherModel?> favoriteWeather = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchAllFavoritesWeather();
  }

  Future<void> fetchAllFavoritesWeather() async {
    final weatherProvider =
    Provider.of<WeatherProvider>(context, listen: false);
    final favorites = weatherProvider.favorites;

    Map<String, WeatherModel?> tempMap = {};
    for (String city in favorites) {
      await weatherProvider.fetchWeather(city);
      tempMap[city] = weatherProvider.weather;
    }

    setState(() {
      favoriteWeather = tempMap;
      _loading = false;
    });
  }

  Color getTempColor(double temp) {
    if (temp > 30) return Colors.orangeAccent;
    if (temp < 20) return Colors.deepPurple[300]!;
    return Colors.deepPurple[100]!;
  }

  Icon getWeatherIcon(String description) {
    if (description.toLowerCase().contains('sun')) {
      return const Icon(Icons.wb_sunny, size: 40, color: Colors.orange);
    }
    if (description.toLowerCase().contains('cloud')) {
      return const Icon(Icons.cloud, size: 40, color: Colors.black87);
    }
    if (description.toLowerCase().contains('rain')) {
      return const Icon(Icons.beach_access, size: 40, color: Colors.blue);
    }
    return const Icon(Icons.wb_cloudy, size: 40, color: Colors.black87);
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final favorites = weatherProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Cities'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : favorites.isEmpty
          ? const Center(
        child: Text('No favorite cities added',
            style: TextStyle(fontSize: 18)),
      )
          : ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final city = favorites[index];
          final weather = favoriteWeather[city];

          return Container(
            margin: const EdgeInsets.symmetric(
                vertical: 8, horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple[100]!,
                  Colors.deepPurple[300]!
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Weather icon
                weather != null
                    ? getWeatherIcon(weather.description)
                    : const Icon(Icons.location_city,
                    size: 40, color: Colors.black87),
                const SizedBox(width: 16),
                // City+ weather details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(city,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      if (weather != null) ...[
                        const SizedBox(height: 4),
                        Text(
                            '${weather.temp.toStringAsFixed(1)} °C, ${weather.description}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87)),
                      ],
                    ],
                  ),
                ),
                // Delete button
                IconButton(
                  icon:
                  const Icon(Icons.delete, color: Colors.orange),
                  onPressed: () {
                    weatherProvider.removeFavorite(city);
                    setState(() {
                      favoriteWeather.remove(city);
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}



