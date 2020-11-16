import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instgram/pages/HomePage.dart';
import 'package:instgram/pages/PostScreenPage.dart';
import 'package:instgram/widgets/HeaderWidget.dart';
import 'package:instgram/pages/ProfilePage.dart';
import 'package:instgram/widgets/ProgressWidget.dart';
import 'package:timeago/timeago.dart' as TAgo;


class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,strTitle: 'Notification'),
      body: Container(
      child: FutureBuilder(
        future: retrieNotification(),
        builder: (context , snapshot){
          if(!snapshot.hasData){
            return cirularProgress();
          }
          return ListView(
            children: snapshot.data,
          );
        },
      ),
      ),
    );
  }

  retrieNotification() async{
    QuerySnapshot querySnapshot = await activityFeedReference.doc(currentUser.uId)
        .collection('FeedItems').orderBy('timestamp', descending: true).limit(100).get();
    List<NotificationsItem> notificationsTem = [];
    querySnapshot.docs.forEach((document) {
      notificationsTem.add(NotificationsItem.fromDocument(document));
    });
    return notificationsTem;
  }
}

class NotificationsItem extends StatelessWidget {
  final String userName;
  final String type;
  final String commentData;
  final String postId;
  final String userId;
  final String userProfileImage;
  final String url;
  final Timestamp timestamp;

  NotificationsItem({
    this.userName,
    this.timestamp,
    this.url,
    this.postId,
    this.userId,
    this.commentData,
    this.type,
    this.userProfileImage
  });


  @override
  Widget build(BuildContext context) {
    ConfigureMerdiaPreview(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 3),
      child: Container(
        color: Colors.white70,
        child: ListTile(
          title: GestureDetector(
            onTap: displayUserProfile(context, profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black
                  ),
                  children: [
                    TextSpan(
                      text: userName,
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    TextSpan(
                      text: '$notificationItemText'
                    )
                  ]
              ),
            ),
          ),
          leading: CircleAvatar(
            radius: 45,
            backgroundImage: CachedNetworkImageProvider(userProfileImage),
          ),
          subtitle: Text(
            TAgo.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: merdiaPreview,
        ),
      ),
    );
  }

  factory NotificationsItem.fromDocument(DocumentSnapshot document){
    return NotificationsItem(
      userName: document['userName'],
      timestamp: document['timestamp'],
      url: document['url'],
      postId: document['postId'],
      userId: document['userId'],
      commentData: document['commentData'],
      type: document['type'],
      userProfileImage: document['userProfileImage'],
    );
  }

  displayUserProfile(BuildContext context, {String profileId}) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return ProfilePage(userProfileId: profileId,);
        }
    ));
  }

  ConfigureMerdiaPreview(BuildContext context) {
    if(type == 'comment' || type == 'like'){
      merdiaPreview = GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(
            builder: (context){
              return PostScreenPage(postId: postId,userId: userId,);
            }
          ));
        },
        child: Container(
          height: 55,
          width: 45,
          child: AspectRatio(
            aspectRatio: 16/7,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(url),
                )
              ),
            ),
          ),
        ),
      );
    }else{
      merdiaPreview = Text('');
    }
    if(type == 'like'){
      notificationItemText = 'Liked your Post';
    }else
    if(type == 'comment'){
      notificationItemText = 'comment in your Post: $commentData';
    }else
    if(type == 'follow'){
      notificationItemText = 'start following you.. \nyou can comment and see his posts';
    }else{
      notificationItemText = 'Error, Unknown Type = $type';
    }
  }
}

String notificationItemText;
Widget merdiaPreview;
