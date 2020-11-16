import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instgram/Models/User.dart';
import 'package:instgram/pages/HomePage.dart';
import 'package:instgram/widgets/HeaderWidget.dart';
import 'package:instgram/widgets/PostWidget.dart';
import 'package:instgram/widgets/ProgressWidget.dart';

class TimeLinePage extends StatefulWidget {
  final User getCurrentUser;

  TimeLinePage({this.getCurrentUser});

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  List<Post> posts;
  List<String> followingList = [];

  @override
  void initState() {
    retrieveFollowings();
    retrievTimeline();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,isAppTitle: true),
      body: RefreshIndicator(
        child: createUserTimeLine(),
        onRefresh: (){
          return retrievTimeline();
        },
      ),
    );
  }

  createUserTimeLine(){
    if(posts == null){
      return cirularProgress();
    }else{
      return ListView(
        children: posts,
      );
    }
  }

  retrieveFollowings() async{
    QuerySnapshot querySnapshot = await followingReference.doc(currentUser.uId)
        .collection('userFollowing').get();
    setState(() {
      followingList = querySnapshot.docs.map((document) => document.id).toList();
    });
  }

  retrievTimeline() async {
    QuerySnapshot querySnapshot = await timeLineReference.doc(widget.getCurrentUser.uId)
        .collection('timeLinePosts')
        .orderBy('timestamo', descending: true).get();
    List<Post> allPosts = querySnapshot.docs.map((document) => Post.fromDocument(document)).toList();
    setState(() {
      this.posts = allPosts;
    });
  }
}
