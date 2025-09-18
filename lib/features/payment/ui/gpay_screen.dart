import 'package:flutter/material.dart';
import 'package:flutter_application_1/payment_config.dart';
import 'package:pay/pay.dart';

class GooglePayScreen extends StatelessWidget {
  const GooglePayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: GooglePayButton(
            paymentConfiguration: PaymentConfiguration.fromJsonString(defaultGooglePay),
            paymentItems: const [
              PaymentItem(
                label: 'Total',
                amount: '0.01',
                status: PaymentItemStatus.final_price,
              )
            ],
            type: GooglePayButtonType.pay,
            margin: const EdgeInsets.only(top: 15.0),
            height: 50.0,
            width: MediaQuery.of(context).size.width * 0.85,
            onPaymentResult: (result) => debugPrint('Payment Result $result'),
            loadingIndicator: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}