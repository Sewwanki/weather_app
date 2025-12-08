import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForecastScreen extends StatefulWidget {
  final String city;
  ForecastScreen({super.key, required this.city});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  List<dynamic> _forecastList = [];
  bool _loading = true;

  final String apiKey = '6febb1c7dfa5622f5c0628b46ec04616';

  @override
  void initState() {
    super.initState();
    fetchForecast(widget.city);
  }

  Future<void> fetchForecast(String city) async {
    setState(() => _loading = true);
    try {
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _forecastList = (data['list'] as List)
            .where((item) => (item['dt_txt'] as String).contains('12:00:00'))
            .toList();
      } else {
        _forecastList = [];
      }
    } catch (e) {
      _forecastList = [];
    } finally {
      setState(() => _loading = false);
    }
  }

  Icon getWeatherIcon(String description) {
    description = description.toLowerCase();
    if (description.contains('sun')) {
      return const Icon(Icons.wb_sunny, size: 40, color: Colors.orange);
    } else if (description.contains('cloud')) {
      return const Icon(Icons.cloud, size: 40, color: Colors.black);
    } else if (description.contains('rain')) {
      return const Icon(Icons.beach_access, size: 40, color: Colors.blue);
    }
    return const Icon(Icons.wb_cloudy, size: 40, color: Colors.grey);
  }

  Color getTempColor(double temp) {
    if (temp > 30) return Colors.orangeAccent;
    if (temp < 20) return Colors.deepPurple[300]!;
    return Colors.deepPurple[100]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forecast - ${widget.city}'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _forecastList.isEmpty
          ? const Center(child: Text('No forecast available'))
          : Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _forecastList.length,
          itemBuilder: (context, index) {
            final item = _forecastList[index];
            final temp = (item['main']['temp'] as num).toDouble();
            final desc = item['weather'][0]['description'] as String;
            final dateTxt = item['dt_txt'] as String;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: getTempColor(temp),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(2, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  getWeatherIcon(desc),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateTxt.split(' ')[0],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Text(
                    '${temp.toStringAsFixed(1)} °C',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


