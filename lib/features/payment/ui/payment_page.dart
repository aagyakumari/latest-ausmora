// lib/features/payment/ui/payment_ui.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/bottom_nav_bar.dart';
import 'package:flutter_application_1/components/topnavbar.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/mainlogo/ui/main_logo_page.dart';
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
  final String?
      clientSecret; // Optional client secret provided by previous step
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
                          MaterialPageRoute(
                              builder: (context) => SupportPage()),
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
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.03),
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
    // --- Question Row ---
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question: ',
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            widget.question,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    ),
    SizedBox(height: screenHeight * 0.02),

    // --- Price Row ---
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
        Expanded(
        child:Text(
          '\$${widget.price}',
          style: TextStyle(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFF9933),
          ),
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

// --- Payment Grid ---
Padding(
  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
  child: GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2, // 2 per row
      crossAxisSpacing: screenWidth * 0.06,
      mainAxisSpacing: screenHeight * 0.03,
      childAspectRatio: 1.2, // slightly taller boxes
    ),
    itemCount: paymentOptions.length,
    itemBuilder: (context, index) {
      final option = paymentOptions[index];
      return GestureDetector(
        onTap: _isProcessing ? null : option.onTap,
        child: Opacity(
          opacity: _isProcessing ? 0.6 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Image.asset(
                  option.imagePath,
                  width: screenWidth * 0.18,
                  height: screenWidth * 0.18,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    },
  ),
),
// --- Error Message (if any) ---
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
          currentPageIndex: null,
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
        isVerified =
            await widget._paymentService.verifyPaymentStatus(inquiryNumber);
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

  void _showSuccessDialog(String inquiryNumber) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      elevation: 8,
      titlePadding: const EdgeInsets.only(top: 20, bottom: 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      title: Center(
        child: Text(
          'Payment Successful!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFFFF9933), // primary color
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Color(0xFFFF9933),
            size: 60,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your inquiry has been created successfully.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            'Inquiry Number: $inquiryNumber',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF9933),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () async {
            Navigator.of(context).pop();

            final box = Hive.box('settings');
            final guestProfile = await box.get('guest_profile');

            if (guestProfile != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainLogoPage()),
              );
            }
          },
          child: const Text(
            'Continue',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}


 /// Show error dialog
void _showError(String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      elevation: 8,
      titlePadding: const EdgeInsets.only(top: 20, bottom: 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      title: Center(
        child: Text(
          'Error',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.redAccent, // Red for error
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_rounded,
            color: Colors.redAccent,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'OK',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
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
