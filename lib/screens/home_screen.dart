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

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  bool _loadingLocation = false;

  //temperature based card color
  Color getTempColor(double temp) {
    if (temp > 30) return Colors.orangeAccent;
    if (temp < 20) return Colors.deepPurple[300]!;
    return Colors.deepPurple[100]!;
  }

  //Weather icons
  Icon getWeatherIcon(String description) {
    description = description.toLowerCase();
    if (description.contains('sun')) {
      return const Icon(Icons.wb_sunny, size: 60, color: Colors.orange);
    }
    if (description.contains('cloud')) {
      return const Icon(Icons.cloud, size: 60, color: Colors.lightBlueAccent);
    }
    if (description.contains('rain')) {
      return const Icon(Icons.beach_access, size: 60, color: Colors.blueAccent);
    }
    return const Icon(Icons.wb_cloudy, size: 60, color: Colors.grey);
  }

  //Dynamic background gradient based on weather
  List<Color> getBackgroundGradient(String description) {
    description = description.toLowerCase();
    if (description.contains('sun')) {
      return [Colors.orange.shade200, Colors.orange.shade600];
    }
    if (description.contains('rain')) {
      return [Colors.blue.shade300, Colors.blue.shade900];
    }
    if (description.contains('cloud')) {
      return [Colors.lightBlue.shade200, Colors.blue.shade700];
    }
    return [Colors.grey.shade300, Colors.grey.shade600];
  }

  //Fetch current location
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
              content: Text(
                  "Location permanently denied. Enable from settings.")),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

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

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final weather = weatherProvider.weather;

    //Default gradient if no weather loaded
    List<Color> backgroundColors = [Colors.purple.shade200, Colors.blue.shade400];
    if (weather != null) {
      backgroundColors = getBackgroundGradient(weather.description);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Weather App', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple.withOpacity(0.7),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.white),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud, color: Colors.white),
            onPressed: () {
              if (weather != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            ForecastScreen(city: weather.city)));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search for a city first')));
              }
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: backgroundColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(23),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              const Text(
                "Search Weather",
                style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text(
                "Find the latest weather updates instantly",
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 30),

              // Search box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26, blurRadius: 6, offset: Offset(0, 4))
                  ],
                ),
                child: TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    hintText: 'Enter city name...',
                    prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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

              // Current location button
              ElevatedButton.icon(
                icon: _loadingLocation
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Icon(Icons.gps_fixed, color: Colors.white),
                label: const Text('Use Current Location',
                    style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _loadingLocation ? null : fetchCurrentLocationWeather,
              ),
              const SizedBox(height: 25),

              // Weather card
              weather == null
                  ? const Center(
                child: Text(
                  'Search for a city to view weather',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              )
                  : AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: 1,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.9),
                          Colors.deepPurple[50]!
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black38,
                          blurRadius: 8,
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      getWeatherIcon(weather.description),
                      const SizedBox(height: 10),
                      Text(weather.city,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("${weather.temp.toStringAsFixed(1)} °C",
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple)),
                      const SizedBox(height: 8),
                      Text(weather.description,
                          style: const TextStyle(
                              fontSize: 18, fontStyle: FontStyle.italic)),
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






