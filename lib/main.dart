import 'dart:convert';
import 'dart:io'; // <-- add this for HttpOverrides

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'; // <-- add this for kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants.dart';
import 'package:flutter_application_1/config/env.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_application_1/features/auspicious_time/ui/auspicious_time_page.dart';
import 'package:flutter_application_1/features/compatibility/ui/compatibility_page.dart';
import 'package:flutter_application_1/features/horoscope/ui/horoscope_page.dart';
import 'package:flutter_application_1/features/inbox/ui/chat_box_page.dart';
import 'package:flutter_application_1/features/inbox/ui/inbox_page.dart';
import 'package:flutter_application_1/features/mainlogo/ui/main_logo_page.dart';
import 'package:flutter_application_1/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_application_1/features/sign_up/ui/w1_page.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hive/hive.dart';
import 'hive/hive_service.dart'; // Import your Hive service
import 'package:http/http.dart' as http;

// 🔹 DevHttpOverrides class to accept self-signed certs in dev
class DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

final navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  await Env.load('.env');

  // 🔹 Only bypass SSL in debug mode
  if (kDebugMode) {
    HttpOverrides.global = DevHttpOverrides();
  }

  Stripe.publishableKey = Env.stripePublishableKey;
  await Firebase.initializeApp();
  await createNotificationChannel(); // Crea
  await initNotifications(); // Initialize noti  te the notification channel
  // ✅ Quick verification
FirebaseApp app = Firebase.app();
print('Firebase initialized: ${app.name}');
print('Firebase project ID: ${app.options.projectId}');
print('Firebase API key: ${app.options.apiKey}');

// ✅ Get FCM token
FirebaseMessaging messaging = FirebaseMessaging.instance;
String? fcmToken = await messaging.getToken();
print('FCM token: $fcmToken');


  // Initialize Hive and run the app...
  HiveService hiveService = HiveService();
  try {
    await hiveService.initHive();

    // Check if the API URL already exists in Hive
    final existingToken = await hiveService.getToken();

    // Do not overwrite the token on app start. Only saveApiData when logging in or signing up.
    await hiveService.saveOtpApiUrl(
      validateOtpApiUrl,
    );

    runApp(MyApp(existingToken: existingToken));
  } catch (e) {
    print('Error initializing Hive: $e');
    runApp(ErrorApp());
  }
}


class MyApp extends StatelessWidget {
  final String? existingToken;

  const MyApp({super.key, this.existingToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ausmora',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      navigatorKey: navigatorKey, // Assign navigatorKey to the MaterialApp
      home: FutureBuilder<Widget>(
        future: _getInitialPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return ErrorApp();
          } else {
            return snapshot.data!;
          }
        },
      ),
      routes: {
        '/dashboard': (context) => DashboardPage(),
        '/horoscope': (context) => HoroscopePage(showBundleQuestions: false),
        '/compatibility': (context) => CompatibilityPage(),
        '/auspiciousTime': (context) =>
            AuspiciousTimePage(showBundleQuestions: false),
        '/w1': (context) => W1Page(),
        '/mainlogo': (context) => MainLogoPage(),
        '/chat': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;

          if (args != null) {
            return ChatBoxPage(
              inquiryId: args['inquiryId'] ?? '',
              inquiry: args['inquiry'],
            );
          } else {
            return Scaffold(
              body: Center(child: Text('No data provided for the chat')),
            );
          }
        },
        '/inbox': (context) => InboxPage(), // Add route for InboxPage
      },
    );
  }

  Future<Widget> _getInitialPage() async {
    final box = Hive.box('settings');
    final guestProfile = await box.get('guest_profile');
    final token = await box.get('token');

    if (token == null || token == "") {
      return W1Page();
    } else if (token != null && guestProfile == null) {
      return MainLogoPage();
    } else if (token != null && guestProfile != null) {
      return DashboardPage();
    } else {
      return W1Page();
    }
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error',
      home: Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Failed to initialize the app.')),
      ),
    );
  }
}

// Create a notification channel (for Android >= API 26)
Future<void> createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'your_channel_id', // ID
    'Your Channel Name', // Name
    description:
        'This channel is used for important notifications.', // Description
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

// Initialize Firebase Messaging and handle notifications
Future<void> initNotifications() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission
  await messaging.requestPermission();

  // Get FCM Token and store in Hive
  final fcmToken = await messaging.getToken();
  if (fcmToken != null) {
    HiveService hiveService = HiveService();
    await hiveService.initHive();
    await hiveService.saveFcmToken(fcmToken);
    print('FCM Token stored in Hive: $fcmToken');

    // Debug: Verify the token was saved correctly
    final savedToken = await hiveService.getFcmToken();
    print('FCM Token verification - Retrieved from Hive: $savedToken');
    print('FCM Token verification - Tokens match: ${fcmToken == savedToken}');
  } else {
    print('Warning: FCM Token is null!');
  }

  // Handle background messages
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen(handleForegroundMessage);

  // Handle when the app is opened from a notification
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    handleNotificationTap(message);
  });
}

// Foreground message handler
void handleForegroundMessage(RemoteMessage message) {
  if (message.notification != null) {
    final notification = message.notification!;
    final androidNotification = notification.android;

    if (androidNotification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id', // Unique channel ID
            'Your Channel Name', // Channel name
            channelDescription: 'Your channel description',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    }
  }
}

// Background message handler
// Background message handler (when the app is terminated or in the background)
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Background Message Payload: ${message.data}');

  String inquiryId = message.data['inquiry_id'] ?? '';
  Map<String, dynamic>? inquiry;

  if (message.data['inquiry'] != null) {
    try {
      inquiry = jsonDecode(message.data['inquiry']); // Decode JSON string
    } catch (e) {
      print('Error decoding inquiry: $e');
    }
  }

  if (inquiryId.isNotEmpty) {
    navigatorKey.currentState?.pushNamed(
      '/chat',
      arguments: {'inquiryId': inquiryId, 'inquiry': inquiry},
    );
  }
}

// Handle notification tap
void handleNotificationTap(RemoteMessage message) async {
  String inquiryId = message.data['inquiry_id'] ?? '';
  if (inquiryId.isNotEmpty) {
    // Show loading dialog
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final box = Hive.box('settings');
      String? token = await box.get('token');
      final url = '$myInquiriesApiUrl?inquiry_id=$inquiryId';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      Navigator.of(navigatorKey.currentContext!).pop(); // Remove loading dialog

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['error_code'] == "0") {
          var inquiries = responseData['data']['inquiries'];
          if (inquiries is List && inquiries.isNotEmpty) {
            final inquiry = inquiries[0];
            navigatorKey.currentState?.pushNamed(
              '/chat',
              arguments: {'inquiryId': inquiryId, 'inquiry': inquiry},
            );
            return;
          }
        }
      }
      // Handle error: show a message or fallback
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to load inquiry.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.of(navigatorKey.currentContext!)
          .pop(); // Remove loading dialog if error
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Error loading inquiry: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
