import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/hive/hive_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileRepo {
  final HiveService _hiveService = HiveService();

  // Variables to store profile data
  String? name;
  String? dob;
  String? tob;
  String? cityId;
  String? cityName;
  double? tz;
  String? gender;

  // API URLs
  static String _updateProfileUrl = '$baseApiUrl/Guests/UpdateGuestProfile';
  static String _getProfileUrl = '$baseApiUrl/Guests/Get';

  // Method to update guest profile (Including city & timezone)
  Future<bool> updateGuestProfile(Map<String, dynamic> updateData) async {
    String? token = await _hiveService.getToken();

    try {
      final response = await http.post(
        Uri.parse(_updateProfileUrl),
        headers: {
          'Authorization': token != null ? 'Bearer $token' : '',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['error_code'] == "0") {
          print('Profile updated successfully.');
          return true;
        } else {
          print('Error updating profile: ${responseData['message']}');
        }
      } else {
        print('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception during update: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>?> getProfile() async {
  String? token = await _hiveService.getToken();
  try {
    final response = await http.get(
      Uri.parse(_getProfileUrl),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      if (responseData['error_code'] == "0") {
        var profileData = responseData['data']?['item'] ?? {};

        print("Fetched Profile Data: $profileData"); // Debugging print

        // Store profile data in variables
        name = profileData['name'] ?? 'No name available';
        dob = profileData['dob'] ?? '';
        tob = profileData['tob'] ?? '';
        cityId = profileData['city_id'] ?? '';

        // Extract city name safely
        cityName = (profileData['city']?['city_ascii'] as String?) ?? 'Unknown';

        // Extract timezone (tz) safely
        tz = (profileData['tz'] is num) ? profileData['tz'].toDouble() : 0.0;

        gender = profileData['gender'] ?? 'No gender available';

        return profileData;
      } else {
        print('Error fetching profile: ${responseData['message']}');
      }
    } else {
      print('Failed to fetch profile: ${response.statusCode}');
    }
  } catch (e) {
    print('Exception during fetch: $e');
  }
  return null;
}


  // Getters for profile data
  String? getName() => name;
  String? getDob() => dob;
  String? getTob() => tob;
  String? getCityId() => cityId;
  String? getCityName() => cityName;
  double? getTz() => tz;
  String? getGender() => gender;
}
