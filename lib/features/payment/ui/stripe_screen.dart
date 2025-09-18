// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_application_1/constants.dart'; // contains `stripeSecretKey`

// class StripeScreen extends StatefulWidget {
//   final String paymentMethod; // "card" or "googlepay"

//   const StripeScreen({super.key, required this.paymentMethod});

//   @override
//   State<StripeScreen> createState() => _StripeScreenState();
// }

// class _StripeScreenState extends State<StripeScreen> {
//   Map<String, dynamic>? paymentIntent;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Stripe Payment')),
//       body: Center(
//         child: TextButton(
//           onPressed: () async {
//             await makePayment();
//           },
//           child: Text(
//             widget.paymentMethod == 'googlepay'
//                 ? 'Pay with Google Pay'
//                 : 'Pay with Card',
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> makePayment() async {
//     try {
//       paymentIntent = await createPaymentIntent('100', 'USD');

//       final bool isGooglePay = widget.paymentMethod == 'googlepay';

//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: paymentIntent!['client_secret'],
//           style: ThemeMode.dark,
//           merchantDisplayName: 'Ikay',
//           googlePay: isGooglePay
//               ? const PaymentSheetGooglePay(
//                   merchantCountryCode: 'US',
//                   currencyCode: 'USD',
//                   testEnv: true,
//                 )
//               : null,
//         ),
//       );

//       await displayPaymentSheet();
//     } catch (err) {
//       print('Payment failed: $err');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${err.toString()}')),
//       );
//     }
//   }

//   Future<void> displayPaymentSheet() async {
//     try {
//       await Stripe.instance.presentPaymentSheet();

//       showDialog(
//         context: context,
//         builder: (_) => const AlertDialog(
//           title: Text('Success'),
//           content: Text('Payment completed!'),
//         ),
//       );

//       paymentIntent = null;
//     } on StripeException catch (e) {
//       print('StripeException: $e');
//       showDialog(
//         context: context,
//         builder: (_) => const AlertDialog(
//           title: Text("Payment Cancelled"),
//           content: Text("The payment process was cancelled."),
//         ),
//       );
//     } catch (e) {
//       print('Unexpected error: $e');
//     }
//   }

//   Future<Map<String, dynamic>> createPaymentIntent(
//       String amount, String currency) async {
//     try {
//       final body = {
//         'amount': calculateAmount(amount),
//         'currency': currency,
//         'payment_method_types[]': 'card',
//       };

//       final response = await http.post(
//         Uri.parse('https://api.stripe.com/v1/payment_intents'),
//         headers: {
//           'Authorization': 'Bearer $stripeSecretKey',
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: body,
//       );

//       return json.decode(response.body);
//     } catch (err) {
//       throw Exception('Failed to create PaymentIntent: $err');
//     }
//   }

//   String calculateAmount(String amount) {
//     final int calculatedAmount = (int.parse(amount)) * 100;
//     return calculatedAmount.toString();
//   }
// }
