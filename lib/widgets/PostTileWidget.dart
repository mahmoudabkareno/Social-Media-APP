import 'package:flutter/material.dart';
import 'package:instgram/pages/PostScreenPage.dart';
import 'package:instgram/widgets/PostWidget.dart';

class PostTile extends StatelessWidget {

  final Post post;

  PostTile(this.post);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        displayFullPost(context);
      },
      child: Image.network(post.url),
    );
  }

  displayFullPost(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context){
        return PostScreenPage(postId: post.postId, userId: post.postOwner);
      }
    ));
  }

}
