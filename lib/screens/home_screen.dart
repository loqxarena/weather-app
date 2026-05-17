import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // THE NEW LOTTIE ENGINE
import '../services/gemini_service.dart';
import '../models/weather_model.dart';

class HomeScreen extends StatefulWidget {
  final WeatherModel? weather;
  final bool isLoading;
  final String errorMessage;
  final VoidCallback onRefreshLocation;
  final Function(String) onSearch;

  const HomeScreen({
    super.key,
    required this.weather,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefreshLocation,
    required this.onSearch,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _cityController = TextEditingController();

  String _aiInsight = 'Analyzing atmospheric conditions...';
  
  @override
  void initState() {
    super.initState();
    if (widget.weather != null) {
      _fetchHomeInsight();
    }
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.weather != null && widget.weather != oldWidget.weather) {
      _aiInsight = 'Analyzing atmospheric conditions...';
      _fetchHomeInsight();
    }
  }

  Future<void> _fetchHomeInsight() async {
    final insight = await _geminiService.generateWeatherInsight(widget.weather!, 'home');
    if (mounted) {
      setState(() {
        _aiInsight = insight;
      });
    }
  }

  // --- THE MAPPING ENGINE ---
  // This reads the text condition and returns the corresponding 60fps 3D animation
  Widget _getWeatherAnimation(String condition, {bool isDay = true, double size = 80}) {
    String conditionLower = condition.toLowerCase();
    String assetPath = 'assets/animations/sunny.json'; 

    if (conditionLower.contains('rain') || conditionLower.contains('drizzle') || conditionLower.contains('shower')) {
      assetPath = 'assets/animations/rain.json';
    } else if (conditionLower.contains('thunder') || conditionLower.contains('storm')) {
      assetPath = 'assets/animations/storm.json';
    } else if (conditionLower.contains('snow') || conditionLower.contains('blizzard') || conditionLower.contains('ice') || conditionLower.contains('sleet')) {
      assetPath = 'assets/animations/snow.json';
    } else if (conditionLower.contains('fog') || conditionLower.contains('mist')) {
      assetPath = 'assets/animations/fog.json';
    } else if (conditionLower.contains('partly') || conditionLower.contains('patchy')) {
      assetPath = isDay ? 'assets/animations/cloudy_day.json' : 'assets/animations/cloudy_night.json';
    } else if (conditionLower.contains('cloudy') || conditionLower.contains('overcast')) {
      assetPath = 'assets/animations/clouds.json';
    } else if (conditionLower.contains('clear')) {
      assetPath = 'assets/animations/moon.json'; 
    } else if (conditionLower.contains('sunny')) {
      assetPath = 'assets/animations/sunny.json';
    } else {
      assetPath = isDay ? 'assets/animations/sunny.json' : 'assets/animations/moon.json';
    }

    return Lottie.asset(assetPath, width: size, height: size, fit: BoxFit.contain);
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search City'),
          content: TextField(
            controller: _cityController,
            decoration: const InputDecoration(hintText: 'Enter city name (e.g., Delhi)'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
                if (_cityController.text.isNotEmpty) {
                  widget.onSearch(_cityController.text); 
                  _cityController.clear(); 
                }
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Simple logic to check if it's currently daytime for the main header
    final currentHour = DateTime.now().hour;
    final isCurrentlyDay = currentHour > 5 && currentHour < 18;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'MAGIC FORECAST', 
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.w600, 
            letterSpacing: 2.5, // This spacing creates the premium look
            color: Colors.white.withOpacity(0.8)
          )
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.my_location, color: Colors.white.withOpacity(0.8)),
            onPressed: widget.onRefreshLocation, 
          ),
          IconButton(
            icon: Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
            onPressed: _showSearchDialog, 
          )
        ],
      ),
      body: widget.isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : widget.errorMessage.isNotEmpty 
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Error:\n${widget.errorMessage}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)),
              ),
            )
          : widget.weather == null
            ? const Center(child: Text('No Data Available'))
            : SingleChildScrollView( 
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- 1. PREMIUM HERO HEADER ---
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.weather!.cityName.toUpperCase(), 
                          style: const TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.w600, 
                            letterSpacing: 3.0,
                            color: Colors.white70
                          )
                        ),
                        
                        Text(
                          '${widget.weather!.temperatureC.round()}°', 
                          style: const TextStyle(
                            fontSize: 110, 
                            fontWeight: FontWeight.w200, 
                            height: 1.1 
                          )
                        ),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.15), 
                                Colors.white.withOpacity(0.02), 
                              ],
                            ),
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(4, 6),
                                blurRadius: 12,
                                spreadRadius: -2,
                              ),
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.1),
                                offset: const Offset(-2, -2),
                                blurRadius: 10,
                                spreadRadius: 0,
                              ),
                            ]
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // REPLACED: We are now injecting the Lottie animation into the 3D pill
                              _getWeatherAnimation(widget.weather!.condition, isDay: isCurrentlyDay, size: 50),
                              const SizedBox(width: 12),
                              Text(
                                widget.weather!.condition, 
                                style: const TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Colors.white
                                )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),

                  Card(
                    color: widget.weather!.pm25 > 50 ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      leading: Icon(Icons.air, color: widget.weather!.pm25 > 50 ? Colors.orange : Colors.green),
                      title: Text('PM2.5 Pollution: ${widget.weather!.pm25}'),
                      subtitle: Text(widget.weather!.pm25 > 50 ? 'Unhealthy for Sensitive Groups' : 'Air quality is good today'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade900, Colors.purple.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Gemini AI Insight', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _aiInsight,
                          style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildHourlyForecast(),
                  const SizedBox(height: 20),

                  _build3DayForecast(),
                  const SizedBox(height: 20),

                  const Text('Daily Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn(Icons.water_drop, 'Humidity', '${widget.weather!.humidity}%'),
                            _buildStatColumn(Icons.wind_power, 'Wind', '${widget.weather!.windKph} km/h'),
                            _buildStatColumn(Icons.wb_sunny, 'UV Index', '${widget.weather!.uv}'),
                          ],
                        ),
                        const Divider(height: 30, color: Colors.white24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn(Icons.brightness_6, 'Sunrise', widget.weather!.forecastDays[0].sunrise),
                            _buildStatColumn(Icons.brightness_3, 'Sunset', widget.weather!.forecastDays[0].sunset),
                            _buildStatColumn(Icons.umbrella, 'Rain Chance', '${widget.weather!.forecastDays[0].dailyChanceOfRain}%'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildHourlyForecast() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Today\'s Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 140, // Increased slightly to fit the premium Lottie animation
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.weather!.forecastDays[0].hours.length,
            itemBuilder: (context, index) {
              final hour = widget.weather!.forecastDays[0].hours[index];
              
              final rawHour = int.parse(hour.time.substring(11, 13));
              final ampm = rawHour >= 12 ? 'PM' : 'AM';
              final displayHour = rawHour == 0 ? 12 : (rawHour > 12 ? rawHour - 12 : rawHour);
              final timeString = '$displayHour:00 $ampm';
              
              // Determine if the specific hour is day or night for accurate icons
              final isHourDay = rawHour > 5 && rawHour < 18;
              
              return Container(
                width: 85,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(timeString, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    // REPLACED: Injecting smaller Lottie files into the timeline
                    _getWeatherAnimation(hour.condition, isDay: isHourDay, size: 45), 
                    const SizedBox(height: 4),
                    Text('${hour.tempC.round()}°', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _build3DayForecast() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('3-Day Forecast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...widget.weather!.forecastDays.map((day) {
          return Card(
            color: Colors.white.withOpacity(0.05),
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              // REPLACED: Injecting Lottie into the 3-day list. 
              // We assume day animations for daily summaries.
              leading: _getWeatherAnimation(day.condition, isDay: true, size: 40),
              title: Text(day.date, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(day.condition),
              trailing: Text('${day.maxTemp.round()}° / ${day.minTemp.round()}°', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}