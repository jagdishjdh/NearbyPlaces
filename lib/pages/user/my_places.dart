import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nearby_places/services/auth.dart';
import 'package:nearby_places/services/database.dart';
import 'package:nearby_places/services/widget_utils.dart';

class MyPlaces extends StatefulWidget {
  @override
  _MyPlacesState createState() => _MyPlacesState();
}

class _MyPlacesState extends State<MyPlaces> {
  FirebaseUser _user = AuthService.user;
  bool _loading = false;
  List<DocumentSnapshot> restaurants;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    _getData();
  }

  Future _getData() async {
    setState(() => _loading = true);
    dynamic _result = await DatabaseService().getPlacesOfUser(
        DatabaseService.RESTAURANT);
    if (_result == null) {
      print("something went wrong");
    } else if (_result == 'empty') {
      restaurants = null;
    } else {
      restaurants = _result;
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Restaurants"),
      ),
      body: _loading ? WidgetUtils.loadingWidget :
      restaurants == null ? Center(
        child: Text("You don't have any place yet, go ahead and add one"),) :
      ListView.builder(
          itemCount: restaurants.length,
          itemBuilder: (context, i){
            return ListTile(
              title: Text(restaurants[i].data["name"]),
              subtitle: Text(restaurants[i].data["desc"]),
            );
          }
      ),
    );
  }
}
