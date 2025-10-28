import 'dart:convert';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/hive/hive_service.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class UpdateProfileService {
  final String apiUrl = '$baseApiUrl/Guests/UpdateProfile';

  Future<bool> updateProfile(String name, String cityId, String dob, String tob, double tz, String gender) async {
    try {
      // Get the token from Hive
      String? token = await HiveService().getToken(); // Implement this method in your HiveService

      // Set up headers with token
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Use the correct token format if needed
      };

      // Create the request body
      final body = jsonEncode({
        'name': name,
        'city_id': cityId,
        'dob': dob,
        'tob': tob,
        'tz': tz,
        'gender': gender,
      });

      print('Request Body: $body'); // Add this line for debugging
      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      // Check the response
      if (response.statusCode == 200) {
        // After successful profile update, refresh the guest profile in Hive
        await _refreshGuestProfile();
        // Handle successful response
        return true;
      } else {
        // Handle error response
        print('Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }

  // Helper method to fetch and update guest_profile in Hive
  Future<void> _refreshGuestProfile() async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token');
      String url = '$baseApiUrl/Guests/Get';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['error_code'] == "0") {
          var profileData = responseData['data']['item'];
          var guestProfile = profileData['guest_profile'];

          // Save guest_profile to Hive
          await box.put('guest_profile', guestProfile);
          print('Guest profile refreshed in Hive');
        }
      }
    } catch (e) {
      print('Error refreshing guest profile: $e');
    }
  }

  // Static method to refresh guest profile (can be called from anywhere)
  static Future<void> refreshGuestProfileInHive() async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token');
      String url = '$baseApiUrl/Guests/Get';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['error_code'] == "0") {
          var profileData = responseData['data']['item'];
          var guestProfile = profileData['guest_profile'];

          // Save guest_profile to Hive
          await box.put('guest_profile', guestProfile);
          print('Guest profile refreshed in Hive');
        }
      }
    } catch (e) {
      print('Error refreshing guest profile: $e');
    }
  }
}
