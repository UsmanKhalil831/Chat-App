import 'package:chat/Models/ChatRoomModel.dart';
import 'package:chat/Models/FirebaseHelper.dart';
import 'package:chat/Models/UIhelper.dart';
import 'package:chat/Models/UserModel.dart';
import 'package:chat/pages/ChatRoomPage.dart';
import 'package:chat/pages/LoginPage.dart';
import 'package:chat/pages/SearchPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const HomePage({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat App'),centerTitle: true,
                actions: [
                  IconButton(onPressed: () async { //ye future he islai await use krengay
                  await FirebaseAuth.instance.signOut(); //sign out k liay use krengay
                  Navigator.popUntil(context, (route) => route.isFirst); //tab tak navigate krta rahe jab tk 1st page na ajaye
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const LoginPage()));
                  },
                   icon: const Icon(Icons.exit_to_app_outlined))
                ],),
      body: SafeArea(child: Container(
        child: StreamBuilder(//stream builder isliay use kar rahe hen q k humen firebase se data uthana hai
          stream: FirebaseFirestore.instance.collection('chatrooms').where('participants.${widget.userModel.uid}',isEqualTo: true).snapshots(),
          builder: (context,snapshot){
            if(snapshot.connectionState == ConnectionState.active){
              if(snapshot.hasData){
                QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;//ab humen chahie querysnapshot to hum ne snapshot se query snapshot banalia
                return ListView.builder(
                  itemCount: chatRoomSnapshot.docs.length,
                  itemBuilder: (context,index){
                    ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(chatRoomSnapshot.docs[index].data() as Map<String,dynamic>);//is se hmen aik map milega
                    Map<String,dynamic> participants = chatRoomModel.participants!;
                    List<String> participantsKeys = participants.keys.toList(); //participants ki ids ki key hum aik list men save kar lengay 
                    participantsKeys.remove(widget.userModel.uid); //us list men se hum apni id ki key remove kardengay
                    return FutureBuilder(
                      future: FirebaseHelper.getUserModeById(participantsKeys[0]),//target ki key se us ka model fetch karengay
                      builder: (context,userData){
                        if(userData.connectionState == ConnectionState.done){
                          if(userData.data != null){//agar user data men data ajaye
                            UserModel targetUser = userData.data as UserModel;//target ka usermodel fetch karlia
                         return ListTile(
                           title: Row(children: [CircleAvatar(backgroundImage: NetworkImage(targetUser.profilepic.toString()),),SizedBox(width: 5,),Text(targetUser.firstname.toString()),const SizedBox(width: 5,),Text(targetUser.lastname.toString())],),
                          subtitle: Container(padding: EdgeInsets.fromLTRB(45, 0, 0, 5),child:
                                  (chatRoomModel.lastMessage != '')? Text(chatRoomModel.lastMessage.toString())
                          :const Text('Say Hi to your new friend!',style: TextStyle(color: Colors.blue),)),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatRoomPage(
                              targetUser: targetUser, 
                              chatroom: chatRoomModel, 
                              userModel: widget.userModel, 
                              firebaseUser: widget.firebaseUser)));
                          },
                         );
                          }
                          else{
                            return Container();//otherwise kuch b return na ho
                          }
                        }
                        else{
                          return Container(); //agar connection nahi bana to kuch b return nhi krengay
                        }
                           
                      });
                  });
              }
              else if(snapshot.hasError){
                return Center(child: Text(snapshot.error.toString()),);
              }
              else{
                return const Center(child: Text('No Chats'),);
              }
            }
            else{
              return const Center(child: CircularProgressIndicator(),);
            }
          }),
      )),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: ((context) => SearchPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser))));
      },
      child: const Icon(Icons.search),),
    );
  }
}