import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instgram/Models/User.dart';
import 'package:instgram/pages/NotificationPage.dart';
import 'package:instgram/pages/ProfilePage.dart';
import 'package:instgram/pages/SearchPage.dart';
import 'package:instgram/pages/TimeLinePage.dart';
import 'package:instgram/pages/UploadPage.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

User currentUser = User();

final usersReference = FirebaseFirestore.instance.collection('Users');

final postsReference = FirebaseFirestore.instance.collection('Posts');

final activityFeedReference = FirebaseFirestore.instance.collection('Feed');

final commentReference = FirebaseFirestore.instance.collection('Comments');

final followingReference = FirebaseFirestore.instance.collection('Following');

final followersReference = FirebaseFirestore.instance.collection('Followers');

final timeLineReference = FirebaseFirestore.instance.collection('TimeLine');

final Reference ref = FirebaseStorage.instance.ref().child("Post Picture");

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool isSignedIn = false;

  PageController pageController;

  int getPageIndex = 0;

  final DateTime timestamp = DateTime.now();



  @override
  void dispose(){

    super.dispose();

    pageController.dispose();

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    pageController = PageController();

    googleSignIn.onCurrentUserChanged.listen((googleSignInAccount) {
      controlSignIn(googleSignInAccount);
    }, onError: (googleError){
      print('Error message:' + googleError);
    });
    googleSignIn.signInSilently(suppressErrors: false).then((googleSignInAccount) {
      controlSignIn(googleSignInAccount);
    }).catchError((googleError){
      print('Error message:' + googleError.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
// build function
    if(isSignedIn){
      return homeScreen();
    }else{
      return signInScreen();
    }
  }

  Scaffold signInScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Theme.of(context).accentColor, Theme.of(context).primaryColor]
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                'Instagram',
              style: TextStyle(
                fontSize: 65,
                color: Colors.white,
                fontFamily: 'Pacifico',
              ),
            ),
            GestureDetector(
              onTap: logInUser,
              child: Container(
                width: 280,
                height: 70,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/google.png'),
                    fit: BoxFit.cover
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
   logInUser() {
    googleSignIn.signIn();
  }

  logOutUser(){
    googleSignIn.signOut();
  }

  controlSignIn(GoogleSignInAccount googleSignInAccount) async {
    if(googleSignInAccount != null){
      await saveUserInformationToFireStore();
      setState(() {
        isSignedIn = true;
      });
      configurationRealTimePushNotification();
    }else{
      setState(() {
        isSignedIn = false;
      });
    }
  }

  Scaffold homeScreen() {
    return Scaffold(
      body: PageView(
        children: [
          TimeLinePage(getCurrentUser: currentUser,),
          SearchPage(),
          UploadPage(getCurrentUser: currentUser,),
          NotificationPage(),
          ProfilePage(userProfileId: currentUser.uId)
        ],
        controller: pageController,
        onPageChanged: whenPageChanges,
        physics: NeverScrollableScrollPhysics(),
      ),
     bottomNavigationBar: CupertinoTabBar(
       currentIndex: getPageIndex,
       onTap: onTapChangePage,
       activeColor: Colors.white,
       inactiveColor: Colors.blueGrey,
       backgroundColor: Theme.of(context).accentColor,
       items: [
         BottomNavigationBarItem(icon: Icon(Icons.home)),
         BottomNavigationBarItem(icon: Icon(Icons.search)),
         BottomNavigationBarItem(icon: Icon(Icons.photo_camera,size: 36,)),
         BottomNavigationBarItem(icon: Icon(Icons.favorite)),
         BottomNavigationBarItem(icon: Icon(Icons.person)),
       ],
     ),
    );
  }

  whenPageChanges(int pageIndex) {
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  onTapChangePage(int pageIndex) {
    pageController.animateToPage(
        pageIndex,
        duration: Duration(
          microseconds: 400
        ),
        curve: Curves.bounceInOut
    );
  }

  saveUserInformationToFireStore() async{
    final GoogleSignInAccount googleCurrentUser = googleSignIn.currentUser;

    DocumentSnapshot documentSnapshot = await usersReference.doc(googleCurrentUser.id).get();

    if(!documentSnapshot.exists) {

      final userName = await Navigator.pushNamed(context, '/CreateAccountPage');

      usersReference.doc(googleCurrentUser.id).set({
        'uId': googleCurrentUser.id,
        'email': googleCurrentUser.email,
        'userName': userName,
        'url': googleCurrentUser.photoUrl,
        'profileName': googleCurrentUser.displayName,
        'bio': '',
        'timestamp':timestamp,
      });
      await followersReference.doc(googleCurrentUser.id).collection('userFollowers')
          .doc(googleCurrentUser.id).set({

      });
      documentSnapshot = await usersReference.doc(googleCurrentUser.id).get();
      print(documentSnapshot);
    }
    currentUser = User.fromDocument(documentSnapshot);
  }

  configurationRealTimePushNotification() {
    final GoogleSignInAccount googleUser = googleSignIn.currentUser;
    if(Platform.isIOS){
      getIOsPermissions();
    }
    _fireBaseMessaging.getToken().then((value) {
      usersReference.doc(googleUser.id).update({
        'androidNotificationToken': value
      });
    });
    _fireBaseMessaging.configure(
      onMessage: (Map<String, dynamic> msg) async{
        final String recipienId = msg['data']['recipient'];
        final String body = msg['Notification']['body'];
        if(recipienId == googleUser.id){
          Scaffold.of(context).showBottomSheet((context) => SnackBar(
            backgroundColor: Colors.grey,
            content: Text(
                body,
              style: TextStyle(
                color: Colors.black
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ));
        }
      }
    );
  }
  FirebaseMessaging _fireBaseMessaging = FirebaseMessaging();
  getIOsPermissions() {
    _fireBaseMessaging.requestNotificationPermissions(IosNotificationSettings(alert: true , sound: true,badge: true));
    _fireBaseMessaging.onIosSettingsRegistered.listen((event) {
      print('Settings Registerd: $event');
    });
  }
}
