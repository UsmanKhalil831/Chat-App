class MessageModel{
  String? messageid;
  String? sender; //Sender of a msg
  String? text; //Actual msg
  bool? seen; //Msg seen by the receiver or not,if not seen is false otherwise true
  DateTime? createdon; //When msg is sent?

  MessageModel({this.messageid,this.sender,this.text,this.seen,this.createdon});

  MessageModel.fromMap(Map<String,dynamic> map){
    messageid = map['messagid'];
    sender = map['sender'];
    text = map['text'];
    seen = map['seen'];
    createdon = map['createdon'].toDate();
  }

  Map<String,dynamic> toMap(){
    return {
      'messageid':messageid,
      'sender':sender,
      'text':text,
      'seen':seen,
      'createdon':createdon
    };
  }
}