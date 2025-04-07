import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart'; // เพิ่ม import สำหรับ intl
import 'package:intl/date_symbol_data_local.dart'; // เพิ่ม import สำหรับการเริ่มต้น locale
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/splash_screen.dart';
import 'scripts/seed_emergency_numbers.dart';
import 'scripts/seed_first_aid.dart'; // เพิ่ม import สำหรับ seed_first_aid
import 'scripts/seed_news.dart'; // เพิ่ม import สำหรับ seed_news
import 'services/background_service.dart';
import 'services/notification_service.dart';
import 'features/sos/sos_confirmation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // เริ่มต้น Firebase
  // await FirebaseAuth.instance.signOut(); // ล็อกเอาท์ผู้ใช้ทั้งหมด (เพื่อทดสอบ)

  // เพิ่มการ seed ข้อมูลเบอร์โทรฉุกเฉิน
  await seedEmergencyNumbers();
  
  // เพิ่มการ seed ข้อมูลการปฐมพยาบาล
  await seedFirstAidData();
  
  // เพิ่มการ seed ข้อมูลข่าวสาร
  await seedNewsData();

  // เริ่มต้น locale สำหรับ intl
  await initializeDateFormatting('th', null);

  // ขอสิทธิ์ที่จำเป็น
  await _requestPermissions();
  
  // เริ่มต้น background service
  await initializeService();
  
  // เริ่มต้น NotificationService
  await NotificationService().initialize();
  
  // ตั้งค่า notification actions listener
  FlutterLocalNotificationsPlugin().initialize(
    InitializationSettings(
      android: AndroidInitializationSettings('notification_icon'),
    ),
    onDidReceiveNotificationResponse: _handleNotificationAction,
  );

  runApp(MyApp());
}

/// รับเหตุการณ์การคลิกการแจ้งเตือน
void _handleNotificationAction(NotificationResponse details) {
  if (details.actionId == 'CONFIRM_SOS') {
    // เปิดแอพที่หน้า SOS confirmation screen
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(builder: (context) => SosConfirmationScreen(detectionSource: 'notification')),
    );
  }
}

Future<void> _requestPermissions() async {
  await [
    Permission.location,
    Permission.sms,
    Permission.phone,
    Permission.notification,
  ].request();
}

// Global navigator key ที่จะใช้สำหรับ navigation จากภายนอก Widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Emergency App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: SplashScreen(),
      navigatorKey: navigatorKey, // เพิ่ม navigator key
      debugShowCheckedModeBanner: false,
    );
  }
}