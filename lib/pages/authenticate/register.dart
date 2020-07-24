import 'package:flutter/material.dart';
import 'package:nearby_places/services/auth.dart';
import 'package:email_validator/email_validator.dart';

class Register extends StatefulWidget {

  final Function toggle;
  Register({this.toggle});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";
  String errMsg = '';
  bool isDisabled = false;

  @override
  Widget build(BuildContext context) {
    final Widget registerBtn = RaisedButton(
      onPressed: isDisabled ? null : () async {
        setState(() {
          isDisabled = true;
        });
        if (_formKey.currentState.validate()) {
          dynamic result =
              await _authService.registerWithEmailAndPassword(email, password);
          if (result != null) {
            print("Registered successfully");
          } else {
            print("some error");
            setState(() {
              isDisabled = false;
              errMsg = AuthService.errorMsg;
            });
          }
        }else{
          setState(() {
            isDisabled = false;
          });
        }
      },
      child: Text("Register"),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.orange,
    );

    final List<Widget> emailPasswordFormField = [
      TextFormField(
        onChanged: (val) {
          email = val;
        },
        textAlign: TextAlign.center,
        validator: (val) =>
            EmailValidator.validate(val) ? null : "Enter an valid email",
        decoration: InputDecoration(
          border:
              new OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          hintText: "Email",
          filled: true,
        ),
      ),
      SizedBox(height: 10),
      // Password field
      TextFormField(
        onChanged: (val) {
          password = val;
        },
        validator: (val) =>
            val.length < 6 ? "Enter password with 6+ chars" : null,
        obscureText: true,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          hintText: "password",
          filled: true,
        ),
      ),
      SizedBox(height: 10),
      Text(
        errMsg,
        style: TextStyle(
          color: Colors.red,
          fontSize: 16,
        ),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
        backgroundColor: Colors.blue[700],
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () {
              widget.toggle();
            },
            icon: Icon(Icons.person),
            label: Text("Login"),
          ),
        ],
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
              child: Form(
                key: _formKey,
                child: Column(
                  children: emailPasswordFormField + [registerBtn],
                ),
              ),
            )
          ]),
    );
  }
}
