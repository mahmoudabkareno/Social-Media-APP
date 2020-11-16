import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instgram/Models/User.dart';
import 'package:image/image.dart' as IMD;
import 'package:instgram/pages/HomePage.dart';
import 'package:instgram/widgets/ProgressWidget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class UploadPage extends StatefulWidget {

  final User getCurrentUser;

  UploadPage({this.getCurrentUser});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return _image == null ? diplayUploadScreen() : diplayUploadFormScreen();
  }

  Widget diplayUploadScreen() {
    return Container(
      color: Theme.of(context).accentColor.withOpacity(0.4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            color: Colors.grey,
            size: 190,
          ),
          Padding(
            padding: EdgeInsets.only(top: 23),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                  'Upload Image',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 25
                ),
              ),
              onPressed: ()=> takeInage(context),
            ),
          )

        ],
      ),
    );
  }

  takeInage(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context){
        return SimpleDialog(
          title: Text(
            'New Post',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold
            ),
          ),
          children: [
            SimpleDialogOption(
              child: Text(
                'Capture Image With Phone Camera',
                style: TextStyle(
                    color: Colors.white,
                ),
              ),
              onPressed: CaptureImageWithPhoneCamera,
            ),
            SimpleDialogOption(
              child: Text(
                'Select Image From Phone Gallery',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: pickImageFromPhoneGallery,
            ),
            SimpleDialogOption(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white,
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

  final picker = ImagePicker();
  File _image;
  bool uploading = false;
  String postId = Uuid().v4();
  TextEditingController descrptiontextEditingController = TextEditingController();
  TextEditingController locationtextEditingController = TextEditingController();

  @override
  void dispose(){
    super.dispose();
    descrptiontextEditingController.dispose();
    locationtextEditingController.dispose();
  }

  CaptureImageWithPhoneCamera() async{
    Navigator.pop(context);
    final pickedFile = await picker.getImage(
        source: ImageSource.camera,
      maxHeight: 670,
      maxWidth: 970
    );
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });

  }

  pickImageFromPhoneGallery() async{
    Navigator.pop(context);
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery,
    );
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  diplayUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
              Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: clearPostInfo,
        ),
        title: Text(
            'New Post',
          style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          FlatButton(
            child: Text(
              'share',
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 19,
                  fontWeight: FontWeight.bold
              ),
            ),
            onPressed: (){
              try{
                uploading? null : controlUploadAndSave();
              }catch(e){
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.message),
                  )
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          uploading? linearProgress(): Text(''),
          Container(
            height: 240,
            width: MediaQuery.of(context).size.width*0.7,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16/7,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: FileImage(_image),
                        fit: BoxFit.cover
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(widget.getCurrentUser.url),
            ),
            title: Container(
              width: 260,
              child: TextField(
                style: TextStyle(
                  color: Colors.white
                ),
                controller: descrptiontextEditingController,
                decoration: InputDecoration(
                  hintText: 'write Description for your inage',
                  hintStyle: TextStyle(
                    color: Colors.white
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
             Icons.person_pin_circle, color: Colors.white,size: 29,
            ),
            title: Container(
              width: 260,
              child: TextField(
                style: TextStyle(
                    color: Colors.white
                ),
                controller: locationtextEditingController,
                decoration: InputDecoration(
                  hintText: 'write the location here',
                  hintStyle: TextStyle(
                      color: Colors.white
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 230,
            height: 110,
            alignment: Alignment.center,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              color: Colors.lightBlue,
              child: Icon(
                  Icons.location_on,
                color: Colors.white,
              ),
              onPressed: getUserCurrentLocation,
            ),
          )
        ],
      ),
    );
  }

  clearPostInfo() {
    setState(() {
      _image = null;
    });
  }

  LatLng currentPostion;
  getUserCurrentLocation() async{
    try{
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);///Here you have choose level of distance
    print('posistion ${position}');
    List newPlace =  await await placemarkFromCoordinates(position.latitude, position.longitude);;
    Placemark placeMark  = newPlace[0];
    String compeletAddressInfor = '${placeMark.subThoroughfare} ${placeMark.thoroughfare}, ${placeMark.subLocality} ${placeMark.locality}, ${placeMark.subAdministrativeArea} ${placeMark.administrativeArea}, ${placeMark.postalCode} ${placeMark.country},';
    String specificAddress = '${placeMark.locality}, ${placeMark.country}';
    locationtextEditingController.text = specificAddress;
    }catch(e){
      print(e);
    }
  }

  controlUploadAndSave() async{
    setState(() {
      uploading = true;
    });
    await compressingPhotot();
    String downloadUrl = await uploadPhoto(_image);
    savePostInforToFirStore(url: downloadUrl, location: locationtextEditingController.text, discrption: descrptiontextEditingController.text);
    setState(() {
      _image = null;
      uploading = false;
      postId = Uuid().v4();
    });
  }

  compressingPhotot() async{
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    IMD.Image mImageFile = IMD.decodeImage(_image.readAsBytesSync());
    final compressedImageFile =
    File('$path/img_$postId.jpg')..writeAsBytesSync(IMD.encodeJpg(mImageFile));
    setState(() {
      _image = compressedImageFile;
    });
  }

  Future<String> uploadPhoto(mImageFile) async{
    try{
      UploadTask muploadTask = ref.child('post_$postId.jpg').putFile(mImageFile);
      TaskSnapshot taskSnapshot = await muploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    }catch(e){
      print(e);
    }
  }

  savePostInforToFirStore({String url, String location, String discrption}) {
    postsReference.doc(widget.getCurrentUser.uId).collection('usersPosts').doc(postId).set({
      'postId' : postId,
      'likes' : {},
      'postOwner' : widget.getCurrentUser.uId,
      'timestamo' : timestamp,
      'userName' : widget.getCurrentUser.userName,
      'description' : discrption,
      'location' : location,
      'url' : url,
    });
  }

  bool get wantKeepAlive => true;
  final DateTime timestamp = DateTime.now();
}
