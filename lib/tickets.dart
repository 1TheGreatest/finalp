import 'package:firebase_database/firebase_database.dart';

class TransportTickets {
  String key;
  String typeofTicket;
  String subject;
  String time;
  String numberOfTicket;
  String amountPaid;
  String completed;
  String date;
  String userId;

  TransportTickets(this.typeofTicket ,this.subject, this.time , this.numberOfTicket ,this.amountPaid ,this.date, this.userId,  this.completed);

  TransportTickets.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        userId = snapshot.value["userId"],
        typeofTicket =snapshot.value["typeofticket"],
        subject = snapshot.value["subject"],
        time =snapshot.value["time"],
        numberOfTicket =snapshot.value["numberOfTicket"],
        date = snapshot.value["Date"],
        amountPaid = snapshot.value['amountPaid'],
        completed = snapshot.value["completed"];

  toJson() {
    return {
      "completed": completed,
      "time": time,
      "numberOfTicket": numberOfTicket,
      "amountPaid": amountPaid,
      "subject": subject,
      "Date": date,
      "typeofticket": typeofTicket,
      "userId": userId,

    };
  }
}

class MovieTickets {
  String key;
  String typeofTicket;
  String subject;
  String time;
  String cinemaRoom;
  String numberOfTicket;
  String amountPaid;
  String date;
  String completed;
  String userId;

  MovieTickets(this.typeofTicket ,this.subject, this.time , this.cinemaRoom, this.numberOfTicket ,this.amountPaid,this.date, this.userId, this.completed);

  MovieTickets.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        userId = snapshot.value["userId"],
        typeofTicket =snapshot.value["typeofticket"],
        subject = snapshot.value["subject"],
        time =snapshot.value["time"],
        cinemaRoom = snapshot.value["cinemaRoom"],
        numberOfTicket =snapshot.value["numberOfTicket"],
        amountPaid = snapshot.value['amountPaid'],
        date =snapshot.value["date"],
        completed = snapshot.value["completed"];

  toJson() {
    return {
      "completed": completed,
      "time": time,
      "cinemaRoom": cinemaRoom,
      "numberOfTicket": numberOfTicket,
      "amountPaid": amountPaid,
      "subject": subject,
      "typeofticket": typeofTicket,
      "date": date,
      "userId": userId,

    };
  }
}

class FoodTickets {
  String key;
  String typeofTicket;
  String subject;
  String numberOfTicket;
  String size;
  String amountPaid;
  String completed;
  String userId;

  FoodTickets(this.typeofTicket ,this.subject, this.size, this.numberOfTicket , this.amountPaid , this.userId, this.completed);

  FoodTickets.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        userId = snapshot.value["userId"],
        typeofTicket =snapshot.value["typeofticket"],
        subject = snapshot.value["subject"],
        numberOfTicket =snapshot.value["numberOfTicket"],
        size = snapshot.value["size"],
        amountPaid = snapshot.value['amountPaid'],
        completed = snapshot.value["completed"];

  toJson() {
    return {
      "completed": completed,
      "numberOfTicket": numberOfTicket,
      "amountPaid": amountPaid,
      "size": size,
      "subject": subject,
      "typeofticket": typeofTicket,
      "userId": userId,

    };
  }
}