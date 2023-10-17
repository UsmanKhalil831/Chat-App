import 'package:chat/Models/MessageModel.dart';
import 'package:chat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Models/ChatRoomModel.dart';
import '../Models/UserModel.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser; //us user ka model jis se bat karnahi
  final ChatRoomModel chatroom;//chat room
  final UserModel userModel;// hamara apna userModel
  final User firebaseUser;//hamari apni firebase ki information
  const ChatRoomPage({super.key, required this.targetUser, required this.chatroom, required this.userModel, required this.firebaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();
  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();
    if(msg != ''){
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: DateTime.now(),
        text: msg,
        seen: false
      );//ab hum is msg ko apn firebase k chatroms k collection ki id k andar aik or documnt bana kar save kar rahe hen
      FirebaseFirestore.instance.collection('chatrooms').doc(widget.chatroom.Chatroomid).collection('messages').doc(newMessage.messageid).set(newMessage.toMap());
      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance.collection('chatrooms').doc(widget.chatroom.Chatroomid).set(widget.chatroom.toMap());
      print('msg sent');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(children: [CircleAvatar(backgroundImage: NetworkImage(widget.targetUser.profilepic.toString()),),SizedBox(width: 5,),Text(widget.targetUser.firstname.toString()),const SizedBox(width: 5,),Text(widget.targetUser.lastname.toString())],) ),
      body: SafeArea(child: 
      Container(child: Column(
        children: [
          // This is where the chats will go
            Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 10),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('chatrooms')
                .doc(widget.chatroom.Chatroomid).collection('messages')
                .orderBy('createdon',descending: false).snapshots(),
                builder: (context,snaphot){
                  if(snaphot.connectionState == ConnectionState.active){
                    if(snaphot.hasData){
                      QuerySnapshot dataSnapshot = snaphot.data as QuerySnapshot;// convert snaphot to querySnapshot
                      return ListView.builder(
                        reverse: true,
                        itemCount: dataSnapshot.docs.length,
                        itemBuilder: (context,index){
                          MessageModel currentMessage = MessageModel.fromMap(dataSnapshot.docs[index].data() as Map<String,dynamic>);
                          return Row(mainAxisAlignment: (currentMessage.sender == widget.userModel.uid) ? MainAxisAlignment.end:MainAxisAlignment.start,
                            children: [
                            Container(margin: const EdgeInsets.symmetric(vertical: 2),padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                            decoration: BoxDecoration(color:(currentMessage.sender == widget.userModel.uid)? Colors.grey: Colors.blue,
                            borderRadius: BorderRadius.circular(5),),
                            child:Text(currentMessage.text.toString(),style: const TextStyle(color: Colors.white),) )
                          ],)   ;
                        });
                    }
                    else if(snaphot.hasError){
                      return const Center(child: Text('An error occured, Please check your internet connection'),);
                    }
                    else{
                      return const Center(child: Text('Say hi to new friends'),);
                    }
                  }
                  return const Center(child: CircularProgressIndicator(),);
                })
            )),

        Container(padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5,),color: Colors.grey[200],
          child: Row(
            children: [

              Flexible(child: TextField(
                controller: messageController,
                decoration: InputDecoration(hintText: 'Enter message',),
                maxLines: null,)),//maximum lines can be infinite

              IconButton(onPressed: (){
                sendMessage();
              }, icon: Icon(Icons.send),color: Colors.blue,)
            ],
          ),
        )


        ],
      ),)),
    );
  }
}