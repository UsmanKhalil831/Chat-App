
import 'package:chat/Models/UIhelper.dart';
import 'package:chat/Models/UserModel.dart';
import 'package:chat/pages/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'SignUpPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void CheckValues(){
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if(email == '' || password == ''){
      UIhelper.showAlertDialog(context, 'Incomplete Data', 'Please fill all the fields');
      //print('Enter all the fields');
      //Fluttertoast.showToast(msg: 'Enter all the fields',backgroundColor: Colors.blue,gravity: ToastGravity.BOTTOM_LEFT);
    }
    else {
      login(email,password);
    }
  }
  void login(String email, String password) async {
    UserCredential? credential;
    UIhelper.showLoadingDialog(context, 'Logging In');
    try{
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      // emailController.clear();
      // passwordController.clear();
    }
    on FirebaseAuthException catch (e){
      Navigator.pop(context);//close the loading dialog
      UIhelper.showAlertDialog(context, 'An error occured', e.message.toString());
      // if (e.code == 'user-not-found'){
      //   Fluttertoast.showToast(msg: 'User not found',backgroundColor: Colors.blue,gravity: ToastGravity.BOTTOM_LEFT);
      //   emailController.clear();
      //   passwordController.clear();
      // }
      // else if (e.code == 'wrong-password'){
      //   Fluttertoast.showToast(msg: 'Wrong Password',backgroundColor: Colors.blue,gravity: ToastGravity.BOTTOM_LEFT);
      //   emailController.clear();
      //   passwordController.clear();
      // }
    }
    

    if(credential != null){
      String uid = credential.user!.uid;
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel = UserModel.fromMap(userData.data() as Map<String,dynamic>);//userData.data() humen aik object dega to hum usay cast kar k Map men convert karlengay

      //go to homepage
      
      Fluttertoast.showToast(msg: 'Log In Successful',backgroundColor: Colors.blue,gravity: ToastGravity.BOTTOM_LEFT);
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomePage(userModel: userModel, firebaseUser: credential!.user!)));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Container(padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text('Chat App',style: TextStyle(color: Colors.blue,fontSize: 45,fontWeight: FontWeight.bold),),
              const SizedBox(height: 10,),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: 'Email Address'),),
              const SizedBox(height: 10,),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(hintText: 'Password'),
              obscureText: true,),
              const SizedBox(height: 30,),
              CupertinoButton(onPressed: (){
                //Navigator.push(context, MaterialPageRoute(builder: (context)=>const SignUpPage()));
                CheckValues();
              }, 
              color: Colors.blue,
              child: const Text('Log In'))
            ],
          ),
        ),
      ),)
      ),
      bottomNavigationBar: Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an account?",style: TextStyle(fontSize: 16),),
            CupertinoButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const SignUpPage()));
              }, 
            child: const Text('Sign Up'),)
          ],
        ),
      ),
    );
  }
}