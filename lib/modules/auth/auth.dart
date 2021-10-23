import 'package:digital_auth/modules/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  LocalAuthentication auth = LocalAuthentication();
  late bool _canCheckBiometric;
  late bool _isDeviceSupported;
  List<BiometricType> _availableBiometric = [];
  String autherized = "Not autherized";

  Future<void> _checkBiometric() async {
    late bool canCheckBiometric;

    try {
      canCheckBiometric = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    print("AQUI");
    if (!mounted) return;
    print(canCheckBiometric);
    setState(() {
      _canCheckBiometric = canCheckBiometric;
    });
  }

  Future<void> _deviceSupported() async {
    late bool isDeviceSupported;

    try {
      isDeviceSupported = await auth.isDeviceSupported();
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      _isDeviceSupported = isDeviceSupported;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometric = [];

    try {
      availableBiometric = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      _availableBiometric = availableBiometric;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;

    if (_canCheckBiometric && _isDeviceSupported) {
      try {
        authenticated = await auth.authenticate(
            localizedReason: "Digitalize sua impressão digital para autenticar",
            useErrorDialogs: true,
            biometricOnly: true,
            stickyAuth: false);
      } on PlatformException catch (e) {
        print(e);
      }

      if (!mounted) return;

      authenticated
          ? Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => MyHomePage(
                  title: "My Home Page",
                ),
              ),
            )
          : null;
    } else {
      print("ERROR");
    }
  }

  loadingInfo() async {
    await _checkBiometric();
    await _deviceSupported();
    await _getAvailableBiometrics();
  }

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      loadingInfo();
    });

    Future.delayed(Duration(seconds: 2), () {
      _authenticate();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      // appBar: AppBar(
      //   title: Text('Auth Page'),
      // ),
      // body: Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: <Widget>[
      //     Center(
      //       child: RaisedButton(
      //         onPressed: _authenticate,
      //         child: Text("Obter biométrico"),
      //       ),
      //     ),
      //     Text("Can check biometric: $_canCheckBiometric"),
      //     Text("Device Supported: $_isDeviceSupported"),
      //     Text("Available biometric: $_availableBiometric"),
      //     Text("Current State: $autherized"),
      //   ],
      // ),
    );
  }
}
