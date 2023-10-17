class ChatRoomModel{ //We are making a class for the Chat Room if there is any change then we can change our class and entire change will occur all the code
  String? Chatroomid;  //We used ? in our properties, which means that these properties of a user can be null. Otherwise code will give an error
  Map<String,dynamic>? participants;
  String? lastMessage;

  ChatRoomModel({this.Chatroomid,this.participants,this.lastMessage});

  ChatRoomModel.fromMap(Map<String,dynamic> map){  //now we make another constructor which extract values from Map to userModel class. This is called "json serialization"
    Chatroomid = map['Chatroomid'];
    participants = map['participants'];
    lastMessage = map['lastmessage'];
  }

  Map<String,dynamic> toMap(){ //now we make a toMap function which returns a Map and sends value from ChatRoomModel class to database
    return {
      'Chatroomid':Chatroomid,
      'participants':participants,
      'lastmessage':lastMessage,
    };
  }
}