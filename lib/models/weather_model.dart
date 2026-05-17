// 1. Blueprint for a single hour of weather
class HourlyWeather {
  final String time;
  final double tempC;
  final String condition;
  final String iconUrl;

  HourlyWeather({
    required this.time,
    required this.tempC,
    required this.condition,
    required this.iconUrl,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: json['time'],
      tempC: json['temp_c'].toDouble(),
      condition: json['condition']['text'],
      // WeatherAPI sends URLs missing the 'https:', we fix it here
      iconUrl: 'https:${json['condition']['icon']}', 
    );
  }
}

// 2. Blueprint for an entire day (holds sunrise/sunset and a list of hours)
class ForecastDay {
  final String date;
  final double maxTemp;
  final double minTemp;
  final String condition;
  final String sunrise;
  final String sunset;
  final double maxWindKph;
  final int dailyChanceOfRain;
  final List<HourlyWeather> hours; // The nested hourly array

  ForecastDay({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.condition,
    required this.sunrise,
    required this.sunset,
    required this.maxWindKph,
    required this.dailyChanceOfRain,
    required this.hours,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    var hourList = json['hour'] as List;
    List<HourlyWeather> parsedHours = hourList.map((i) => HourlyWeather.fromJson(i)).toList();

    return ForecastDay(
      date: json['date'],
      maxTemp: json['day']['maxtemp_c'].toDouble(),
      minTemp: json['day']['mintemp_c'].toDouble(),
      condition: json['day']['condition']['text'],
      sunrise: json['astro']['sunrise'],
      sunset: json['astro']['sunset'],
      maxWindKph: json['day']['maxwind_kph'].toDouble(),
      dailyChanceOfRain: json['day']['daily_chance_of_rain'],
      hours: parsedHours, // Attaching the hours to the day
    );
  }
}

// 3. The Master Blueprint
class WeatherModel {
  final String cityName;
  final double temperatureC;
  final String condition;
  final String currentIconUrl; // THE NEW VARIABLE
  final double windKph;
  final int humidity;
  final double pm25;
  final double uv; 
  final List<ForecastDay> forecastDays; // The nested 3-day array

  WeatherModel({
    required this.cityName,
    required this.temperatureC,
    required this.condition,
    required this.currentIconUrl, // ADDED HERE
    required this.windKph,
    required this.humidity,
    required this.pm25,
    required this.uv,
    required this.forecastDays,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    var forecastList = json['forecast']['forecastday'] as List;
    List<ForecastDay> parsedDays = forecastList.map((i) => ForecastDay.fromJson(i)).toList();

    return WeatherModel(
      cityName: json['location']['name'],
      temperatureC: json['current']['temp_c'].toDouble(),
      condition: json['current']['condition']['text'],
      // GRABBING THE ICON FROM THE JSON AND ADDING HTTPS:
      currentIconUrl: 'https:${json['current']['condition']['icon']}', 
      windKph: json['current']['wind_kph'].toDouble(),
      humidity: json['current']['humidity'],
      pm25: json['current']['air_quality']['pm2_5'].toDouble(),
      uv: json['current']['uv'].toDouble(),
      forecastDays: parsedDays, // Attaching the 3 days to the master model
    );
  }
}