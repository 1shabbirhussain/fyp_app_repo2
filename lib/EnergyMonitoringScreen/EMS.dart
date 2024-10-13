import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TempData {
  final int time; // Use int for numeric representation of time
  final double temperature;
  final double humidity; // Add humidity field

  TempData(this.time, this.temperature, this.humidity);
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
  List<TempData> tempDataList = []; // Store temperature and humidity data
  int currentTimeInMinutes = 0; // Track time in minutes
  bool _isLoading = true; // Add a loading indicator

  @override
  void initState() {
    super.initState();
    _fetchDataAndListen(); // Single function to fetch data and listen for updates
  }

  void _fetchDataAndListen() async {
    // Fetch initial data from the Firebase Database
    final DataSnapshot snapshot = await databaseRef.get();

    // Extract temperature and humidity from the snapshot, if available
    final double initialTemperature =
        double.tryParse(snapshot.child('Temperature').value?.toString() ?? '') ?? 0.0;
    final double initialHumidity =
        double.tryParse(snapshot.child('Humidity').value?.toString() ?? '') ?? 0.0;

    // Initialize the chart with the initial data
    setState(() {
      tempDataList.add(TempData(currentTimeInMinutes, initialTemperature, initialHumidity));
      currentTimeInMinutes++; // Increment time for next data point
      _isLoading = false; // Stop showing the loader after initial data is loaded
    });

    // Listen for real-time updates to Temperature and Humidity
    databaseRef.onValue.listen((event) {
      final temperatureValue =
          double.tryParse(event.snapshot.child('Temperature').value?.toString() ?? '') ?? 0.0;
      final humidityValue =
          double.tryParse(event.snapshot.child('Humidity').value?.toString() ?? '') ?? 0.0;

      print(
          'Received temperature: $temperatureValue, humidity: $humidityValue at time: $currentTimeInMinutes minutes');

      setState(() {
        tempDataList.add(TempData(currentTimeInMinutes, temperatureValue, humidityValue));
        currentTimeInMinutes += 1; // Increment time for next data point
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loader while data is being fetched
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Ensure we have enough data to display
    if (tempDataList.isEmpty) {
      return const Center(child: Text('No data available')); // Show a message if no data is available
    }

    // Create the chart series
    final temperatureSeries = charts.Series<TempData, int>(
      id: 'Temperature',
      colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      domainFn: (TempData temps, _) => temps.time, // X-axis (minutes)
      measureFn: (TempData temps, _) => temps.temperature, // Y-axis
      data: tempDataList,
    );

    final humiditySeries = charts.Series<TempData, int>(
      id: 'Humidity',
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (TempData temps, _) => temps.time, // X-axis (minutes)
      measureFn: (TempData temps, _) => temps.humidity, // Y-axis
      data: tempDataList,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Real-Time Temperature and Humidity Chart"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TempChart([temperatureSeries], [humiditySeries]), // Pass both series to TempChart
      ),
    );
  }
}
