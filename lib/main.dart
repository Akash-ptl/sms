import 'dart:convert';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PermissionHandlerScreen(),
    );
  }
}

class PermissionHandlerScreen extends StatefulWidget {
  const PermissionHandlerScreen({super.key});

  @override
  _PermissionHandlerScreenState createState() =>
      _PermissionHandlerScreenState();
}

class _PermissionHandlerScreenState extends State<PermissionHandlerScreen> {
  @override
  void initState() {
    super.initState();
    permissionServiceCall();
  }

  permissionServiceCall() async {
    await permissionServices().then(
      (value) {
        if (value[Permission.sms]!.isGranted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyHomePage()),
          );
        }
      },
    );
  }

  Future<Map<Permission, PermissionStatus>> permissionServices() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
    ].request();

    if (statuses[Permission.sms]!.isPermanentlyDenied) {
      openAppSettings();
    } else {
      if (statuses[Permission.sms]!.isDenied) {
        permissionServiceCall();
      }
    }

    return statuses;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
        return Future.value(false);
      },
      child: Scaffold(
        body: Center(
          child: InkWell(
              onTap: () {
                permissionServiceCall();
              },
              child: const Text("Click on Allow all the time")),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool start = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            title: const Text(
              'KGE Technologies',
              style: TextStyle(fontFamily: 'helvetica'),
            ),
            centerTitle: true,
            leading: Image.network(
                'https://raw.githubusercontent.com/kgetechnologies/kgesitecdn/kgetechnologies-com/images/KgeMain.png')),
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            setState(() {
              start = !start;
              if (start == true) {
                AndroidAlarmManager.periodic(
                    const Duration(minutes: 1), 0, sendSms);
              } else {
                AndroidAlarmManager.cancel(0);
              }
            });
          },
          child: (start == false)
              ? const Icon(Icons.send)
              : const Icon(Icons.stop),
        ),
      ),
    );
  }
}

Future<void> sendSms() async {
  final Telephony telephony = Telephony.instance;

  String phoneNumber = '9328895180';
  String message = 'KGE Technologies';

  telephony.sendSms(
    to: phoneNumber,
    message: 'KGE Technologies',
  );
  Map<String, dynamic> smsData = {
    'phoneNumber': phoneNumber,
    'message': message,
  };
  String jsonEncoded = json.encode(smsData);
  print(jsonEncoded);
}
