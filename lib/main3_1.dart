import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:math';
import 'package:read/support/user.dart';
import 'package:save_in_gallery/save_in_gallery.dart';

class NewCard extends StatefulWidget {
  @override _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<NewCard> {
  File _imageFile;
  String _downloadurl;
  StorageReference _reference = FirebaseStorage.instance.ref().child('Image');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Firebase Storage'),
        actions: <Widget>[
          IconButton(onPressed: getImage,
            icon: Icon(Icons.add_comment),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Flexible(
              child: _buildBody(context),
            ),
          ],
        ),
      ),
    );
  }
  delete(Record record){
    Firestore.instance.runTransaction(
            (Transaction transation) async {
          await transation.delete(record.reference);
        }
    );
  }
  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('storage').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.documents);
      },
    );
  }
  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return GridView.count(
      scrollDirection: Axis.vertical,
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        padding:  EdgeInsets.only(top: 20),
        children: snapshot.map((data) => _buildListItem(context, data)).toList()
    );
  }
  Future downloadImage() async{
    String downloadAddress = await _reference.getDownloadURL();
    setState(() {
      _downloadurl = downloadAddress;
    });
  }
  Future<String>_countDown = Future<String>.delayed(Duration(seconds: 3),
          ()=> "kill you");
  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
    return FutureBuilder<String>(
      future: _countDown,
      builder: (BuildContext context,AsyncSnapshot<String>snapshort){
        List<Widget>children;
        if(snapshort.hasData){
          children = <Widget>[
            Hero(
                tag: '',
                child: Image.network(record.url,height: 110,),
            ),
            Row(
               mainAxisAlignment: MainAxisAlignment.end,
               children: <Widget>[
                 Text(record.location,
                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
                 IconButton(icon: Icon(Icons.delete_forever,size: 18,),
                   onPressed: (){delete(record);},),
               ],
            ),
            IconButton(icon: Icon(Icons.save_alt,size: 18,),
              onPressed: (){downloadImage();},),
          ];
        }else{
          children = <Widget>[
            SizedBox(
              child: CircularProgressIndicator(),
              width: 20,height: 20,
            ),
            const Padding(padding: EdgeInsets.only(top: 16),
              child: Text('Waiting Please!!!'),
            ),
          ];
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: children,
          ),
        );
      },
    );
//    final record = Record.fromSnapshot(data);
//    return ListTile(
//      key: ValueKey(record.location),
//      title: Card(
//        child: Column(
//          children: <Widget>[
//            //            Image.network(record.url,height: 155,),
////            Row(
////              mainAxisAlignment: MainAxisAlignment.end,
////              children: <Widget>[
////              Text(record.location,
////                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
////              IconButton(icon: Icon(Icons.delete_forever,size: 18,),
////                onPressed: (){delete(record);
////                },),
////              ],
////            ),
//            FutureBuilder<ByteData>(
//              future: _wai6SecAndLoadImage(context,data),
//              builder: (BuildContext context, AsyncSnapshot<ByteData> snapshort ){
//                if(snapshort.hasData){
//                  return CircularProgressIndicator();
//                }
//                return Center(child: Hero(
//                  tag: " ",
//                  child: Image.network(record.url,height: 120,),
//                ));
//              },
//            ),
//            Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: <Widget>[
//                 Text(record.location,
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),),
//                 IconButton(icon: Icon(Icons.delete_forever,size: 18,),
//                   onPressed: (){delete(record);
//              },),
//          ],
//        ),
//        ]),
//      ),
//    );
  }

  Future getImage([String string]) async {
    // Get image from gallery.//
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    _uploadImageToFirebase(image);
  }

  Future<void> _uploadImageToFirebase(File image) async {
    try {
      // Make random image name.//
      int randomNumber = Random().nextInt(100000);
      String imageLocation = 'images/image${randomNumber}.jpg';

      // Upload image to firebase.//
      final StorageReference storageReference = FirebaseStorage().ref().child(imageLocation);
      final StorageUploadTask uploadTask = storageReference.putFile(image);
      await uploadTask.onComplete;
      _addPathToDatabase(imageLocation);
    }catch(e){
      print(e.message);
    }
  }

  Future<void> _addPathToDatabase(String text) async {
    try {
      // Get image URL from firebase//
      final ref = FirebaseStorage().ref().child(text);
      var imageString = await ref.getDownloadURL();

      // Add location and url to database//
      await Firestore.instance.collection('storage').document().setData({'url':imageString , 'location':text});
    }catch(e){
      print(e.message);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message),
            );
          }
      );
    }
  }



}
class Record {
  final String location;
  final String url;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['location'] != null),
        assert(map['url'] != null),
        location = map['location'],
        url = map['url'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$location:$url>";
}

