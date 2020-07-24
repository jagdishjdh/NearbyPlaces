import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nearby_places/main.dart';
import 'package:nearby_places/services/database.dart';
import 'package:nearby_places/services/map_utils.dart';
import 'package:nearby_places/services/widget_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class AddPlace extends StatefulWidget {
  @override
  _AddPlaceState createState() => _AddPlaceState();
}

class _AddPlaceState extends State<AddPlace> {
  final _formKey = GlobalKey<FormState>();

  String _name = '', _desc = '';
  LatLng _tapPos;
  CameraPosition _cameraPos = MapUtils().mumbai;
  Set<Marker> _markers = {};
  bool _loading = false;
  String _errMsg = "";

  void _onSingleMapTap(LatLng pos) {
    setState(() {
      _tapPos = pos;
      _markers = {
        Marker(
          markerId: MarkerId("tapped Position"),
          position: pos,
          icon: BitmapDescriptor.defaultMarker,
        )
      };
    });
  }

  Future<void> _onSave() async {
    if (_formKey.currentState.validate() && _tapPos != null) {
      setState(() { _loading = true; _errMsg=""; });
      await DatabaseService().addRestaurant(name: _name, desc: _desc, pos: _tapPos);
      setState(() {_loading = false;});
      Fluttertoast.showToast(
        msg: "Restaurant \"$_name\" saved",
        backgroundColor: Colors.grey,
        textColor: Colors.black,
      );
    } else if(_tapPos == null) {
      setState(() { _errMsg = "Select a location on map"; });
    }else{
    }
  }

  @override
  Widget build(BuildContext context) {

    Widget loadingWidget = WidgetUtils.loadingWidget;

    Widget mainBody = SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Text(
                "Name of Restaurant",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              TextFormField(
                onChanged: (val) => _name = val,
                textAlign: TextAlign.center,
                validator: (val) =>
                val.length > 0 ? null : "Enter some name",
                decoration: InputDecoration(
                  hintText: "Name of Restaurant",
                  filled: true,
                ),
              ),


              SizedBox(height: 10),
              Text(
                "Description",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              TextFormField(
                onChanged: (val) => _desc = val,
                textAlign: TextAlign.center,
                validator: (val) =>
                val.length > 0 ? null : "Enter some text",
                decoration: InputDecoration(
                  hintText: "description",
                  filled: true,
                ),
              ),


              SizedBox(height: 10),
              Text(
                "Choose Location on map",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(
                height: 400,
                child: GoogleMap(
                  onMapCreated: (controller) {},
                  initialCameraPosition: _cameraPos,
                  onTap: (pos) {
                    _onSingleMapTap(pos);
                  },
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
              Text(
                _errMsg,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Add new Place"),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.save),
            label: Text("Save"),
            onPressed: _loading ? null : _onSave,
          )
        ],
      ),
      body: _loading ? loadingWidget : mainBody,
    );
  }
}
