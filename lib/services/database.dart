import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:geohash/geohash.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearby_places/services/auth.dart';
import 'package:nearby_places/services/geohash.dart';

class DatabaseService {
  static const String RESTAURANT = "restaurants";
  static const String DISHES = "dishes";
  static const String RATINGS = "ratings";
  final FirebaseUser user = AuthService.user;

  // collection reference
  final Firestore _db = Firestore.instance;
  final CollectionReference _users = Firestore.instance.collection('users');
  final CollectionReference _restaurants =
      Firestore.instance.collection('restaurants');

  // get stream

  Future updateUserData({String name}) async {
    print(_users);
    print(_users.document(user.uid));
    return await _users.document(user.uid).setData({
      'name': name,
    });
  }

  Future addRestaurant({String name, String desc, LatLng pos}) async {
    DocumentReference newRes = await _restaurants.add({
      "owner": user.uid,
      "name": name,
      "desc": desc,
      "geohash": Geohash.encode(pos.latitude, pos.longitude),
      "position": GeoPoint(pos.latitude, pos.longitude),
    });

    return await _users.document(user.uid).updateData({
        'restaurants' : FieldValue.arrayUnion([newRes.documentID]),
    });
  }

  Future getRestaurants({String startHash, String endHash}) async {
    try {
      var res = await _restaurants
          .where('geohash',
          isGreaterThanOrEqualTo: startHash, isLessThan: endHash)
          .getDocuments();
//    res.documents.forEach((element) {
//      print(element.data["name"]);
//    });
      return res;
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  Future getRestDetails(DocumentReference resRef) async{
    try {
      DocumentSnapshot resData = await _db.document(resRef.path).get();
      var resDishes = await _db.document(resRef.path)
          .collection(DISHES)
          .getDocuments();
      return {
        "resData" : resData,
        "resDishes" : resDishes,
      };
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  Future getDishDetails(DocumentReference dishRef) async{
    try {
      DocumentSnapshot dishData = await _db.document(dishRef.path).get();
      dynamic reviews = await getReviewsOf(dishRef, 10);
      return {
        "dishData" : dishData,
        "reviews" : reviews,
      };
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  Future getReviewsOf(DocumentReference ref, int limit, [startAfter]) async{
    Query query = _db.document(ref.path)
        .collection(RATINGS)
        .limit(limit);
    try{
      QuerySnapshot res;
      if(startAfter == null) {
        res = await query.getDocuments();
      }else{
        res = await query.startAfter(startAfter).getDocuments();
      }
      return res.documents.toList();
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  Future getPlacesOfUser(String type) async{
    try{
      DocumentSnapshot userRests = await _users.document(user.uid).get();
      int count = userRests.data[RESTAURANT].length;
      if(count == 0){
        return "empty";
      }else{
        List<DocumentSnapshot> restaurants = [];
        for(var rid in userRests.data[RESTAURANT]){
//          print(rid);
          restaurants.add(await _restaurants.document(rid).get());
        }
        return restaurants;
      }
    }catch(e){
      print(e.toString());
      return null;
    }
  }

}
