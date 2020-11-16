import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instgram/Models/User.dart';
import 'package:instgram/pages/HomePage.dart';
import 'package:instgram/pages/ProfilePage.dart';
import 'package:instgram/widgets/HeaderWidget.dart';
import 'package:instgram/widgets/ProgressWidget.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin<SearchPage>{

  TextEditingController _searchEditingController =TextEditingController();
  Future<QuerySnapshot> futureSearchResilts;


  @override
  void disapose(){
    _searchEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchPageHeader(),
      body: futureSearchResilts == null ? displayNoSearchResultScearn() : displayUserFounScrean(),
    );
  }

  Container displayNoSearchResultScearn(){
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Icon(
              Icons.group,
            color: Colors.grey,
            size: 100,
            ),
            Text(
              'Search Users',
            textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: 60
              ),
            )
          ],
        ),
      ),
    );
  }

  displayUserFounScrean(){
    return FutureBuilder(
      future: futureSearchResilts,
      // ignore: missing_return
      builder: (context , snapshot){
        if(!snapshot.hasData){
          return cirularProgress();
        }
        List<UserReault> searchUserResult = [];
        snapshot.data.docs.forEach((doc){
          User eachUser = User.fromDocument(doc);
          UserReault userReault = UserReault(eachUser);
          searchUserResult.add(userReault);
        });
        return ListView(
          children: searchUserResult,
        );
      },

    );
  }

  AppBar searchPageHeader() {
    return AppBar(
      title: TextFormField(
        controller: _searchEditingController,
        decoration: InputDecoration(
          hintStyle: TextStyle(color: Colors.white),
          hintText: 'Searching...',
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          prefix: Icon(
            Icons.person_pin,
            color: Colors.white,
            size: 28,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            color: Colors.white,
            onPressed: emptyTextFormField,
          )
        ),
        onFieldSubmitted: controlSearching,
        style: TextStyle(
          fontSize: 20,
          color: Colors.white
        ),
      ),
    );
  }

  emptyTextFormField() {
    _searchEditingController.clear();
  }

  controlSearching(String value) {
    Future<QuerySnapshot> allUsers = usersReference.where('profileName', isGreaterThanOrEqualTo: value).get();
    setState(() {
      futureSearchResilts = allUsers ;
    });
  }

  bool get wantKeepAlive => true;
}

class UserReault extends StatelessWidget{
  final User eachUser;

  UserReault(this.eachUser);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.all(3),
      child: Container(
        color: Colors.white38,
        child: Column(
          children: [
            GestureDetector(
              onTap: () => displayUserProfile(context, profileId: eachUser.uId),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.black,
                  backgroundImage: CachedNetworkImageProvider(eachUser.url),
                ),
                title: Text(
                  eachUser.profileName !=null? eachUser.profileName : 'Default Value',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
                subtitle: Text(
                  eachUser.userName !=null? eachUser.userName : 'Default Value',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  displayUserProfile(BuildContext context, {String profileId}) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context){
          return ProfilePage(userProfileId: profileId,);
        }
    ));
  }
}
