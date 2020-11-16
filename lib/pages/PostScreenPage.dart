import 'package:flutter/material.dart';
import 'package:instgram/pages/HomePage.dart';
import 'package:instgram/widgets/HeaderWidget.dart';
import 'package:instgram/widgets/PostWidget.dart';
import 'package:instgram/widgets/ProgressWidget.dart';

class PostScreenPage extends StatefulWidget {
  final String userId;
  final String postId;

  PostScreenPage({
    this.postId,
    this.userId,
  });
  @override
  _PostScreenPageState createState() => _PostScreenPageState();
}

class _PostScreenPageState extends State<PostScreenPage> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postsReference.doc(widget.userId).collection('usersPosts').doc(widget.postId).get(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return cirularProgress();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context,strTitle: post.userName),
            body: ListView(
              children: [
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
