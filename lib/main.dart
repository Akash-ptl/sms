import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms/global.dart';
import 'package:sim_data/sim_data.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await AndroidAlarmManager.initialize();
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
  List<SimCard> _simCard = <SimCard>[];
  @override
  void initState() {
    super.initState();
    permissionServiceCall();
  }

  permissionServiceCall() async {
    await permissionServices().then(
      (value) async {
        if (value[Permission.phone]!.isGranted) {
          await _getSimCards();
        }
      },
    );
  }

  Future<void> _getSimCards() async {
    // final hasPermission = await MobileNumber.hasPhonePermission;
    // if (hasPermission) {
    //   final simCards = await MobileNumber.getSimCards;
    //   setState(() {
    //     _simCard = simCards!;
    //     _simCard.length = sim;
    //     print(_simCard.length);
    //   });
    // }

    if (Platform.isAndroid) {
      final SimData simData = await SimDataPlugin.getSimData();
      _simCard = simData.cards;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(simCard: _simCard,)),
      );
    }
  }

  Future<Map<Permission, PermissionStatus>> permissionServices() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.sms, Permission.phone].request();

    if (statuses[Permission.sms]!.isPermanentlyDenied) {
      openAppSettings();
    } else {
      if (statuses[Permission.sms]!.isDenied) {
        permissionServiceCall();
      }
    }
    if (statuses[Permission.phone]!.isPermanentlyDenied) {
      openAppSettings();
    } else {
      if (statuses[Permission.phone]!.isDenied) {
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
  const MyHomePage({super.key,required this.simCard});


  final List<SimCard> simCard;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool start = false;
  int? _choiceIndex;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: _choiceIndex !=null?FloatingActionButton(
        onPressed: () async {
          // setState(() {
          //   start = !start;
          //   // if (start == true) {
          //   //   AndroidAlarmManager.periodic(
          //   //       const Duration(minutes: 1), 0, sendSms);
          //   // } else {
          //   //   AndroidAlarmManager.cancel(0);
          //   // }
          // });
          sendSms();
        },
        child: (start == false)
            ? const Icon(Icons.send)
            : const Icon(Icons.stop),
      ):null,
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
        body: _buildChoiceChips(),
      ),
    );
  }
  Widget _buildChoiceChips() {
    return Container(
      height: MediaQuery.of(context).size.height/4,
      child: ListView.builder(
        itemCount: widget.simCard.length,
        itemBuilder: (BuildContext context, int index) {
          return ChoiceChip(
            label: Text(widget.simCard[index].carrierName),
            selected: _choiceIndex == index,
            selectedColor: Colors.red,
            onSelected: (bool selected) {
              setState(() {
                _choiceIndex = selected ? index : 0;
              });
            },
            backgroundColor: Colors.green,
            labelStyle: const TextStyle(color: Colors.white),
          );
        },
      ),
    );
  }

  Future<void> sendSms() async {
    // final Telephony telephony = Telephony.instance;
    //
    String phoneNumber = '6354449038';
    String message = 'HI';
    // telephony.sendSms(
    //   to: phoneNumber,
    //   message: 'KGE Technologies',
    // );
    // Map<String, dynamic> smsData = {
    //   'phoneNumber': phoneNumber,
    //   'message': message,
    //   'sim': sim
    // };
    // String jsonEncoded = json.encode(smsData);
    // print(jsonEncoded);
    if (Platform.isAndroid) {
      await Constants.nativeChannel.invokeMethod("sendSMS", {
        "mobileNumber": phoneNumber,
        "message": message,
        "subscriptionId": widget.simCard[_choiceIndex ?? 0].subscriptionId.toString(),
      });
    }
  }
}
