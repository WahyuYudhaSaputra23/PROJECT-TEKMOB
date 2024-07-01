import 'package:flutter/material.dart';
import 'login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeNotifications();
  runApp(const MyApp());
}

void initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: selectNotification,
  );
}

Future selectNotification(String? payload) async {
  // Tindakan yang dilakukan saat notifikasi dipilih
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
  // Arahkan ke halaman yang diinginkan
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600, // Poppins-SemiBold
            ),
          ),
        ),
      ),
    );
  }
}
