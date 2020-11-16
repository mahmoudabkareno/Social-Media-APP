import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instgram/Models/User.dart';
import 'package:instgram/pages/HomePage.dart';
import 'package:instgram/widgets/ProgressWidget.dart';

class EditProfilePage extends StatefulWidget {
  final String currentInlineUserId;

  EditProfilePage({
    this.currentInlineUserId
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController profileNametextEditingController = TextEditingController();
  TextEditingController biotextEditingController = TextEditingController();

  bool loading = false;
  User user;
  bool _bioValid = true;
  bool _profileNameValid = true;

  @override
  void dispose(){
    super.dispose();
    profileNametextEditingController.dispose();
    biotextEditingController.dispose();
  }

  @override
  void initState() {
    getAndDisplayUserInformation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
                Icons.done,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      body: loading? cirularProgress() : ListView(
        children: [
          Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 14,bottom: 8),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: CachedNetworkImageProvider(user.url),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                     children: [
                       createProfileNameTextField(),
                       createBioTextField()
                     ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 25,left: 54,right: 52),
                  child: RaisedButton(
                    child: Text(
                      '   Update  ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18
                      ),
                    ),
                    onPressed: updateUserInfo,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8,left: 54,right: 52),
                  child: RaisedButton(
                    child: Text(
                      'LogOut',
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 18
                      ),
                    ),
                    onPressed: logUotUser,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Column createProfileNameTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            'Profile Name',
            style: TextStyle(
              color: Colors.grey
            ),
          ),
        ),
        TextField(
          style: TextStyle(
            color: Colors.white
          ),
          controller: profileNametextEditingController,
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey
              )
            ),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white
                )
            ),
            hintStyle: TextStyle(
              color: Colors.grey
            ),
            hintText: 'Write Profile Name...',
            errorText: _profileNameValid? null : 'profileName is very short',
          ),
        )
      ],
    );
  }

  Column createBioTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text(
            'Bio',
            style: TextStyle(
                color: Colors.grey
            ),
          ),
        ),
        TextField(
          style: TextStyle(
              color: Colors.white
          ),
          controller: biotextEditingController,
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.grey
                )
            ),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white
                )
            ),
            hintStyle: TextStyle(
                color: Colors.grey
            ),
            hintText: 'Write Bio...',
            errorText: _bioValid? null : 'Bio is very Long',
          ),
        )
      ],
    );
  }

  updateUserInfo() {
    setState(() {
      profileNametextEditingController.text.trim().length <3 || profileNametextEditingController.text.trim().isEmpty?
          _profileNameValid = false: _profileNameValid = true;
      biotextEditingController.text.trim().length > 150 ? _profileNameValid = false: _profileNameValid = true;
    });
    if(_bioValid && _profileNameValid){
      usersReference.doc(widget.currentInlineUserId).update(
        {
         'profileName' : profileNametextEditingController.text,
         'bio' : biotextEditingController.text,
        }
      );
    }
  }

  getAndDisplayUserInformation() async{
    setState(() {
      loading = true;
    });
    DocumentSnapshot documentSnapshot = await usersReference.doc(widget.currentInlineUserId).get();
    user = User.fromDocument(documentSnapshot);
    profileNametextEditingController.text = user.profileName;
    biotextEditingController.text = user.bio;
    setState(() {
      loading = false;
    });
  }

  logUotUser() async{
    await googleSignIn.signOut();
    Navigator.pushNamed(context, '/HomePage');
  }
}
