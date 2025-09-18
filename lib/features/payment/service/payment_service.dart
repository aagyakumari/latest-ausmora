// lib/services/payment_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/payment/model/payment_model.dart';
import 'package:flutter_application_1/features/payment/repo/payment_repo.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';

class PaymentService {
  final PaymentRepository _repository = PaymentRepository();

  List<PaymentOption> fetchPaymentOptions({
    required VoidCallback showSuccessOverlay,
    required VoidCallback onGoogleTap,
    required VoidCallback onStripeTap,
  }) {
    return _repository.getPaymentOptions(
      showSuccessOverlay: showSuccessOverlay,
      onGoogleTap: onGoogleTap,
      onStripeTap: onStripeTap,
    );
  }

  /// Start the inquiry process and get Stripe session ID
  Future<Map<String, dynamic>> startInquiryProcess({
    required String questionId,
    required String inquiryType,
    required Map<String, dynamic> profile,
    required Map<String, dynamic>? profile2,
  }) async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final url = startInquiryProcessApiUrl;
      
      Map<String, dynamic> requestBody = {
        "inquiry_type": 0, // Always use 0 for now
        "inquiry_regular": {
          "question_id": questionId,
        },
        "profile1": profile,
      };

      // Add profile2 for compatibility inquiries
      if (profile2 != null) {
        requestBody["profile2"] = profile2;
      }

      // Add date fields for specific inquiry types
      if (inquiryType.toLowerCase() == 'horoscope' && profile.containsKey('horoscope_from_date')) {
        requestBody["horoscope_from_date"] = profile['horoscope_from_date'];
      } else if (inquiryType.toLowerCase() == 'auspicious time' && profile.containsKey('auspicious_from_date')) {
        requestBody["auspicious_from_date"] = profile['auspicious_from_date'];
      }

      print('Starting inquiry process with URL: $url');
      print('Request body: ${jsonEncode(requestBody)}');
      print('Inquiry type: $inquiryType -> ${_getInquiryTypeNumber(inquiryType)}');
      print('Profile keys: ${profile.keys.toList()}');
      if (profile2 != null) {
        print('Profile2 keys: ${profile2.keys.toList()}');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['error_code'] == "0") {
          print('Inquiry process started successfully');
          print('Inquiry number: ${responseData['data']['inquiry_number']}');
          print('Stripe session ID: ${responseData['data']['client_secret']}');
          
          return {
            'success': true,
            'inquiry_number': responseData['data']['inquiry_number'],
            'client_secret': responseData['data']['client_secret'],
            'message': responseData['message'],
          };
        } else {
          print('API returned error: ${responseData['message']}');
          throw Exception(responseData['message'] ?? 'Failed to start inquiry process');
        }
      } else {
        print('HTTP error: ${response.statusCode}');
        print('Error response: ${response.body}');
        throw Exception('HTTP ${response.statusCode}: Failed to start inquiry process');
      }
    } catch (e) {
      print('Exception in startInquiryProcess: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Process payment using Stripe with the session ID
  Future<Map<String, dynamic>> processStripePayment({
    required String stripeSessionId,
    required String paymentMethod,
  }) async {
    try {
      print('Processing Stripe payment with session ID: $stripeSessionId');
      print('Payment method: $paymentMethod');

      // Initialize Stripe payment sheet with the session ID
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: stripeSessionId,
          style: ThemeMode.dark,
          merchantDisplayName: 'Ausmora',
          googlePay: paymentMethod == 'googlepay'
              ? const PaymentSheetGooglePay(
                  merchantCountryCode: 'US',
                  currencyCode: 'USD',
                  testEnv: true,
                )
              : null,
        ),
      );

      print('Payment sheet initialized successfully');

      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      print('Payment completed successfully');
      return {
        'success': true,
        'message': 'Payment completed successfully',
      };
    } on StripeException catch (e) {
      print('StripeException: ${e.toString()}');
      String errorMessage = 'Payment failed';
      
      // Handle different Stripe error types
      if (e.error.localizedMessage != null) {
        errorMessage = e.error.localizedMessage!;
      } else {
        errorMessage = 'Payment error: ${e.error.code}';
      }
      
      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      print('Unexpected error in processStripePayment: $e');
      return {
        'success': false,
        'error': 'Unexpected error: ${e.toString()}',
      };
    }
  }

  /// Get inquiry type number based on inquiry type string
  int _getInquiryTypeNumber(String inquiryType) {
    switch (inquiryType.toLowerCase()) {
      case 'horoscope':
        return 1;
      case 'compatibility':
        return 2;
      case 'auspicious time':
        return 3;
      case 'ask_a_question':
      default:
        return 0;
    }
  }

Future<bool> verifyPaymentStatus(String inquiryNumber) async {
  try {
    final box = Hive.box('settings');
    String? token = await box.get('token');

    if (token == null || token.isEmpty) {
      throw Exception("Authentication token not found");
    }

    final url = '$myInquiriesApiUrl?inquiry_number=$inquiryNumber';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['error_code'] == "0" && data['data'] != null) {
        final inquiries = data['data']['inquiries'] as List;
        if (inquiries.isNotEmpty) {
          return inquiries[0]['payment_successfull'] == true;
        }
      }
    }

    return false;
  } catch (e) {
    print("Error verifying payment status: $e");
    return false;
  }
}


}

