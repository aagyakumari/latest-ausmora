import 'package:flutter_application_1/features/compatibility/model/compatibility_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class CompatibilityRepository {
  // Function to fetch compatibility data from the API
  Future<Compatibility> fetchCompatibilityData(String date) async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token'); // Retrieve the token from Hive storage

      // final url = 'https://genzrev.com/api/frontend/Guests/GetDashboardData?date=2024-11-24';
      final url = 'https://genzrev.com/api/frontend/Guests/GetDashboardData?date=$date';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Include the token in the request headers
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data']['compatibility'];
        if (data == null) {
          // Return a default Compatibility if data is null
          return Compatibility(compatibility: '');
        }
        return Compatibility.fromJson(data);
      } else {
        throw Exception('Failed to load compatibility data');
      }
    } catch (e) {
      throw Exception('Error fetching compatibility data: $e');
    }
  }
}
