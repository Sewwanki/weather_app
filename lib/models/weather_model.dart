class WeatherModel {
  String city;
  double temp;
  String description;

  WeatherModel({
    required this.city,
    required this.temp,
    required this.description,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['name'],
      temp: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
    );
  }
}
