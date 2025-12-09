import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import 'forecast_screen.dart';
import 'favorites_screen.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _cityController = TextEditingController();
  bool _loadingLocation = false;

  @override
  void initState() {
    super.initState();
  }

  // -----------------------------
  // COLOR LOGIC (Dynamic Themes)
  // -----------------------------
  Color getBackgroundColor(String description, double temp) {
    description = description.toLowerCase();

    if (description.contains("light rain")) {
      return Colors.lightBlueAccent.shade100;
    }
    if (description.contains("heavy rain") || description.contains("thunder")) {
      return Colors.blueGrey.shade700;
    }
    if (description.contains("cloud")) {
      return Colors.blue.shade200;
    }
    if (temp > 30) {
      return Colors.orangeAccent;
    }

    // default purple theme
    return const Color(0xFF7F53AC);
  }

  Color getBackgroundColor2(String description, double temp) {
    description = description.toLowerCase();

    if (description.contains("light rain")) {
      return Colors.lightBlueAccent.shade200;
    }
    if (description.contains("heavy rain") || description.contains("thunder")) {
      return Colors.blueGrey.shade500;
    }
    if (description.contains("cloud")) {
      return Colors.blue.shade100;
    }
    if (temp > 30) {
      return Colors.deepOrangeAccent;
    }

    // default purple theme
    return const Color(0xFF647DEE);
  }

  Icon getWeatherIcon(String description) {
    description = description.toLowerCase();

    if (description.contains('sun') || description.contains('clear')) {
      return const Icon(Icons.wb_sunny, size: 60, color: Colors.orange);
    }
    if (description.contains('cloud')) {
      return const Icon(Icons.cloud, size: 60, color: Colors.black54);
    }
    if (description.contains('heavy rain')) {
      return const Icon(Icons.thunderstorm, size: 60, color: Colors.blueGrey);
    }
    if (description.contains('light rain')) {
      return const Icon(Icons.grain, size: 60, color: Colors.lightBlueAccent);
    }
    if (description.contains('rain')) {
      return const Icon(Icons.beach_access, size: 60, color: Colors.blue);
    }

    return const Icon(Icons.wb_cloudy, size: 60, color: Colors.black87);
  }

  // -----------------------------
  // DYNAMIC TEXT COLORS
  // -----------------------------
  Color getTextColor(String description, double temp) {
    description = description.toLowerCase();

    if (description.contains("heavy rain")) return Colors.white;
    if (temp > 30) return Colors.black;

    return Colors.white;
  }

  // -----------------------------
  // FETCH CURRENT LOCATION
  // -----------------------------
  Future<void> fetchCurrentLocationWeather() async {
    setState(() => _loadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enable GPS to use current location")),
        );
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
              Text("Location permanently denied. Enable from settings.")),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await Provider.of<WeatherProvider>(context, listen: false)
          .fetchWeatherByCoordinates(position.latitude, position.longitude);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to get location")),
      );
    } finally {
      setState(() => _loadingLocation = false);
    }
  }

  // -----------------------------
  // MAIN UI
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final weather = weatherProvider.weather;

    final bg1 = weather == null
        ? const Color(0xFF7F53AC)
        : getBackgroundColor(weather.description, weather.temp);

    final bg2 = weather == null
        ? const Color(0xFF647DEE)
        : getBackgroundColor2(weather.description, weather.temp);

    final textColor = weather == null
        ? Colors.white
        : getTextColor(weather.description, weather.temp);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud, color: Colors.white),
            onPressed: () {
              final w = weatherProvider.weather;
              if (w != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ForecastScreen(city: w.city)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search for a city first')),
                );
              }
            },
          ),
        ],
      ),

      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bg1, bg2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Text(
                "Search Weather",
                style: TextStyle(
                  fontSize: 28,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),
              Text(
                "Find the latest weather updates instantly",
                style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.8)),
              ),

              const SizedBox(height: 30),

              // Search Box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'Enter city name...',
                    prefixIcon:
                    const Icon(Icons.search, color: Colors.deepPurple),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios,
                          color: Colors.deepPurple),
                      onPressed: () {
                        if (_cityController.text.isNotEmpty) {
                          weatherProvider.fetchWeather(_cityController.text);
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Current Location Button
              ElevatedButton.icon(
                icon: _loadingLocation
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Icon(Icons.gps_fixed, color: Colors.white),
                label: const Text(
                  'Use Current Location',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed:
                _loadingLocation ? null : fetchCurrentLocationWeather,
              ),

              const SizedBox(height: 25),

              weather == null
                  ? Center(
                child: Text(
                  'Search for a city to view weather',
                  style: TextStyle(color: textColor, fontSize: 18),
                ),
              )
                  : AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.85),
                        bg2.withOpacity(0.35),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      getWeatherIcon(weather.description),
                      const SizedBox(height: 10),
                      Text(
                        weather.city,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${weather.temp.toStringAsFixed(1)} °C",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weather.description,
                        style: const TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic),
                      ),

                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.favorite),
                        label: const Text("Add to Favorites"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          weatherProvider.addFavorite(weather.city);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




