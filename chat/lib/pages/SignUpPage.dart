import 'package:chat/Models/UIhelper.dart';
import 'package:chat/Models/UserModel.dart';
import 'package:chat/pages/CompleteProfilePage.dart';
import 'package:chat/pages/LoginPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void CheckValues() //We make this function to check that there is no empty field in our signup values
  {
    String email = emailController.text.trim();
    String Password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();
    
    if(email == '' || Password == '' || cPassword == ''){
      UIhelper.showAlertDialog(context, 'Incomplete Data', 'Please fill all the fields');
      //Fluttertoast.showToast(msg: 'Enter all the fields',backgroundColor: Colors.blue,gravity: ToastGravity.BOTTOM);
    }
    else if(Password != cPassword){
      UIhelper.showAlertDialog(context, 'Password Mismatch', 'The passwords you entered do not match');
      //Fluttertoast.showToast(msg: 'Password and Confirm Password do not match',backgroundColor: Colors.blue,gravity: ToastGravity.BOTTOM);
    }
    else{
      SignUp(email,Password,cPassword); //if there is no error then it will call the signUp method
    }

  }

  void SignUp(String email, String password,String cPassword)//We make this function, after tapping the SignUp button it will complete our SignUp process
  async { 
  UserCredential? credential;//Firebase_auth k pass aik pehle se class mojod hai jis ka nam hai UserCredential jab hum is class ko user ka email or password bhejtay hen to ye humen us user k credentials return karti hai. To hum ne yaha credential k nam se hi class banali hai
  UIhelper.showLoadingDialog(context, 'Creating new account...');
  
  {
     try{   //we use try and catch block because in authentication process there could be some errors so for dealing these errors we are using try and catch block
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      emailController.clear();
      passwordController.clear();
      cPasswordController.clear();
      
     } on FirebaseAuthException catch (e){
      Navigator.pop(context); //is se hamara loading dialog band hoga
      UIhelper.showAlertDialog(context, 'An error occured', e.message.toString());
      // if (e.code == 'weak-password'){
      //   //print('The password provided must have 6 letters');
      //   Fluttertoast.showToast(msg: 'The password provided must have 6 letters',backgroundColor: Colors.blue,gravity: ToastGravity.BOTTOM);
       
      // }
      // else if(e.code == 'email-already-in-use'){
      //   //print('Email already in use try with different email');
      //   Fluttertoast.showToast(msg: 'Email already in use try with different email',backgroundColor: Colors.blue,gravity: ToastGravity.BOTTOM);
      
    //   }
    // }
    //  catch (e){
    //   Fluttertoast.showToast(msg: 'wrong credentials');
    //   emailController.clear();
    //     passwordController.clear();
    }
    
    if(credential != null){  //now we are using another function. If email and password is authenticating succesfully then credentials will not be null. If there is any error then credential will be null
      String uid = credential.user!.uid;//This method will make a document in FireStore for this particular User. All the data of this user will be in DataBase. credential variable ki madad se humen is user ki uid mil jaegi jo FirebseAuth ne uniquely generate kari hogi. wo hum ne uid k nam k aik variable men store karli
      
      UserModel newUser = UserModel(
        uid : uid,//uid attribute ko humen jo credential se uid mili he wo dedengay
        email: email,// email attribute ko jo email user ka hai wo chala jayega
        firstname: '', // first name hamen pata nahi hai isliay usay empty chor dia hai
        lastname: '', // last name hamen pata nahi hai isliay usay empty chor dia hai
        gender: '', // gender hamen pata nahi hai isliay usay empty chor dia hai
        //profilepic: '',// profile pic abhi upload nahi kari hai isliay usay b empty chor dia hai
      );

      //yaha pe set ka jo function hai wo map leta hai jab k usermodel aik class hai to hum ne jo toMap wala function banaya tha usko hum yaha use karengay 
      await FirebaseFirestore.instance.collection('users').doc(uid).  //FirebaseFirestore k andar hum ne aik collection banaya uska nam hai users us k andar hum ne document banaya or uska nam hum ne user ki jo id humen milegi uid men wo rekh den is tarah hamara har document yani user ka data unique hoajega
      set(newUser.toMap())
      .then((value) => print('New User Created')); //set() ye karega k us men user ka data set kardega yani us men user ka data safe kardega. hum ne jo document banay hai. ye data hamaray pass jo hum ne userModel ki jo class banai thi waha se ayega. Yaha hum uska constructor call kar k us men values assign karengay
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CompleteProfilePage(usermodel: newUser, firebaseUser: credential!.user!)));
    }
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
              const SizedBox(height: 10,),
              TextField(
                controller: cPasswordController,
                decoration: const InputDecoration(hintText: 'Confirm Password'),
              obscureText: true,),
              const SizedBox(height: 30,),
              CupertinoButton(onPressed: (){
                //Navigator.push(context, MaterialPageRoute(builder: (context)=>const CompleteProfilePage()));
                CheckValues();
              }, 
              color: Colors.blue,
              child: const Text('Sign Up'))
            ],
          ),
        ),
      ),
      )
      ),
      bottomNavigationBar: Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Already have an account?",style: TextStyle(fontSize: 16),),
            CupertinoButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>const LoginPage()));
              }, 
            child: const Text('Log In'),)
          ],
        ),
      ),
    );
  }
}