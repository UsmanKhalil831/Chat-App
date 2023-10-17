import 'package:chat/Models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseHelper {
  static Future<UserModel?> getUserModeById(String uid) async {  //now we make a function that takes a user id as argument and return a Usermodel. q k ye future return kar raha hai isliay hum async likhengay.static isliay kia hai ta k isay dosri file se access kar saken
    UserModel? userModel;
    DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection('users').doc(uid).get(); //get humen documentSnapshot deta hai. to hum ne isko aik variable
    if(docSnap.data() != null){   //ab hum is docSnap ko check karengay k agar wo null na ho to aik map bana day
      userModel = UserModel.fromMap(docSnap.data() as Map<String,dynamic>);  //docSnap ko convert kar k dengay q k ye argument men map leta hai
    }
    return userModel;  //agar docSnap men data nahi aya to null return hojaega q k initially userModel ko koi bhi value assign nahi kari hai
  }
}