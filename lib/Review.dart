import 'package:firebase_database/firebase_database.dart';

class ThomasReview {
  String key;
  String subject;

  ThomasReview(this.subject,);

  ThomasReview.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,

        subject = snapshot.value["subject"];

  toJson() {
    return {
      "subject": subject,
    };
  }
}

class KwakuReview {
  String key;

  String subject;



  KwakuReview(this.subject );

  KwakuReview.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,

        subject = snapshot.value["subject"];

  toJson() {
    return {

      "subject": subject,


    };
  }
}

class YaoReview {
  String key;
  String subject;



  YaoReview(this.subject);

  YaoReview.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,

        subject = snapshot.value["subject"];

  toJson() {
    return {

      "subject": subject,

    };
  }
}

class KingReview {
  String key;

  String subject;

  KingReview(this.subject);

  KingReview.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,

        subject = snapshot.value["subject"];


  toJson() {
    return {
      "subject": subject,

    };
  }
}