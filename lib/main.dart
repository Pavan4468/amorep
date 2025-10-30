import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'sign_in_screen.dart';
import 'home_screen1.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize OneSignal
  await initializeOneSignal();

  runApp(const MyApp());
}

// OneSignal initialization function
Future<void> initializeOneSignal() async {
  // Enable verbose logging (optional, for debugging)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  // Initialize OneSignal with your App ID (NO await here)
  OneSignal.initialize('71fc2c4f-dd2d-4556-8d41-830298f312b7');

  // Request permission for notifications (especially for iOS)
  OneSignal.Notifications.requestPermission(true);

  // Handle notification click
  OneSignal.Notifications.addClickListener((event) {
    print('Notification clicked: ${event.notification}');
  });

  // Handle notification received while app is in foreground
  OneSignal.Notifications.addForegroundWillDisplayListener((event) {
    print('Notification received: ${event.notification}');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Media Upload App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Wrapper(),
    );
  }
}

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          // Set the external user ID for OneSignal when user is authenticated
          _setOneSignalExternalUserId(snapshot.data!.uid);
          return MainPage(); // Authenticated user
        }
        return const SignInScreen(); // Not authenticated
      },
    );
  }
}

// Function to set external user ID for OneSignal
void _setOneSignalExternalUserId(String userId) {
  OneSignal.login(userId); // Link OneSignal to Firebase user
}

// Function to remove external user ID when user signs out
void _removeOneSignalExternalUserId() {
  OneSignal.logout(); // Unlink OneSignal on sign-out
}
