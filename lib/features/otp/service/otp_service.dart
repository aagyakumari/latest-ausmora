import 'dart:convert';
import 'package:flutter_application_1/hive/hive_service.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class OtpService {
  final HiveService _hiveService = HiveService(); // Create an instance of HiveService

  Future<bool> verifyOtp(String otp, String email, bool timeup) async {
    final box = Hive.box('settings');
    final baseUrl = await box.get('otpApiUrl'); // Retrieve OTP validation URL
    final int otps = int.parse(otp);
    final String? deviceToken = await box.get('fcmToken'); // FCM token is saved as 'fcmToken'

    // Debug logging
    print('OTP Service Debug:');
    print('Email: $email');
    print('OTP: $otps');
    print('Device Token (FCM): $deviceToken');
    print('Base URL: $baseUrl');
    print('Timeup: $timeup');

    // Check if FCM token is available
    if (deviceToken == null || deviceToken.isEmpty) {
      print('Warning: FCM Token is null or empty!');
      print('This might cause issues with push notifications.');
    }

    if (baseUrl != null) {
      final url = !timeup
          ? '$baseUrl?email=$email&otp=$otps&device_token=$deviceToken&is_android=true'
          : '$baseUrl?email=$email&otp=000000&device_token=$deviceToken&is_android=true';

      print('Full API URL: $url');
      final response = await http.get(Uri.parse(url)); // Call the API

      if (response.statusCode == 200 && jsonDecode(response.body)['error_code'] == '0') {
        var responseData = jsonDecode(response.body);
        print('OTP validated successfully: ${response.body}');

        if (responseData['data'] != null && responseData['data']['token'] != null) {
          await _hiveService.saveToken(responseData['data']['token']); // Save the token
        }

        return true; // Indicate successful verification
      } else {
        print('Error validating OTP: ${response.statusCode}');
        return false; // Indicate failure
      }
    } else {
      print('Base URL not found in Hive.');
      return false; // Indicate failure
    }
  }

  // Test method to verify FCM token is properly stored and retrieved
  Future<void> testFcmTokenStorage() async {
    final box = Hive.box('settings');
    final fcmToken = await box.get('fcmToken');
    
    print('=== FCM Token Test ===');
    print('FCM Token from Hive: $fcmToken');
    print('FCM Token is null: ${fcmToken == null}');
    print('FCM Token is empty: ${fcmToken?.isEmpty ?? true}');
    print('FCM Token length: ${fcmToken?.length ?? 0}');
    print('=====================');
    
    // Also test if we can get the token directly from Firebase
    try {
      final firebaseToken = await FirebaseMessaging.instance.getToken();
      print('=== Direct Firebase Token Test ===');
      print('Direct Firebase Token: $firebaseToken');
      print('Direct Token matches Hive: ${fcmToken == firebaseToken}');
      print('===============================');
    } catch (e) {
      print('Error getting direct Firebase token: $e');
    }
  }

  // Test method to send a test notification to yourself
  Future<void> testNotification() async {
    final box = Hive.box('settings');
    final fcmToken = await box.get('fcmToken');
    
    if (fcmToken == null || fcmToken.isEmpty) {
      print('Cannot test notification: FCM token is null or empty');
      return;
    }
    
    print('=== Testing Notification ===');
    print('FCM Token for testing: $fcmToken');
    print('You can use this token to send a test notification from your server');
    print('===========================');
  }
}
