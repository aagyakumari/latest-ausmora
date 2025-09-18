// lib/features/payment/ui/payment_ui.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/components/topnavbar.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/menu/ui/menu_page.dart';
import 'package:flutter_application_1/features/payment/service/payment_service.dart';
import 'package:flutter_application_1/features/payment/ui/gpay_screen.dart';
import 'package:flutter_application_1/features/payment/ui/stripe_screen.dart';
import 'package:flutter_application_1/features/support/ui/support_page.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentPage extends StatefulWidget {
  final PaymentService _paymentService = PaymentService();
  final Function _handleTickIconTap;
  final String question;
  final double price;
  final String inquiryType;
  final String? questionId;
  final Map<String, dynamic>? profile2;
  final String? selectedDate; // Add selected date parameter
  final Map<String, dynamic>? editedProfile; // Add edited profile parameter
  final String? clientSecret; // Optional client secret provided by previous step
  final String? inquiryNumber; // Optional inquiry number from previous step

  PaymentPage({
    super.key,
    required Function handleTickIconTap,
    required this.question,
    required this.price,
    required this.inquiryType,
    this.questionId,
    this.profile2,
    this.selectedDate, // Add selected date parameter
    this.editedProfile, // Add edited profile parameter
    this.clientSecret,
    this.inquiryNumber,
  }) : _handleTickIconTap = handleTickIconTap;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final paymentOptions = widget._paymentService.fetchPaymentOptions(
      showSuccessOverlay: () => _handleNonStripePayment(),
      onStripeTap: () => _handleStripePayment('card'),
      onGoogleTap: () => _handleStripePayment('googlepay'),
    );

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopNavBar(
                      title: 'Payment',
                      onLeftButtonPressed: () {
                        Navigator.pop(context);
                      },
                      onRightButtonPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SupportPage()),
                        );
                      },
                      leftIcon: Icons.arrow_back,
                      rightIcon: Icons.help,
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: screenWidth * 0.9,
                            padding: EdgeInsets.all(screenWidth * 0.05),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(screenWidth * 0.03),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Question:',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  widget.question,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Price:',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      '\$${widget.price}',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFFF9933),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          Text(
                            'Choose Payment Method:',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: paymentOptions.map((option) {
                              return Column(
                                children: [
                                  GestureDetector(
                                    onTap: _isProcessing ? null : option.onTap,
                                    child: Opacity(
                                      opacity: _isProcessing ? 0.6 : 1.0,
                                      child: Image.asset(
                                        option.imagePath,
                                        width: screenWidth * 0.2,
                                        height: screenWidth * 0.2,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.02),
                                ],
                              );
                            }).toList(),
                          ),
                          if (_errorMessage != null) ...[
                            SizedBox(height: screenHeight * 0.02),
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.03),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: screenWidth * 0.03,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        ),
      ),
    );
  }

  // // / Handle Stripe payment (both card and Google Pay)
  // Future<void> _handleStripePayment(String paymentMethod) async {
  //   setState(() {
  //     _isProcessing = true;
  //     _errorMessage = null;
  //   });

  //   try {
  //     final String? stripeSessionId = widget.clientSecret;
  //     final String? inquiryNumber = widget.inquiryNumber;
  //     print("Stripe Session ID: $stripeSessionId"); // 👈 This will print it to console
  //     print("Inquiry Number: $inquiryNumber");

  //     if (stripeSessionId == null) {
  //       throw Exception('Payment cannot proceed: missing client secret.');
  //     }

  //     // Step 1 (already done upstream): Inquiry created and client secret provided
  //     // Step 2: Process payment with Stripe using the provided session ID
  //     final paymentResult = await widget._paymentService.processStripePayment(
  //       stripeSessionId: stripeSessionId,
  //       paymentMethod: paymentMethod,
  //     );

  //     if (paymentResult['success']) {
  //       // Payment successful
  //       if (inquiryNumber != null) {
  //         _showSuccessDialog(inquiryNumber);
  //       } else {
  //         _showSuccessDialog('');
  //       }
  //     } else {
  //       throw Exception(paymentResult['error']);
  //     }
  //   } catch (e) {
  //     _showError('Payment failed: ${e.toString()}');
  //   } finally {
  //     setState(() {
  //       _isProcessing = false;
  //     });
  //   }
  // }

  /// Handle Stripe payment (both card and Google Pay)
// Future<void> _handleStripePayment(String paymentMethod) async {
//   setState(() {
//     _isProcessing = true;
//     _errorMessage = null;
//   });

//   try {
//     final String? stripeSessionId = widget.clientSecret;
//     final String? inquiryNumber = widget.inquiryNumber;
//     print("Stripe Session ID: $stripeSessionId");
//     print("Inquiry Number: $inquiryNumber");

//     if (stripeSessionId == null) {
//       throw Exception('Payment cannot proceed: missing client secret.');
//     }

//     // Step 2: Process payment with Stripe
//     final paymentResult = await widget._paymentService.processStripePayment(
//       stripeSessionId: stripeSessionId,
//       paymentMethod: paymentMethod,
//     );

//     if (paymentResult['success']) {
//       if (inquiryNumber != null && inquiryNumber.isNotEmpty) {
//         // ✅ Verify payment with backend
//         bool isVerified = await widget._paymentService.verifyPaymentStatus(inquiryNumber);

//         if (isVerified) {
//           _showSuccessDialog(inquiryNumber);
//         } else {
//           _showError('Payment could not be verified yet. Please try again later.');
//         }
//       } else {
//         _showError('Missing inquiry number. Cannot verify payment.');
//       }
//     } else {
//       throw Exception(paymentResult['error']);
//     }
//   } catch (e) {
//     _showError('Payment failed: ${e.toString()}');
//   } finally {
//     setState(() {
//       _isProcessing = false;
//     });
//   }
// }



/// Handle Stripe payment (both card and Google Pay) with backend verification polling
Future<void> _handleStripePayment(String paymentMethod) async {
  setState(() {
    _isProcessing = true;
    _errorMessage = null;
  });

  try {
    final String? stripeSessionId = widget.clientSecret;
    final String? inquiryNumber = widget.inquiryNumber;

    if (stripeSessionId == null) {
      throw Exception('Payment cannot proceed: missing client secret.');
    }

    // Step 1: Process payment with Stripe
    final paymentResult = await widget._paymentService.processStripePayment(
      stripeSessionId: stripeSessionId,
      paymentMethod: paymentMethod,
    );

    if (!paymentResult['success']) {
      throw Exception(paymentResult['error']);
    }

    // Step 2: Poll backend to verify payment
    if (inquiryNumber == null || inquiryNumber.isEmpty) {
      _showError('Missing inquiry number. Cannot verify payment.');
      return;
    }

    bool isVerified = false;
    int attempts = 0;
    const int maxAttempts = 5; // Try 5 times
    const Duration delayBetweenAttempts = Duration(seconds: 2);

    while (!isVerified && attempts < maxAttempts) {
      isVerified = await widget._paymentService.verifyPaymentStatus(inquiryNumber);
      if (!isVerified) {
        await Future.delayed(delayBetweenAttempts);
        attempts++;
      }
    }

    if (isVerified) {
      _showSuccessDialog(inquiryNumber);
    } else {
      _showError('Payment could not be verified. Please contact support.');
    }
  } catch (e) {
    _showError('Payment failed: ${e.toString()}');
  } finally {
    setState(() {
      _isProcessing = false;
    });
  }
}



  /// Handle non-Stripe payment methods
  void _handleNonStripePayment() {
    // For now, just show success overlay
    // You can implement other payment methods here later
    widget._handleTickIconTap();
  }

  /// Show success dialog
  void _showSuccessDialog(String inquiryNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 50,
            ),
            const SizedBox(height: 16),
            Text('Your inquiry has been created successfully.'),
            const SizedBox(height: 8),
            Text(
              'Inquiry Number: $inquiryNumber',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  /// Show error message
  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  /// Fetch profile data from API
  Future<Map<String, dynamic>?> _fetchProfileFromAPI() async {
    try {
      final box = Hive.box('settings');
      String? token = await box.get('token');
      
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse(getGuestApiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['error_code'] == "0") {
          final profileData = responseData['data']['item'];
          print('Fetched profile from API: ${profileData.keys.toList()}');
          return profileData;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to fetch profile');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: Failed to fetch profile');
      }
    } catch (e) {
      print('Error fetching profile from API: $e');
      return null;
    }
  }
}
