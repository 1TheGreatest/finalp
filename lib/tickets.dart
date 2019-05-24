import 'package:firebase_database/firebase_database.dart';

class Tickets {
  String key;
  String typeofTicket;
  String subject;
  String time;
  String numberOfTicket;
  bool completed;
  String userId;

  Tickets(this.typeofTicket ,this.subject, this.time , this.numberOfTicket ,  this.userId, this.completed);

  Tickets.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        userId = snapshot.value["userId"],
        typeofTicket =snapshot.value["typeofticket"],
        time =snapshot.value["time"],
        numberOfTicket =snapshot.value["numberOfticket"],
        subject = snapshot.value["subject"],
        completed = snapshot.value["completed"];

  toJson() {
    return {
      "completed": completed,
      "time": time,
      "numberOfTicket": numberOfTicket,
      "subject": subject,
      "typeofticket": typeofTicket,
      "userId": userId,

    };
  }
}