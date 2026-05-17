import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/gemini_service.dart';

class LifestyleScreen extends StatefulWidget {
  final WeatherModel? weather;

  const LifestyleScreen({super.key, required this.weather});

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  final GeminiService _geminiService = GeminiService();
  String _aiInsight = 'Ready to analyze lifestyle parameters. Tap below.';
  bool _isLoadingInsight = false;

  // We only fetch when the user asks, stopping the simultaneous API blast
  Future<void> _fetchLifestyleInsight() async {
    if (widget.weather == null) return;
    
    setState(() {
      _isLoadingInsight = true;
      _aiInsight = 'Analyzing...';
    });

    final insight = await _geminiService.generateWeatherInsight(widget.weather!, 'lifestyle');
    
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
    final canDryClothes = w.humidity < 60 && w.forecastDays[0].dailyChanceOfRain < 20;

    return Scaffold(
      appBar: AppBar(
        title: Text('LIFESTYLE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 2.5, color: Colors.white.withOpacity(0.8))),
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
                gradient: LinearGradient(colors: [Colors.purple.shade900, Colors.black87]),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.directions_run, color: Colors.purpleAccent),
                          SizedBox(width: 8),
                          Text('Activity Directive', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      // The Lazy Load Button
                      IconButton(
                        icon: _isLoadingInsight 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.purpleAccent, strokeWidth: 2))
                          : const Icon(Icons.refresh, color: Colors.purpleAccent),
                        onPressed: _isLoadingInsight ? null : _fetchLifestyleInsight,
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(_aiInsight, style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Condition Matrix', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              color: Colors.white.withOpacity(0.05),
              child: ListTile(
                leading: Icon(Icons.dry_cleaning, color: canDryClothes ? Colors.green : Colors.red),
                title: const Text('Laundry Viability'),
                subtitle: Text(canDryClothes ? 'Optimal conditions for line-drying.' : 'High humidity/rain. Do not wash clothes.'),
              ),
            ),
            Card(
              color: Colors.white.withOpacity(0.05),
              child: ListTile(
                leading: Icon(Icons.wb_sunny, color: w.uv > 7 ? Colors.red : Colors.orange),
                title: Text('UV Protection (Index: ${w.uv})'),
                subtitle: Text(w.uv > 7 ? 'Extreme exposure. Sunscreen mandatory.' : 'Moderate exposure.'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}