import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instgram/pages/HomePage.dart';
import 'package:instgram/widgets/HeaderWidget.dart';
import 'package:instgram/widgets/ProgressWidget.dart';
import 'package:timeago/timeago.dart' as tAgo;

import 'ProfilePage.dart';

class CommentsPage extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postImageUrl;

  CommentsPage({
    this.postId,
    this.postImageUrl,
    this.postOwnerId
  });

  @override
  _CommentsPageState createState() => _CommentsPageState(
      postId: postId,
      postOwnerId : postOwnerId,
      postImageUrl: postImageUrl,
  );
}

class _CommentsPageState extends State<CommentsPage> {
  final String postId;
  final String postOwnerId;
  final String postImageUrl;
  TextEditingController commentTextEditingController = TextEditingController();

  @override
  void dipose(){
    super.dispose();
    commentTextEditingController.dispose();
  }

  _CommentsPageState({
    this.postId,
    this.postImageUrl,
    this.postOwnerId
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: 'Comments'),
      body: Column(
        children: [
          Expanded(
            child: retrieveComments(),
          ),
          Divider(),
          ListTile(
            trailing: OutlineButton(
              onPressed: saveComment,
              child: Icon(
                Icons.publish,
                size: 25,
                color: Colors.grey,
              )
            ),
            title: TextFormField(
             controller: commentTextEditingController,
             decoration: InputDecoration(
               labelText: 'write your comment',
               labelStyle: TextStyle(
                 color: Colors.white
               ),
               enabledBorder: UnderlineInputBorder(
                 borderSide: BorderSide(
                   color: Colors.grey
                 ),
               ),
               focusedBorder: UnderlineInputBorder(
                 borderSide: BorderSide(
                     color: Colors.white
                 ),
               ),
             ),
              style: TextStyle(
                color: Colors.white
              ),
            ),
          ),
        ],
      ),
    );
  }

  retrieveComments() {
    return StreamBuilder<QuerySnapshot>(
      stream: commentReference.doc(postId).collection('Comments').orderBy('timestamp', descending: false).snapshots(),
      builder: (context , AsyncSnapshot<QuerySnapshot> querysnapshots){
        if(querysnapshots.hasData == null){
          return cirularProgress();
        }
        List<Comment> comments = [];
        querysnapshots.data.docs.forEach((document){
          comments.add(Comment.fromDocument(document));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  saveComment() {
    commentReference.doc(postId).collection('Comments').add({
      'userName' : currentUser.userName,
      'comment' : commentTextEditingController.text,
      'timestamp' : timestamp,
      'url' : currentUser.url,
      'userId' : currentUser.uId
    });
    bool isNotPostOwner = postOwnerId != currentUser.uId;
    if(isNotPostOwner){
      activityFeedReference.doc(postOwnerId).collection('FeedItems').add({
        'type' : 'comment',
        'commentData' : commentTextEditingController.text,
        'postId' : postId,
        'userId' : currentUser.uId,
        'userName' : currentUser.userName,
        'userProfileImage' : currentUser.url,
        'url' : postImageUrl,
        'timestamp' : timestamp,
      });
    }
    commentTextEditingController.clear();
  }
  final DateTime timestamp = DateTime.now();
}


class Comment extends StatelessWidget {
  final String userName;
  final String comnent;
  final String userId;
  final Timestamp timestamp;
  final String url;

  Comment({
    this.userName,
    this.timestamp,
    this.url,
    this.userId,
    this.comnent
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Container(
        color: Colors.white70,
        child: Column(
          children: [
            ListTile(
              title:Text(
                  userName+':'+comnent,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black
                  )
              ),
              trailing: CircleAvatar(
                radius: 45,
                backgroundImage: CachedNetworkImageProvider(url),
              ),
              subtitle: Text(
                tAgo.format(timestamp.toDate()),
                style: TextStyle(
                  color: Colors.black
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  factory Comment.fromDocument(DocumentSnapshot document) {
    return Comment(
      userName : document['userName'],
      timestamp : document['timestamp'],
      url : document['url'],
      userId : document['userId'],
      comnent : document['comment'],
    );
  }

  displayUserProfile(BuildContext context, {String profileId}) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return ProfilePage(userProfileId: profileId,);
        }
    ));
  }
}

