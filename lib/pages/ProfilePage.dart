import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instgram/Models/User.dart';
import 'package:instgram/pages/HomePage.dart';
import 'package:instgram/widgets/HeaderWidget.dart';
import 'package:instgram/widgets/PostTileWidget.dart';
import 'package:instgram/widgets/PostWidget.dart';
import 'package:instgram/widgets/ProgressWidget.dart';

import 'EditProfilePage.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;
  ProfilePage({
    this.userProfileId
  });
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final String currentOnLineUserId = currentUser?.uId;

  bool loading = false;

  int countPost = 0;

  List<Post> postList = [];

  String postOrentation = 'grid';

  int countfollowers = 0;
  int countfollowings = 0;
  bool folloeing = false;

  @override
  void initState() {
    getAllProfilePosts();
    getAlFollowers();
    getAllFollowings();
    chechIfAleardyFollowing();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,strTitle: 'Profile'),
      body: ListView(
        children: [
          createProfilTopView(),
          Divider(),
          createListAntGridPOstOrientation(),
          Divider(height: 0.0,),
          displayProfilePosts(),
        ],
      ),
    );
  }

  createProfilTopView() {
    return FutureBuilder(
      future: usersReference.doc(widget.userProfileId).get(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return cirularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.url),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            createColumns('posts', countPost),
                            createColumns('followers', countfollowers),
                            createColumns('following', countfollowings),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            createButton(),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  '@${user.userName}',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  user.profileName,
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 3),
                child: Text(
                  user.bio,
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.white54,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Column createColumns(String title, int count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
            count.toString(),
          style: TextStyle(
            fontSize: 19,
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 6),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
    );
  }

  createButton() {
    bool profile = currentOnLineUserId == widget.userProfileId;
    if(profile){
      return createButtonTitleAndFunction(title: 'Edit Profile', performFunction: editUsterProfile,);
    }else if(folloeing){
      return createButtonTitleAndFunction(title: 'UnFollow', performFunction: controlUnfollowUser,);
    }else if(!folloeing){
      return createButtonTitleAndFunction(title: 'Follow', performFunction: controlfollowUser,);
    }
  }

  Container createButtonTitleAndFunction({String title, Function performFunction}) {
    return Container(
      padding: EdgeInsets.only(top: 3),
      child: FlatButton(
        onPressed: performFunction,
        child: Container(
          width: MediaQuery.of(context).size.width*.6,
          height: 25,
          child: Text(
            title,
            style: TextStyle(
                color: folloeing ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: folloeing? Colors.white30 : Colors.black,
            border: Border.all(color: folloeing? Colors.white30 : Colors.grey),
            borderRadius: BorderRadius.circular(7)
          ),
        ),
      ),
    );
  }
  editUsterProfile(){
    Navigator.push(context,MaterialPageRoute(builder: (context) => EditProfilePage(currentInlineUserId: currentOnLineUserId)));
  }

  displayProfilePosts() {
    if(loading){
      return cirularProgress();
    }
    else if(postList.isEmpty){
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(25),
              child: Icon(
                Icons.photo_library,
                color: Colors.grey,
                size: 150,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 21),
              child: Text(
                'No Posts Founded',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.bold
                ),
              ),
            )
          ],
        ),
      );
    }
    else if(postOrentation == 'grid'){
      List<GridTile> gridTiles = [];
      postList.forEach((eachPost) {
        gridTiles.add(GridTile(
          child: PostTile(eachPost),
        ));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    }
    else if(postOrentation == 'list'){
      return Column(
        children: postList,
      );
    }
  }

  getAllProfilePosts() async{
    setState(() {
      loading = true;
    });
    QuerySnapshot querySnapshot = await postsReference.doc(widget.userProfileId)
    .collection('usersPosts').orderBy('timestamp', descending: true).get();
    setState(() {
      loading = false;
      countPost = querySnapshot.docs.length;
      postList = querySnapshot.docs.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
    });
  }

  createListAntGridPOstOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () => setOreintation('grid'),
          icon: Icon(Icons.grid_on),
          color: postOrentation == 'grid'? Theme.of(context).primaryColor : Colors.grey,
        ),
        IconButton(
          onPressed: () => setOreintation('list'),
          icon: Icon(Icons.list),
          color: postOrentation == 'list'? Theme.of(context).primaryColor : Colors.grey,
        )
      ],
    );
  }

  setOreintation(String o) {
    setState(() {
      this.postOrentation = o;
    });
  }

  controlUnfollowUser() {
    setState(() {
      folloeing = false;
    });
    followersReference.doc(widget.userProfileId).collection('userFollowers').doc(currentOnLineUserId).get()
        .then((document){
          if(document.exists){
            document.reference.delete();
          }
    });
    followingReference.doc(currentOnLineUserId).collection('userFollowing').doc(widget.userProfileId).get()
        .then((document){
      if(document.exists){
        document.reference.delete();
      }
    });
    activityFeedReference.doc(widget.userProfileId).collection('FeedItems').doc(currentOnLineUserId).get().then((value){
      if(value.exists){
        value.reference.delete();
      }
    });
  }

  controlfollowUser(){
    setState(() {
      folloeing = true;
    });
    followersReference.doc(widget.userProfileId).collection('userFollowers').doc(currentOnLineUserId).set({

    });
    followingReference.doc(currentOnLineUserId).collection('userFollowing').doc(widget.userProfileId).set({

    });
    activityFeedReference.doc(widget.userProfileId).collection('FeedItems').doc(currentOnLineUserId).set({
      'type' : 'follow',
       'ownerId' : widget.userProfileId,
      'username' : currentUser.userName,
      'timestamp' : DateTime.now(),
      'userProfileImaage' : currentUser.url,
      'userId' : currentOnLineUserId,
    });
  }

  getAlFollowers() async{
    QuerySnapshot querySnapshot = await followersReference.doc(widget.userProfileId)
        .collection('userFollowers').get();
    setState(() {
      countfollowers = querySnapshot.docs.length;
    });
  }

  getAllFollowings() async{
    QuerySnapshot querySnapshot = await followingReference.doc(widget.userProfileId)
        .collection('userFollowing').get();
    setState(() {
      countfollowings = querySnapshot.docs.length;
    });
  }

  chechIfAleardyFollowing() async{
    DocumentSnapshot documentSnapshot = await followersReference.doc(widget.userProfileId)
        .collection('userFollowers').doc(currentOnLineUserId).get();
    setState(() {
      folloeing = documentSnapshot.exists;
    });
  }

}
