import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nearby_places/pages/places/dish_detail.dart';
import 'package:nearby_places/services/database.dart';
import 'package:nearby_places/services/widget_utils.dart';

class PlaceDetails extends StatefulWidget {
  final DocumentReference placeRef;

  PlaceDetails({this.placeRef});

  @override
  _PlaceDetailsState createState() => _PlaceDetailsState();
}

class _PlaceDetailsState extends State<PlaceDetails> {
  DatabaseService _databaseService = DatabaseService();
  String _placeType;
  bool _loading = false;
  Map<String, dynamic> data = {};

  @override
  void initState() {
    super.initState();
    _placeType = widget.placeRef.parent().path;
    _getData();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future _getData() async {
    setState(() => _loading = true);
    dynamic _result = await _databaseService.getRestDetails(widget.placeRef);
    if (_result != null) {
      data = _result;
    } else {
      print("something went wrong");
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    Widget loadingWidget = WidgetUtils.loadingWidget;

    int items = data["resDishes"] == null ? 0 : data["resDishes"].documents.length;
    Widget mainBody = data == {}
        ? Center(
            child: Text("Something went wrong"),
          )
        : Container(
            child: ListView.builder(
              itemCount: items + 1,
              itemBuilder: createDishTile,
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: Text("Restaurant Details"),
      ),
      body: _loading ? loadingWidget : mainBody,
    );
  }



  Widget createDishTile(BuildContext context, int index) {
    if (index == 0) {
      Widget rating = WidgetUtils.starRating(data["resData"].data["rating"],
          data["resData"].data["#ratings"], 20.0);

      return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Text(data["resData"].data["name"]),
              subtitle: Text(data["resData"].data["desc"]),
              trailing: Text("open"),
            ),
            Container(margin: EdgeInsets.fromLTRB(20, 0, 0, 10), child: rating),
          ],
        ),
      );
    } else {
      index -= 1;
      var ref = data["resDishes"].documents.elementAt(index);
      return ListTile(
        title: Text(ref.data["name"]),
        subtitle: Text(ref.data["desc"]),
        trailing: FittedBox(
          fit: BoxFit.cover,
          child: WidgetUtils.starRating(ref.data["rating"], ref.data["#ratings"], 15.0),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DishDetail(dishRef : ref.reference),
              ));
        },
      );
    }
  }
}
