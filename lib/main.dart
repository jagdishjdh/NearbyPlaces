import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearby_places/pages/authenticate/authenticate.dart';
import 'package:provider/provider.dart';
import 'package:nearby_places/services/auth.dart';
import 'package:nearby_places/pages/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    return MaterialApp(
//      initialRoute: 'login',
//      routes: {
//        'login': (context) => Login(),
//        'register': (context) => Register(),
//        'home' : (context) => Home(),
//        'place_details' : (context) => PlaceDetails(),
//        'dish_detail' : (context) => DishDetail(),
//        'review' : (context) => Review(),
//        'user_detail' : (context) => UserDetail(),
//        'my_places' : (context) => MyPlaces(),
//        'add_place' : (context) => AddPlace(),
//        'my_reviews' : (context) => MyReviews(),
//      },
//    );
    return StreamProvider<FirebaseUser>.value(
      value: AuthService().userStream,
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUser>(context);
//    print("user : $user");
    if(user == null){
      return Authenticate();
    }else{
      return Home();
    }
  }
}
