import 'package:chat/Models/UIhelper.dart';
import 'package:chat/Models/UserModel.dart';
import 'package:chat/pages/HomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
class CompleteProfilePage extends StatefulWidget {
  final UserModel usermodel;
  final User firebaseUser; //we are making variables for our current user. This is our firebase_auth user
  const CompleteProfilePage({super.key, required this.usermodel, required this.firebaseUser});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  
  File? imageFile; //we make a variable for our image, since a photo is a file so we have made a variable file
    getFromGallery() async{
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery); 
    if(pickedFile != null){
    setState(() {
      imageFile = File(pickedFile.path);
      });
      await uploadImagetoFirebase(imageFile!);
  }
  }
  getFromcamera()async{
  XFile? pickedFile = await ImagePicker().pickImage(source:ImageSource.camera,);
  if(pickedFile != null){
    setState(() {
      imageFile = File(pickedFile.path);
      });
      await uploadImagetoFirebase(imageFile!);
    
  }
}
Future uploadImagetoFirebase(File imageFile) async{
  try{
    UploadTask uploadTask = FirebaseStorage.instance.ref('ProfilePictures').child(widget.usermodel.uid!).putFile(imageFile); //1st child men folder ka name dengay jis men save karna hai 2nd men file name dengay
    TaskSnapshot snapshot = await uploadTask;
    String imageURL = await snapshot.ref.getDownloadURL();
    widget.usermodel.profilepic = imageURL;
    await FirebaseFirestore.instance.collection('users').doc(widget.usermodel.uid).set(widget.usermodel.toMap());
  } catch (e){
    print(e);
  }
}

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  void selectImage(ImageSource source) async {   //here argument imageSource will be used. Whether we have to take a photo from gallery or from source
    XFile? pickedFile = await ImagePicker().pickImage(source: source); //pickImage XFile return karta hai isliay hum isay Xfile k aik variable bana kar store karengay
    if (pickedFile != null){// agar file pick hojati hai to crop image k function par chala jaye ta k image crop ho sakay
      cropImage(pickedFile);
    }
  } 
  void cropImage(XFile file) async{
    File? croppedImage = (await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),//This will ensure that picture crop size will be 1:1
      compressQuality: 20)) as File?; //we reduce the quality becuase heavy file will be loaded very late
    if(croppedImage != null){
      setState(() {
        imageFile = croppedImage;
      });
    }
  } 
  void ShowPhotoOptions(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        title: const Text('Upload Profile Picture'),
        content: Column(mainAxisSize: MainAxisSize.min,//This command is used to minimum the size of the dialog box otherwise dialog box use the entire screen
          children: [
            ListTile(
              title: const Text('Select from Gallery'),leading: const Icon(Icons.photo),
             onTap: () {
              Navigator.pop(context);  //this will ensure that after tapping "select from galley" dialog box will be disappear 
               getFromGallery();
             },),
            ListTile(title: const Text('Take a photo'),leading: const Icon(Icons.camera_alt),
            onTap:(){ 
              Navigator.pop(context);  //this will ensure that after tapping "select from galley" dialog box will be disappear 
              getFromcamera();
            },)
          ],
        ),
      );
    });
  }

  void CheckValues(){
    String fullname = firstNameController.text.trim();
    String lastname = lastNameController.text.trim();
    String gender = genderController.text.trim();

    if(fullname == '' || lastname == '' || gender == ''){
      UIhelper.showAlertDialog(context, 'Incomplete Data', 'Please fill all the fields');
      //Fluttertoast.showToast(msg: 'Enter all the fields',backgroundColor: Colors.blue,gravity: ToastGravity.BOTTOM);
    }
    else 
    UploadData();
  }
  void UploadData() async {//upload remaining fields on database
    String? firstname = firstNameController.text.trim();
    widget.usermodel.firstname = firstname;
    String? lastname = lastNameController.text.trim();
    widget.usermodel.lastname = lastname;
    String? gender = genderController.text.trim();
    widget.usermodel.gender = gender;

    await FirebaseFirestore.instance.collection('users').doc(widget.usermodel.uid).set(widget.usermodel.toMap())
    .then((value) {Navigator.popUntil(context, (route) => route.isFirst); 
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>
                  HomePage(userModel:widget.usermodel, firebaseUser: widget.firebaseUser)));});//ab jo hamaray pass fistname,lastname and gender ki value aai hai wo hum firestore men send kar rahay hen
    firstNameController.clear();
    lastNameController.clear();
    genderController.clear();
    Fluttertoast.showToast(msg: 'Registration Successful',backgroundColor: Colors.blue,gravity: ToastGravity.BOTTOM_LEFT);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, //Move the text of appBar in the middle
        automaticallyImplyLeading: false, //This command will remove the back button appear in the appBar
        title: const Text('Complete Profile'),
      ),
      body: SafeArea(child: Container(padding: const EdgeInsets.symmetric(horizontal: 30),
        child: 
        // ListView(
        //   children: [
        //     const SizedBox(height: 20,),
        //     CupertinoButton(
        //       onPressed: (){
        //         ShowPhotoOptions();
        //       },
        //     child: CircleAvatar(radius: 60,backgroundColor: Colors.blue,
        //     backgroundImage: (imageFile != null) ? FileImage(imageFile!) : null,  //we will provide our cropped file in fileimage. and it cannot be null so we have marked!. If image is not null it will be uploaded otherwise null will return
        //       child: (imageFile == null) ? Icon(Icons.person,size: 60,) : null), //if there is no image file then there is a people icon otherwise it will be null when we upload the image
        //     ),
        //        const SizedBox(height: 20,),
        //        const TextField(
        //         decoration: InputDecoration(hintText: 'Full Name'),
        //        ),
        //        const SizedBox(height: 20,),
        //        CupertinoButton(color: Colors.blue,
        //        onPressed: (){
        //           Navigator.push(context, MaterialPageRoute(builder: (context)=>const HomePage()));
        //        }, child: const Text('Submit'))
        //   ],
        // ),
        Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text('Chat App',style: TextStyle(color: Colors.blue,fontSize: 45,fontWeight: FontWeight.bold),),
              const SizedBox(height: 10,),
              CupertinoButton(
              onPressed: (){
                ShowPhotoOptions();
              },
            child: CircleAvatar(radius: 60,backgroundColor: Colors.blue,
            backgroundImage: (imageFile != null) ? FileImage(imageFile!) : null,  //we will provide our cropped file in fileimage. and it cannot be null so we have marked!. If image is not null it will be uploaded otherwise null will return
              child: (imageFile == null) ? Icon(Icons.person,size: 60,) : null), //if there is no image file then there is a people icon otherwise it will be null when we upload the image
            ),
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(hintText: 'First Name'),),
              const SizedBox(height: 10,),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(hintText: 'Last Name')),
              const SizedBox(height: 10,),
              TextField(
                controller: genderController,
                decoration: const InputDecoration(hintText: 'Gender')),
              const SizedBox(height: 30,),
              CupertinoButton(onPressed: (){
                
                CheckValues();
              }, 
              color: Colors.blue,
              child: const Text('Submit'))
            ],
          ),
        ),
      ),
        )),
    );
  }
}