import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instgram/widgets/HeaderWidget.dart';

class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  String userName;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, strTitle: 'Stings', disableBackButton: true),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 25),
                  child: Center(
                      child: Text('Set Up A UserName', style: TextStyle(fontSize: 25),)
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        validator: (v){
                          if( v.trim().length<5 || v.isEmpty){
                            return 'User Name Should Be more than 5';
                          }else if(v.trim().length>15){
                            return 'User Name Should Be less than 15';
                          }else {
                            return null;
                          }
                        },
                        onSaved: (v) => userName = v,
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          border: UnderlineInputBorder(),
                          labelText: 'User Name',
                          labelStyle: TextStyle(
                            fontSize: 17
                          ),
                          hintText: 'Enter you user name',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                Builder(
                  builder: (context) => GestureDetector(
                    onTap: submitUserName,
                    child: Container(
                      height: 55,
                      width: 350,
                      decoration: BoxDecoration(
                        color: Colors.lightBlueAccent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                            'Proceed',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  submitUserName() {
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      Timer(Duration(seconds: 4), (){
        Navigator.pop(context , userName);
      });
    }
  }
}
