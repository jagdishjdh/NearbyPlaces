import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:nearby_places/pages/authenticate/register.dart';
import 'package:nearby_places/services/auth.dart';

class Login extends StatefulWidget {

  final Function toggle;
  Login({this.toggle});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";
  String errMsg = '';
  bool isDisabled = false;

  @override
  Widget build(BuildContext context) {
    final Widget signinBtn = RaisedButton(
      onPressed: isDisabled ? null : () async {
        setState(() {
          isDisabled = true;
        });
        if (_formKey.currentState.validate()) {
          dynamic result =
          await _authService.signInWithEmailAndPassword(email, password);
          if (result != null) {
            print("signed in successfully");
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
      child: Text("Sign In"),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.green,
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

    final Widget dividerOR = Row(
      children: <Widget>[
        Expanded(
          child: Divider(
            color: Colors.black,
          ),
        ),
        Text("OR"),
        Expanded(
          child: Divider(
            color: Colors.black,
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Colors.blue[700],
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () {
              widget.toggle();
            },
            icon: Icon(Icons.person),
            label: Text("Register"),
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
                  children: emailPasswordFormField + [signinBtn],
                ),
              ),
            )
          ]),
    );
  }
}
