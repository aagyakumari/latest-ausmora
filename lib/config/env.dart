import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static Future<void> load(String fileName) async {
    await dotenv.load(fileName: fileName);
  }

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? (throw 'API_BASE_URL missing');

  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? (throw 'STRIPE_PUBLISHABLE_KEY missing');
}
