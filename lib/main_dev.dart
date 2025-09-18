// import 'dart:io';
// import 'config/env.dart';
// import 'app_entry.dart';

// class DevHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }

// Future<void> main() async {
//   // Dev-specific SSL bypass
//   HttpOverrides.global = DevHttpOverrides();

//   // Load dev environment
//   await Env.load('.env.dev');

//   // Bootstrap app without Firebase
//   await bootstrapApp(firebaseEnabled: false);
// }
