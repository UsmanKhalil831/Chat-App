import 'dart:io';

class UserModel{ //We are making a class for the user if there is any change then we can change our class and entire change will occur all the code
    String? uid; //We used ? in our properties, which means that these properties of a user can be null. Otherwise code will give an error
    String? firstname;
    String? lastname;
    String? gender;
    String? email;
    String? profilepic;

    UserModel({this.uid,this.firstname,this.lastname,this.gender,this.email}); //this is the default constructor of our UserModel class

    UserModel.fromMap(Map<String,dynamic> map){  //now we make another constructor which extract values from Map to userModel class. This is called "json serialization"
      uid = map['uid'];
      firstname = map['firstname'];
      lastname = map['lastname'];
      gender = map['gender'];
      email = map['email'];
      profilepic = map['profilepic'];
    }
    Map<String,dynamic> toMap(){ //now we make a toMap function which returns a Map and sends value from UserModel class to database
      return {
        'uid':uid,
        'firstname':firstname,
        'lastname':lastname,
        'gender':gender,
        'email':email,
        'profilepic':profilepic,
      };
}
}