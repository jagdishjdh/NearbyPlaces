import 'package:flutter/material.dart';
import 'package:nearby_places/pages/authenticate/login.dart';
import 'package:nearby_places/pages/authenticate/register.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  static bool isLogin = true;

  void toggle(){
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLogin ? Login(toggle: this.toggle) : Register(toggle: this.toggle);
  }
}
