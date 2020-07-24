import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nearby_places/services/database.dart';
import 'package:nearby_places/services/widget_utils.dart';

class DishDetail extends StatefulWidget {
  final DocumentReference dishRef;

  DishDetail({this.dishRef});

  @override
  _DishDetailState createState() => _DishDetailState();
}

class _DishDetailState extends State<DishDetail> {
  DatabaseService _databaseService = DatabaseService();
  bool _loading = false;
  Map<String, dynamic> data = {};
  List<DocumentSnapshot> _reviews;
  dynamic _startAfter;
  int _count;

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
    dynamic _result = await _databaseService.getDishDetails(widget.dishRef);
    if (_result != null) {
      data = _result;
      _reviews = data["reviews"];
      _count = data["#ratings"];
    } else {
      print("something went wrong");
    }
    setState(() => _loading = false);
  }

  List<String> lst = [];
  @override
  Widget build(BuildContext context) {
    Widget loadingWidget = WidgetUtils.loadingWidget;

    return Scaffold(
      appBar: AppBar(
        title: Text("Dish Details"),
      ),
      body: _loading ? loadingWidget : Column(
        children: <Widget>[
          createDishTile(),
          Expanded(
            child: ListView.builder(
              itemCount: _count,
              itemBuilder: createReviewTile,
            ),
          ),
        ],
      ),
    );
  }

  Widget createDishTile() {
    Map<String, dynamic> map = data["dishData"].data;
    return ListTile(
      title: Text(map["name"]),
      subtitle: Text(map["desc"]),
      trailing: FittedBox(
        fit: BoxFit.cover,
        child: WidgetUtils.starRating(map["rating"], map["#ratings"], 20.0),
      ),
    );
  }

  Widget createReviewTile(BuildContext context, int index) {
    if(index < _reviews.length) {
      var review = _reviews[index];
      return ListTile(
        title: WidgetUtils.starRating(review.data["value"], 0.0, 20.0),
        subtitle: Text(review.data["comment"]),
      );
    }
//    Widget a = FutureBuilder(
//      future: this._fetchEntry(index),
//      // ignore: missing_return
//      builder: (context, snapshot) {
//        switch (snapshot.connectionState) {
//          case ConnectionState.none:
//          case ConnectionState.waiting:
//            return Align(
//                alignment: Alignment.center,
//                child: CircularProgressIndicator()
//            );
//          case ConnectionState.done:
//            if (snapshot.hasError) {
//              return Text('Error: ${snapshot.error}');
//            } else {
//
//              var productInfo = snapshot.data;
//
//              return ListTile(
//                leading: Icon(Icons.shopping_cart),
//                title: Text(productInfo['name']),
//                subtitle:
//                Text('price: ${productInfo['price']}USD'),
//              );
//            }
//          case ConnectionState.active:
//             return Text('');
//            break;
//        }
//      },
//    );

  }
}
