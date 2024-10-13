import 'dart:convert';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:theiotlab/services/shared_preferences.dart/shared_pref_helper.dart';

class TempData {
  final int time; 
  final double temperature;
  final double humidity;

  TempData(this.time, this.temperature, this.humidity);

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'temperature': temperature,
      'humidity': humidity,
    };
  }

  // Convert from Map
  factory TempData.fromMap(Map<String, dynamic> map) {
    return TempData(
      map['time'],
      map['temperature'],
      map['humidity'],
    );
  }
}
class TempChart extends StatelessWidget {
  final List<charts.Series<TempData, int>>
      temperatureSeriesList; // For temperature
  final List<charts.Series<TempData, int>> humiditySeriesList; // For humidity

  const TempChart(this.temperatureSeriesList, this.humiditySeriesList, {super.key});

  @override
  Widget build(BuildContext context) {
    return charts.LineChart(
      temperatureSeriesList + humiditySeriesList, // Combine both series
      animate: true,
      behaviors: [
        charts.ChartTitle('Time (minutes since start)',
            behaviorPosition: charts.BehaviorPosition.bottom),
        charts.ChartTitle('Value',
            behaviorPosition: charts.BehaviorPosition.start),
      ],
    );
  }
}

class EnergyMonitoringScreen extends StatefulWidget {
  const EnergyMonitoringScreen({super.key});

  @override
  _EnergyMonitoringScreenState createState() => _EnergyMonitoringScreenState();
}

class _EnergyMonitoringScreenState extends State<EnergyMonitoringScreen> {
  final databaseRef = FirebaseDatabase.instance.ref();
  List<TempData> tempDataList = [];
  int currentTimeInMinutes = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData(); // Load data from SharedPreferences or Firebase
  }

  void _loadData() async {
    SharedPreferencesHelper sharedPrefs = SharedPreferencesHelper();

    // Check if we have saved data
    List<Map<String, dynamic>>? savedData = await sharedPrefs.getData();

    if (savedData != null) {
      // Use saved data to populate the chart
      setState(() {
        tempDataList = savedData.map((item) => TempData.fromMap(item)).toList();
        currentTimeInMinutes = tempDataList.length; // Update time tracking
        _isLoading = false;
      });
    } else {
      _fetchInitialData();
    }

    _listenToTemperatureAndHumidityChanges();
  }

  void _fetchInitialData() async {
    // Fetch initial data from Firebase
    final DataSnapshot snapshot = await databaseRef.get();

    // Extract data
    final double initialTemperature = double.tryParse(snapshot.child('Temperature').value?.toString() ?? '') ?? 0.0;
    final double initialHumidity = double.tryParse(snapshot.child('Humidity').value?.toString() ?? '') ?? 0.0;

    setState(() {
      tempDataList.add(TempData(currentTimeInMinutes, initialTemperature, initialHumidity));
      currentTimeInMinutes++;
      _isLoading = false;
    });

    _updateSharedPreferences();
  }

  void _listenToTemperatureAndHumidityChanges() {
    databaseRef.onValue.listen((event) {
      final temperatureValue = double.tryParse(event.snapshot.child('Temperature').value?.toString() ?? '') ?? 0.0;
      final humidityValue = double.tryParse(event.snapshot.child('Humidity').value?.toString() ?? '') ?? 0.0;

      setState(() {
        tempDataList.add(TempData(currentTimeInMinutes, temperatureValue, humidityValue));
        currentTimeInMinutes++;
      });

      _updateSharedPreferences();
    });
  }

  void _updateSharedPreferences() {
    SharedPreferencesHelper sharedPrefs = SharedPreferencesHelper();
    
    // Save the data in SharedPreferences
    List<Map<String, dynamic>> tempDataListMap = tempDataList.map((data) => data.toMap()).toList();
    sharedPrefs.saveData(tempDataListMap);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tempDataList.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Create chart series
    final temperatureSeries = charts.Series<TempData, int>(
      id: 'Temperature',
      colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      domainFn: (TempData temps, _) => temps.time,
      measureFn: (TempData temps, _) => temps.temperature,
      data: tempDataList,
    );

    final humiditySeries = charts.Series<TempData, int>(
      id: 'Humidity',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (TempData temps, _) => temps.time,
      measureFn: (TempData temps, _) => temps.humidity,
      data: tempDataList,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Real-Time Temperature and Humidity Chart")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TempChart([temperatureSeries], [humiditySeries]),
      ),
    );
  }
}
