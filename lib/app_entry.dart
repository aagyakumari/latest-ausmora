// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:hive/hive.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:http/http.dart' as http;

// import 'constants.dart';
// import 'hive/hive_service.dart';
// import 'features/dashboard/ui/dashboard_page.dart';
// import 'features/horoscope/ui/horoscope_page.dart';
// import 'features/compatibility/ui/compatibility_page.dart';
// import 'features/auspicious_time/ui/auspicious_time_page.dart';
// import 'features/sign_up/ui/w1_page.dart';
// import 'features/mainlogo/ui/main_logo_page.dart';
// import 'features/inbox/ui/chat_box_page.dart';
// import 'features/inbox/ui/inbox_page.dart';

// final navigatorKey = GlobalKey<NavigatorState>();
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// Future<void> bootstrapApp({bool firebaseEnabled = false}) async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Stripe setup
//   Stripe.publishableKey = stripePublishableKey;

//   // Initialize Firebase if prod
//   if (firebaseEnabled) {
//     await Firebase.initializeApp();
//     await createNotificationChannel();
//     await initNotifications();
//   }

//   // Initialize Hive
//   HiveService hiveService = HiveService();
//   try {
//     await hiveService.initHive();

//     final existingToken = await hiveService.getToken();

//     // Save API URLs
//     await hiveService.saveApiData(loginApiUrl, '');
//     await hiveService.saveOtpApiUrl(validateOtpApiUrl);

//     runApp(MyApp(existingToken: existingToken));
//   } catch (e) {
//     print('Error initializing Hive: $e');
//     runApp(const ErrorApp());
//   }
// }

// class MyApp extends StatelessWidget {
//   final String? existingToken;
//   const MyApp({super.key, this.existingToken});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Ausmora',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       navigatorKey: navigatorKey,
//       home: FutureBuilder<Widget>(
//         future: _getInitialPage(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             );
//           } else if (snapshot.hasError) {
//             return const ErrorApp();
//           } else {
//             return snapshot.data ?? W1Page();
//           }
//         },
//       ),
//       routes: {
//         '/dashboard': (_) => DashboardPage(),
//         '/horoscope': (_) => HoroscopePage(showBundleQuestions: false),
//         '/compatibility': (_) => CompatibilityPage(),
//         '/auspiciousTime': (_) => AuspiciousTimePage(showBundleQuestions: false),
//         '/w1': (_) => W1Page(),
//         '/mainlogo': (_) => MainLogoPage(),
//         '/chat': (context) {
//           final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//           if (args != null) {
//             return ChatBoxPage(
//               inquiryId: args['inquiryId'] ?? '',
//               inquiry: args['inquiry'],
//             );
//           }
//           return const Scaffold(
//             body: Center(child: Text('No data provided for the chat')),
//           );
//         },
//         '/inbox': (_) => InboxPage(),
//       },
//     );
//   }

//   Future<Widget> _getInitialPage() async {
//     final box = Hive.box('settings');
//     final guestProfile = await box.get('guest_profile');
//     final token = await box.get('token');

//     if (token == null || token.isEmpty) return W1Page();
//     if (guestProfile == null) return MainLogoPage();
//     return DashboardPage();
//   }
// }

// class ErrorApp extends StatelessWidget {
//   const ErrorApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Error',
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Error')),
//         body: const Center(child: Text('Failed to initialize the app.')),
//       ),
//     );
//   }
// }

// // Notification channel setup (prod only)
// Future<void> createNotificationChannel() async {
//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'your_channel_id',
//     'Your Channel Name',
//     description: 'This channel is used for important notifications.',
//     importance: Importance.high,
//   );

//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//           AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
// }

// // Firebase Messaging setup
// Future<void> initNotifications() async {
//   FirebaseMessaging messaging = FirebaseMessaging.instance;
//   await messaging.requestPermission();

//   final fcmToken = await messaging.getToken();
//   if (fcmToken != null) {
//     HiveService hiveService = HiveService();
//     await hiveService.initHive();
//     await hiveService.saveFcmToken(fcmToken);
//     print('FCM Token stored: $fcmToken');
//   }

//   // Handle background messages
//   FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

//   // Handle foreground messages
//   FirebaseMessaging.onMessage.listen(handleForegroundMessage);

//   // Handle when the app is opened from a notification
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     handleNotificationTap(message);
//   });
// }

// // Foreground message handler
// void handleForegroundMessage(RemoteMessage message) {
//   if (message.notification != null) {
//     final notification = message.notification!;
//     final androidNotification = notification.android;

//     if (androidNotification != null) {
//       flutterLocalNotificationsPlugin.show(
//         notification.hashCode,
//         notification.title,
//         notification.body,
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'your_channel_id', // Unique channel ID
//             'Your Channel Name', // Channel name
//             channelDescription: 'Your channel description',
//             importance: Importance.high,
//             priority: Priority.high,
//           ),
//         ),
//       );
//     }
//   }
// }

// // Background message handler
// // Background message handler (when the app is terminated or in the background)
// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   print('Background Message Payload: ${message.data}');

//   String inquiryId = message.data['inquiry_id'] ?? '';
//   Map<String, dynamic>? inquiry;

//   if (message.data['inquiry'] != null) {
//     try {
//       inquiry = jsonDecode(message.data['inquiry']); // Decode JSON string
//     } catch (e) {
//       print('Error decoding inquiry: $e');
//     }
//   }

//   if (inquiryId.isNotEmpty) {
//     navigatorKey.currentState?.pushNamed(
//       '/chat',
//       arguments: {'inquiryId': inquiryId, 'inquiry': inquiry},
//     );
//   }
// }

// // Handle notification tap
// void handleNotificationTap(RemoteMessage message) async {
//   String inquiryId = message.data['inquiry_id'] ?? '';
//   if (inquiryId.isNotEmpty) {
//     // Show loading dialog
//     showDialog(
//       context: navigatorKey.currentContext!,
//       barrierDismissible: false,
//       builder: (context) => const Center(child: CircularProgressIndicator()),
//     );

//     try {
//       final box = Hive.box('settings');
//       String? token = await box.get('token');
//       final url = '$myInquiriesApiUrl?inquiry_id=$inquiryId';
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {'Authorization': 'Bearer $token'},
//       );
//       Navigator.of(navigatorKey.currentContext!).pop(); // Remove loading dialog

//       if (response.statusCode == 200) {
//         var responseData = jsonDecode(response.body);
//         if (responseData['error_code'] == "0") {
//           var inquiries = responseData['data']['inquiries'];
//           if (inquiries is List && inquiries.isNotEmpty) {
//             final inquiry = inquiries[0];
//             navigatorKey.currentState?.pushNamed(
//               '/chat',
//               arguments: {'inquiryId': inquiryId, 'inquiry': inquiry},
//             );
//             return;
//           }
//         }
//       }
//       // Handle error: show a message or fallback
//       showDialog(
//         context: navigatorKey.currentContext!,
//         builder: (context) => AlertDialog(
//           title: const Text('Error'),
//           content: const Text('Failed to load inquiry.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       Navigator.of(navigatorKey.currentContext!)
//           .pop(); // Remove loading dialog if error
//       showDialog(
//         context: navigatorKey.currentContext!,
//         builder: (context) => AlertDialog(
//           title: const Text('Error'),
//           content: Text('Error loading inquiry: $e'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('OK'),
//             ),
//           ],
//         ),
//       );
//     }
//   }
// }
