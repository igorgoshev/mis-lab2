import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.messageId}');
}

Future<void> setupFlutterNotifications() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const channel = AndroidNotificationChannel(
    'daily_jokes_channel',
    'Daily Jokes Notifications',
    description: 'Channel for daily joke notifications',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> initializeNotifications() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  tz.initializeTimeZones();

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      print('Notification tapped: ${response.payload}');
    },
  );

  // Firebase Messaging Setup
  final messaging = FirebaseMessaging.instance;

  // Request permissions
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Get FCM token
  String? token = await messaging.getToken();
  print('FCM Token: $token');

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message in foreground!');

    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_jokes_channel',
            'Daily Jokes Notifications',
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  });

  await scheduleDailyNotification(flutterLocalNotificationsPlugin);
}

Future<void> scheduleDailyNotification(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
  const androidDetails = AndroidNotificationDetails(
    'daily_jokes_channel',
    'Daily Jokes Notifications',
    channelDescription: 'Daily notification for joke of the day',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
  );

  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  final now = tz.TZDateTime.now(tz.local);
  var scheduledDate = tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    10, // Hour (24-hour format)
    0, // Minute
  );

  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Joke of the Day',
    'Time for your daily laugh! Check out today\'s joke! 😄',
    scheduledDate,
    notificationDetails,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await setupFlutterNotifications();
  await initializeNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jokes App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}