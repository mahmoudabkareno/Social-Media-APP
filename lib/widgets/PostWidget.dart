import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instgram/Models/User.dart';
import 'package:instgram/pages/CommentsPage.dart';
import 'package:instgram/pages/HomePage.dart';
import 'package:instgram/pages/ProfilePage.dart';
import 'package:instgram/widgets/ProgressWidget.dart';

class Post extends StatefulWidget {
  final String postId;
  final dynamic likes;
  final String postOwner;
  final String userName;
  final String description;
  final String location;
  final String url;

  Post({
    this.postId,
    this.likes,
    this.postOwner,
    this.userName,
    this.description,
    this.location,
    this.url,
  });

  factory Post.fromDocument(DocumentSnapshot documentSnapshot){
    return Post(
      postId : documentSnapshot['postId'],
      likes : documentSnapshot['likes'],
      postOwner : documentSnapshot['postOwner'],
      userName : documentSnapshot['userName'],
      description : documentSnapshot['description'],
      location : documentSnapshot['location'],
      url : documentSnapshot['url'],
    );
  }
  int getToatalNumberLikes(likes){
    if(likes == null){
      return 0;
    }
    int count = 0;
    likes.values.forEach((eachvalue){
     if(eachvalue == true){
       count++;
     }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    likes : this.likes,
    postOwner : this.postOwner,
    userName : this.userName,
    description : this.description,
    location : this.location,
    url : this.url,
    likeCount: getToatalNumberLikes(this.likes),
  );
}

class _PostState extends State<Post> {
  final String postId;
  final DateTime timestamp = DateTime.now();
  Map likes;
  final String postOwner;
  final String userName;
  final String description;
  final String location;
  final String url;
  int likeCount;
  bool isLiked ;
  bool shoeHeart = false;
  final String currentOnlineUser = currentUser?.uId;

  _PostState({
    this.postId,
    this.likes,
    this.postOwner,
    this.userName,
    this.description,
    this.location,
    this.url,
    this.likeCount
  });
  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentOnlineUser] == true) ;
    return Padding(
      padding: EdgeInsets.only(bottom: 11),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          createPostHead(),
          createPostPicture(),
          createPostFooter(),
        ],
      ),
    );
  }

  createPostHead() {
    return FutureBuilder(
      future: usersReference.doc(postOwner).get(),
      builder: (context,snapShot){
        if(!snapShot.hasData){
          return cirularProgress();
        }
        User user = User.fromDocument(snapShot.data);
        bool isPostOwner = currentOnlineUser == postOwner;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.url),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: (){
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return ProfilePage(userProfileId: user.uId,);
                    }
                ));
            },
            child: Text(
              user.userName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
          ),
          subtitle: Text(
            location,
            style: TextStyle(
                color: Colors.grey
            ),
          ),
          trailing: isPostOwner? IconButton(
            icon: Icon(
                Icons.more_vert,
              color: Colors.white,
            ),
            onPressed: () => controllPostDelete(context),
          ) : Text('data'),
        );
      },
    );
  }

  createPostPicture() {
    return GestureDetector(
      onDoubleTap: () => controlUserLikePost(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(url),
          shoeHeart? Icon(Icons.favorite, color: Colors.pink,size: 90,) : Text(''),
        ],
      ),
    );
  }

  createPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment:  MainAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: 40, left: 20),),
            GestureDetector(
              onTap: () => controlUserLikePost(),
              child: Icon(
                isLiked? Icons.favorite : Icons.favorite_border,
                size: 30,
                color: Colors.pink,
              ),
            ),
            Padding(padding: EdgeInsets.only(right: 20),),
            GestureDetector(
              onTap: () => displayComments(context,postId: postId, postOwner: postOwner , url: url),
              child: Icon(
                  Icons.comment,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                '$likeCount likes',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(
                '$userName   ',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            Expanded(
              child: Text(
                description,
                style: TextStyle(
                  color: Colors.white
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  controlUserLikePost() {
    bool _like = likes[currentOnlineUser] == true;
    if(_like){
      postsReference.doc(postOwner).collection('usersPosts').doc(postId).update({
        'likes.$currentOnlineUser': false,
      });
      removeLike();
      setState(() {
        likeCount--;
        isLiked = false;
        likes[currentOnlineUser] = false;
      });
    }else if(!_like){
      postsReference.doc(postOwner).collection('usersPosts').doc(postId).update({
        'likes.$currentOnlineUser' : true,
      });
      addLike();
      setState(() {
        likeCount++;
        isLiked = true;
        likes[currentOnlineUser] = true;
        shoeHeart = true;
      });
      Timer(Duration(milliseconds: 800),(){
        setState(() {
          shoeHeart = false;
        });
      });
    }
  }

  removeLike() {
    bool isNotPostOwner = currentOnlineUser != postId;
    if(isNotPostOwner){
      activityFeedReference.doc(postOwner).collection('FeedItems').doc(postId).get().then((document){
        if(document.exists){
          document.reference.delete();
        }
      });
    }
  }

  addLike() {
    bool isNotPostOwner = currentOnlineUser != postOwner;
    if(isNotPostOwner){
      activityFeedReference.doc(postOwner).collection('FeedItems').doc(postId).set({
        'type' : 'like',
        'userName' : currentUser.userName,
        'userId' : currentUser.uId,
        'timestamp' : timestamp,
        'url' : url,
        'postId' : postId,
        'userProfileImage' : currentUser.url,
      });
    }
  }

  displayComments(BuildContext context, {String postId, String postOwner, String url}) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context){
        return CommentsPage(postId: postId, postOwnerId : postOwner, postImageUrl: url);
      }
    ));
  }

  controllPostDelete(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context){
        return SimpleDialog(
          title: Text(
              'what do you want?',
            style: TextStyle(color: Colors.white),
          ),
          children: [
            SimpleDialogOption(
              child: Text(
                'Delete the Post',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
              ),
              onPressed: (){
                Navigator.pop(context);
                removeUserPOsT();
              },
            ),
            SimpleDialogOption(
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                ),
              ),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
          ],
        );
      }
    );
  }

  removeUserPOsT() async{
    postsReference.doc(postOwner).collection('usersPosts').doc(postId).get().then((document){
      if(document.exists){
        document.reference.delete();
      }
    });
    ref.child('post_$postId.jpg').delete();
    QuerySnapshot querySnapshot = await activityFeedReference.doc(postOwner).collection('FeedItems')
    .where('postId',isEqualTo: postId).get();
    querySnapshot.docs.forEach((element) {
      if(element.exists){
        element.reference.delete();
      }
    });
    QuerySnapshot commentQuerySnapshot = await commentReference.doc(postId)
    .collection('Comments').get();
    commentQuerySnapshot.docs.forEach((element) {
      if(element.exists){
        element.reference.delete();
      }
    });
  }
}
