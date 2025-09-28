import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/features/profile/model/profile_model.dart';
import 'package:flutter_application_1/hive/hive_service.dart'; // Assuming this is where you're storing the token
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileServices {
  static  String _getProfileUrl = '$baseApiUrl/Guests/Get';

  // Method to fetch the user's profile
  static Future<ProfileModel?> getProfile() async {
    try {
      final token = await HiveService().getToken();
      
      // Headers with token check
      Map<String, String> headers = {};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(Uri.parse(_getProfileUrl), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if (jsonResponse['error_code'] == "0") {
          final profileData = jsonResponse['data']?['item'];
          if (profileData != null) {
            return ProfileModel.fromJson(profileData);
          } else {
            print('Profile data is missing in response.');
          }
        } else {
          print('API Error: ${jsonResponse['message']}');
        }
      } else {
        print('Failed to fetch profile. HTTP Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception during profile fetch: $e');
    }
    return null;
  }
}
