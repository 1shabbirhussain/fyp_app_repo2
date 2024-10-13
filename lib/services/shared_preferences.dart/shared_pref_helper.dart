import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // To store objects as JSON

class SharedPreferencesHelper {
  static final SharedPreferencesHelper _instance = SharedPreferencesHelper._internal();

  factory SharedPreferencesHelper() {
    return _instance;
  }

  SharedPreferencesHelper._internal();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _sharedPrefs async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  // Define keys
  static const String temperatureKey = 'temperature_data';
  static const String humidityKey = 'humidity_data';
  static const String timeKey = 'time_data';

  // Save data
  Future<void> saveData(List<Map<String, dynamic>> tempDataList) async {
    final prefs = await _sharedPrefs;
    String tempDataJson = jsonEncode(tempDataList); // Convert list to JSON string
    await prefs.setString(temperatureKey, tempDataJson);
  }

  // Get data
  Future<List<Map<String, dynamic>>?> getData() async {
    final prefs = await _sharedPrefs;
    String? tempDataJson = prefs.getString(temperatureKey);

    if (tempDataJson != null) {
      List<dynamic> jsonList = jsonDecode(tempDataJson);
      return jsonList.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return null;
  }

  // Clear saved data
  Future<void> clearData() async {
    final prefs = await _sharedPrefs;
    await prefs.remove(temperatureKey);
  }
}
