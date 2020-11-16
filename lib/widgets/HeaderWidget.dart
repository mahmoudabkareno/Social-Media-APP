import 'package:flutter/material.dart';

AppBar header(BuildContext context , {bool isAppTitle = false, String strTitle, disableBackButton = false}){
  return AppBar(
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    automaticallyImplyLeading: disableBackButton? false : true,
    title:  Text(
      isAppTitle? 'Instagram': strTitle,
      style: TextStyle(
        fontSize: isAppTitle? 35 : 23,
        color: Colors.white,
        fontFamily: isAppTitle? 'Pacifico': '',
      ),
      overflow: TextOverflow.ellipsis,
    ),
    backgroundColor: Theme.of(context).accentColor,
  );
}