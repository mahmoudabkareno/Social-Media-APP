import 'package:flutter/material.dart';


cirularProgress(){
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 11),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(
          Colors.lightGreen),
    ),
  );
}

linearProgress(){
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.only(top: 11),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(
          Colors.lightGreen),
    ),
  );
}