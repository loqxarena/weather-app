import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/gemini_service.dart';

class AgriScreen extends StatefulWidget {
  final WeatherModel? weather;

  const AgriScreen({super.key, required this.weather});

  @override
  State<AgriScreen> createState() => _AgriScreenState();
}

class _AgriScreenState extends State<AgriScreen> {
  final GeminiService _geminiService = GeminiService();
  String _aiInsight = 'Ready to analyze agricultural parameters. Tap below.';
  bool _isLoadingInsight = false;

  Future<void> _fetchAgriInsight() async {
    if (widget.weather == null) return;
    
    setState(() {
      _isLoadingInsight = true;
      _aiInsight = 'Analyzing...';
    });

    final insight = await _geminiService.generateWeatherInsight(widget.weather!, 'agri');
    
    if (mounted) {
      setState(() {
        _aiInsight = insight;
        _isLoadingInsight = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.weather == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final w = widget.weather!;
    final isWindSafe = w.windKph < 15.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('AGRI DASHBOARD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 2.5, color: Colors.white.withOpacity(0.8))),
        centerTitle: true, 
        elevation: 0, 
        backgroundColor: Colors.transparent
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green.shade900, Colors.black87]),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.greenAccent.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.grass, color: Colors.greenAccent),
                          SizedBox(width: 8),
                          Text('Agritech Advisory', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      IconButton(
                        icon: _isLoadingInsight 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.greenAccent, strokeWidth: 2))
                          : const Icon(Icons.refresh, color: Colors.greenAccent),
                        onPressed: _isLoadingInsight ? null : _fetchAgriInsight,
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(_aiInsight, style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Field Conditions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              color: Colors.white.withOpacity(0.05),
              child: ListTile(
                leading: Icon(Icons.pest_control, color: isWindSafe ? Colors.green : Colors.red),
                title: Text('Pesticide Spraying (Wind: ${w.windKph}km/h)'),
                subtitle: Text(isWindSafe ? 'Safe to spray. Low chemical drift.' : 'DANGER: Wind too high. Do not spray.'),
              ),
            ),
            Card(
              color: Colors.white.withOpacity(0.05),
              child: ListTile(
                leading: Icon(Icons.water_drop, color: w.forecastDays[0].dailyChanceOfRain > 50 ? Colors.blue : Colors.grey),
                title: Text('Irrigation Need (Rain Chance: ${w.forecastDays[0].dailyChanceOfRain}%)'),
                subtitle: Text(w.forecastDays[0].dailyChanceOfRain > 50 ? 'Rain expected. Save pump diesel/electricity.' : 'Manual irrigation may be required.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}