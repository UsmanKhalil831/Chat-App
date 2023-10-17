import 'package:chat/Models/Firebasehelper.dart';
import 'package:chat/Models/UserModel.dart';
import 'package:chat/pages/CompleteProfilePage.dart';
import 'package:chat/pages/HomePage.dart';
import 'package:chat/pages/LoginPage.dart';
import 'package:chat/pages/SignUpPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'firebase_options.dart';
var uuid = Uuid();
void main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //now we check whether the user is logged in or not?
  User? currentUser = FirebaseAuth.instance.currentUser;  //Returns the current [User] if they are currently signed-in, or null if not.
  if(currentUser != null){
    //already logged-in
    UserModel? thisUserModel = await FirebaseHelper.getUserModeById(currentUser.uid); 
      if(thisUserModel != null){
        runApp(MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));//MyApp class will be called, here we cannot give our userModel. We fetch usermodel from firebase. So we make a seperate class for this
      }
      else{
        runApp(MyApp());//MyApp class will be called
      }
  }
  else{
    //not logged in
    runApp(MyApp());//MyApp class will be called
  }

 
}

//if we are not log in already then this widget is used
class MyApp extends StatelessWidget {  
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      home: LoginPage(),
    );
  }
}

//if we are log in already then this widget is used
class MyAppLoggedIn extends StatelessWidget {   
  final UserModel userModel;        //we make a variable for our UserModel class
  final User firebaseUser;           //we make a variable for User and details will be fetch from firebase_auth

  const MyAppLoggedIn({super.key, required this.userModel, required this.firebaseUser});         
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      home: HomePage(userModel: userModel, firebaseUser: firebaseUser),
    );
  }
}


  