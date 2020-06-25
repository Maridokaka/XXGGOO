import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'support/user.dart';

class Main3 extends StatefulWidget {
  @override
  _Main3State createState() => _Main3State();
}
class _Main3State extends State<Main3> {
  bool showTextField = false;
  TextEditingController controller = TextEditingController();
  String collectionName = "Users";
  bool isEditing = false;
  String imagelink;
  Users curUsers;
  File imageFile;


  getUsers(){
   return Firestore.instance.collection(collectionName,).snapshots();
  }
  addUsers(){
    Users users = Users(name: controller.text, image: imagelink);
    try{
      Firestore.instance.runTransaction(
          (Transaction transaction) async {
            await Firestore.instance.collection(collectionName)
                .document().setData(users.toJson());
          }
      );
    }catch(e){
      print(e.toString());
    }
  }
  add(){
    if(isEditing){
      update(curUsers, controller.text,);
      setState(() {
        isEditing = false;
      });
    }else{
      addUsers();
    }
    controller.text = " ";
  }
  update(Users users, String newName){
    Firestore.instance.runTransaction(
            (Transaction transaction) async {
          await transaction.update(users.reference, {'name': newName});
        }
    );
  }
  delete(Users users){
    Firestore.instance.runTransaction(
            (Transaction transation) async {
          await transation.delete(users.reference);
        }
    );
  }
  Widget buildBody(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: getUsers(),
      builder: (context, snapshot){
        if(snapshot.hasError){
          return Text('Error ${snapshot.error}');
        }
        if(snapshot.hasData){
          print("Document ${snapshot.data.documents.length}");
          return buildList(context, snapshot.data.documents);
        }
        return CircularProgressIndicator();
      },
    );
  }
  Widget buildList(BuildContext context, List<DocumentSnapshot> snapshot){
    return ListView(
      children: snapshot.map((data)=> builListItem(context, data)).toList(),
    );
  }
  Widget builListItem(BuildContext context, DocumentSnapshot data){
    final record = Users.fromSnapshot(data);
    return Padding(
      key: ValueKey(record.name),
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: ListTile(
          leading: GestureDetector(
            child: Hero(
              key: ValueKey(record.name),
              tag: context.toString(),
              child: CircleAvatar(
                backgroundImage: NetworkImage(record.image),
                radius: 22,
              ),
            ),onTap: ()=> _showSecondPage(context, data),
          ),
          title: Text(record.name),
          trailing: IconButton(icon: Icon(Icons.delete_forever),
            onPressed: (){
              delete(record);
            },
          ),onTap: ()
        {
          setUpdateUI(record);
        },
        ),
      ),
    );
  }
  Future<void> _showChoiceDailog(BuildContext context, DocumentSnapshot data){
    return showDialog(context: context,builder: (BuildContext context){
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Text('Update Date',style: TextStyle(fontSize: 18,color: Colors.black87,
                        fontWeight: FontWeight.bold),),
                    SizedBox(height: 30,),
                    GestureDetector(
                      child: Text('Gallary'), onTap: (){_openGallary(context);},),
                    SizedBox(height: 20,),
                    GestureDetector(
                      child: Text('Camera'), onTap: (){_openCamera(context);},),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
  void _showSecondPage(BuildContext context, DocumentSnapshot data){
    final record = Users.fromSnapshot(data);
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Hero(tag: context.toString(), child: Image.network(record.image),
            ),
          ),
          ),
        ),
    );
  }
  setUpdateUI(Users users){
    controller.text = users.name;
    setState(() {
      showTextField = true;
      isEditing = true;
      curUsers = users;
    }
    );
  }
  button(){
    return SizedBox(width: double.infinity,
      child: OutlineButton(
        child: Text(isEditing? "UPDATE" : "ADD"),
        onPressed: (){
          add();
          setState(() {
            showTextField = false;
          });
        },
      ),
    );
  }

  Widget _dicideImageView(BuildContext context, DocumentSnapshot data){
    if(imageFile == null){
      return Text('No Image Select');
    }else{
      return Image.file(imageFile, width: 350,height: 400,);
    }
  }

  @override
  Widget build(BuildContext context) {
    DocumentSnapshot data;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Firebase Flutter'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add_comment),
              onPressed: ()
//              => Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdateorAdd())),
              {
                setState(() {
                  showTextField = !showTextField;
                });
              },
              ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                showTextField? Column(
                  children: <Widget>[
                    _dicideImageView(context, data),
                    RaisedButton(onPressed: (){
                      _showChoiceDailog(context, data);

//                       Add Image into Storage
                      FirebaseStorage fs = FirebaseStorage.instance;
                      StorageReference rootSref = fs.ref();
                      Random random = Random.secure();
                      String child = random.nextInt(100000).toString();
                      StorageReference pictureSref = rootSref.child("pictures").child("image_" +child);

                      // Image in Storage into Database
                      pictureSref.putFile(imageFile).onComplete.then((storageTask) async {
                        String link = await storageTask.ref.getDownloadURL();
                        print("Upload");
                        setState(() {
                          imagelink = link;
                        });
                      });
                    },child: Text('Select Image'),),
                    SizedBox(height: 10,),
                    TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                          labelText: "Name", hintText: "Enter name"),
                    ),
                    SizedBox(height: 10,),
                    button(),
                  ],
                ):Container(),
                SizedBox(height: 20,),
                Text("USERS",style: TextStyle(fontSize: 20),),
                SizedBox(height: 20,),
                Flexible(
                  child: buildBody(context),
                ),
              ],
            ),
          ),
    );
  }

  void _openCamera(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.camera);
    this.setState((){
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }
  void _openGallary(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      imageFile = picture;
    });
    Navigator.of(context).pop();
  }
}