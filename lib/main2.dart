import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:read/crodobj.dart';
import 'dart:async';

import 'package:read/main1.dart';

class Main2 extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<Main2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('PUBG',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('kaka').snapshots(),
        builder: (context, snapshots){
          if(!snapshots.hasData)
            return Text('Loading data ... Please Wait ...');
          return Column(
            children: <Widget>[
              SizedBox(height: 40,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(width: 20,),
                  Text(snapshots.data.documents[0]['name'], style: TextStyle(fontSize: 25,
                      fontWeight: FontWeight.bold,color: Colors.deepOrange),),
                  SizedBox(width: 10,),
                  Text(snapshots.data.documents[0]['price'].toString(), style: TextStyle(fontSize: 25,
                      fontWeight: FontWeight.bold,color: Colors.orange),),
                ],
              ),
              SizedBox(height: 20,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(width: 20,),
                  Text(snapshots.data.documents[1]['name'], style: TextStyle(fontSize: 25,
                      fontWeight: FontWeight.bold,color: Colors.deepOrange),),
                  SizedBox(width: 10,),
                  Text(snapshots.data.documents[1]['price'].toString(), style: TextStyle(fontSize: 25,
                      fontWeight: FontWeight.bold,color: Colors.orange),),
                ],
              ),
              SizedBox(height: 40,),
              MaterialButton(
                color: Colors.orange,
                onPressed: (){BlendMode.clear.toString();},
                child: Text('Delete',style: TextStyle(fontSize: 25,
                    fontWeight: FontWeight.bold,color: Colors.deepOrange),),
              ),
            ],
          );
        },
      ),
    );
  }
}
