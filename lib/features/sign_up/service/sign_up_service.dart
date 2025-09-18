import 'package:flutter_application_1/hive/hive_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupService {
  final HiveService _hiveService = HiveService();

  Future<bool> signup({
    required String name,
    required String cityId,
    required String dob,
    required String tob,
    required String email,
    required double tz, // Ensure tz is a double
  }) async {
    String? apiUrl = await _hiveService.getApiUrl();
    if (apiUrl == null || apiUrl.isEmpty) {
      print("Error: API URL is not set in Hive.");
      return false;
    }

    final signupData = {
      "name": name,
      "email": email,
      "city_id": cityId,
      "dob": dob,
      "tob": tob,
      "is_login": false, // Always false for signup
      "tz": tz,
    };

    print("Signup Request Data: ${jsonEncode(signupData)}"); // Debugging

    final response = await http.post(
      Uri.parse('$apiUrl/frontend/Guests/signup'), // Ensure correct endpoint
      body: json.encode(signupData),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print("Signup Response Code: ${response.statusCode}");
    print("Signup Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData["error_code"] == "0") {
        return true; // Signup successful
      } else {
        print("Signup API Error: ${responseData["message"]}");
        return false;
      }
    } else {
      print('Signup failed: ${response.body}');
      return false;
    }
  }
}
