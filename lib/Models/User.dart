import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  final String uId, profileName, userName, url, email, bio;

  User({this.uId, this.profileName, this.url,
    this.userName,this.email,this.bio});

  factory User.fromDocument(DocumentSnapshot documentSnapshot){
    return User(
      uId: documentSnapshot.id,
      email: documentSnapshot['email'],
      userName: documentSnapshot['userName'],
      url: documentSnapshot['url'],
      profileName: documentSnapshot['profileName'],
      bio: documentSnapshot['bio'],
    );
  }
}