import 'dart:io';

import 'package:chat/Models/UserModel.dart';
import 'package:chat/main.dart';
import 'package:chat/pages/ChatRoomPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Models/ChatRoomModel.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchPage({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
  ChatRoomModel? chatroom;
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('chatrooms').where('participants.${widget.userModel.uid}',isEqualTo: true).where('participants.${targetUser.uid}',isEqualTo: true).get();
  
  if(snapshot.docs.length > 0){//fetch the existing one
    var docData = snapshot.docs[0].data(); //do participants ka pehla document hi unki cat hogi. is se hum aik chatroom model bana lengay
    ChatRoomModel existingChatroom = ChatRoomModel.fromMap(docData as Map<String,dynamic>);
    chatroom = existingChatroom; //hamara chatroom ka variable existing variable k barabar hojaega

    print('chat room already created');
  }
  else{      //create a new one
    ChatRoomModel newChatRoom = ChatRoomModel(//creating chat room
      Chatroomid: uuid.v1(),  //new we have made our chat room id
      lastMessage: '', //we do not have last msg so it will be empty
      participants: {
        widget.userModel.uid.toString(): true, //in participants we will give a map of participants id
        targetUser.uid.toString(): true
      }
    ); 
    await FirebaseFirestore.instance.collection('chatrooms').doc(newChatRoom.Chatroomid).set(newChatRoom.toMap());//is tarah hum ne chatroom ko firebase men save karwa dia
    chatroom = newChatRoom;
    print('New chat room created');
  }
  return chatroom;
  } 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search'),),
      body: SafeArea(child: Container(padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
        child: Column(
          children: [
            TextField(decoration: const InputDecoration(hintText: 'Email Address'),
            controller: searchController,),
            const SizedBox(height: 20,),
            CupertinoButton(onPressed:(){
              setState(() {
                
              });
            },color: Colors.blue,child:const Text('Search'),),
            const SizedBox(height: 20,),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users')
              .where('email',isEqualTo: searchController.text) //hum firebase men jaengay or jo user ne email search bar men likha hoga usko search karengay
               .where('email',isNotEqualTo:widget.userModel.email).snapshots(), //hum firebase men jaengay or jo user ne email search bar men likha hoga usko search karengay
              builder: (context,Snapshot){
                if(Snapshot.connectionState == ConnectionState.active){//sab se pehle hum check karengay k kia hamara connection firebase se hogaya hai ya nahi?
                  if(Snapshot.hasData){  //ab hum check karengay k snapshot men data aya
                    QuerySnapshot dataSnapshot = Snapshot.data as QuerySnapshot;  //humen jo Snapshot receive hua hai usay hum querySnapshot men convert karengay

                    if(dataSnapshot.docs.length > 0){
                      //if(dataSnapshot.docs.isNotEmpty){
                      Map<String,dynamic> userMap = dataSnapshot.docs[0].data() as Map<String,dynamic>; //agar docSnapshot men koi email address ata hai tab hi ye usko map men convert karay
                      UserModel searchedUser = UserModel.fromMap(userMap); //ab apne usermodel ko ye map send kardengay 

                      return ListTile(
                        title: Row(children: [CircleAvatar(backgroundImage: NetworkImage(searchedUser.profilepic.toString()),),SizedBox(width: 5,),Text(searchedUser.firstname.toString()),const SizedBox(width: 5,),Text(searchedUser.lastname.toString())],)  ,
                        //subtitle: Text(searchedUser.firstname.toString()),
                        subtitle: Container(padding: EdgeInsets.fromLTRB(45, 0, 10, 10),child:Text(searchedUser.gender.toString()),),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () async {
                        ChatRoomModel? chatroomModel = await getChatRoomModel(searchedUser);
                        if(chatroomModel != null){
                          Navigator.pop(context);//is k zariay hum wapis search page par ajengay direct
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatRoomPage(
                            targetUser: searchedUser, 
                            chatroom: chatroomModel, 
                            userModel: widget.userModel, 
                            firebaseUser: widget.firebaseUser)));
                        }
                          
                        },
                      );
                    }
                    else{
                      return const Text('No results found'); //agar koi email nahi milta to no results found ajaega
                    }
                  
                  }
                  else if(Snapshot.hasError){ //ya error hogaya data collection men
                    return const Text('An error occured');
                  }
                  else{
                    return const Text('No results found');
                  }

                }
                else{
                  return const CircularProgressIndicator(); //if connection is not built then we return CircularProgressIndicator()
                }
              })
          ],
        ),
      )),
    );
  }
}