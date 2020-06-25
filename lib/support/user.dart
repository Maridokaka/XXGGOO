import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String name;
  String image;
  DocumentReference reference;

  Users({this.name,this.image});
  Users.fromMap(Map<String, dynamic>map, {this.reference}){
    name = map["name"];
    image = map["image"];
  }
  Users.fromSnapshot(DocumentSnapshot snapshot):
       this.fromMap(snapshot.data, reference: snapshot.reference);
      toJson(){
        return {'name': name,'image': image};
      }
}



