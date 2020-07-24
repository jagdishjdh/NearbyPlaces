import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class WidgetUtils {
  static final Widget loadingWidget = Center(
    child: Container(
      color: Colors.grey[300],
      width: 70.0,
      height: 70.0,
      child: new Padding(
          padding: const EdgeInsets.all(5.0),
          child: new Center(child: new CircularProgressIndicator())),
    ),
  );

   static Widget starRating(rating, numRatings, size) {
    return (rating == null)
        ? Text("no rating available")
        : Row(
      children: <Widget>[
        SmoothStarRating(
          allowHalfRating: true,
          starCount: 5,
          rating: rating.toDouble(),
          size: size,
          isReadOnly: true,
          color: Colors.orange,
        ),
        Text(" $rating ($numRatings)"),
      ],
    );
  }
}
