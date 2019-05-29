import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'tickets.dart';
import 'users.dart';
import 'dart:ui' as ui;
import 'package:flutter_ticket_widget/flutter_ticket_widget.dart';
//import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http ;
//import 'main.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import "package:easy_dialogs/easy_dialogs.dart";
//import 'counter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:pref_dessert/pref_dessert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'TransportDialogContent.dart';
import 'MovieDialogContent.dart';
import 'FoodDialogContent.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'Review.dart';



class MainHome extends StatefulWidget {
  MainHome({Key key, this.auth,this.userId, this.onSignedOut});

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new MainHomeState();
//MainHomeState createState() => MainHomeState();
}

class MainHomeState extends State<MainHome> {


  String transportOne = 'Accra   >>>>>   Kumasi';
  String transportTwo = 'Accra   >>>>>   Cape Coast';
  String transportThree = 'Accra   >>>>>   Takoradi';
  String transportFour = 'Accra   >>>>>   Suyani';
  String transportFive = 'Accra   >>>>>   Ho';

  int transportFareOne = 45;
  int transportFareTwo = 30;
  int transportFareThree = 40;
  int transportFareFour = 55;
  int transportFareFive = 40;

  String foodOne = 'Fried Rice with Grilled Chicken';
  String foodTwo = 'Jollof rice with Chicken ';
  String foodThree = 'Fries with Chicken Wings';
  String foodFour = 'Meat-Lovers Pizza';
  String foodFive = 'Banku with Tilapia';

  int foodFareOne = 25;
  int foodFareTwo = 30;
  int foodFareThree = 20;
  int foodFareFour = 40;
  int foodFareFive = 20;

  String userActivity = "Choose Time";
  int userActivity1 = 1;

  final numberController =  TextEditingController();

  final reviewController =  TextEditingController();

  DateTime selectedDate = DateTime.now();
  DateTime dateSelected;
  InputType inputType = InputType.both;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2018, 8),
        lastDate: DateTime(2020));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dateSelected = picked;
      });
    selectedDate = DateTime.now();
  }

  int totalCost;
  String mobNumber;


  List<TransportTickets> _transportTicketsList;
  List<MovieTickets> _movieTicketsList;
  List<FoodTickets> _foodTicketsList;

  List<ThomasReview> _thomasReviewList;
  List<KwakuReview> _kwakuReviewList;
  List<YaoReview> _yaoReviewList;
  List<KingReview> _kingReviewList;


  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _transportTicketsQuery;
  Query _movieTicketsQuery;
  Query _foodTicketsQuery;

  Query _thomasReviewQuery;
  Query _kwakuReviewQuery;
  Query _yaoReviewQuery;
  Query _kingReviewQuery;

  int _currentIndex = 0;

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  @override
  var movies;
  Color mainColor = const Color(0xff01A0C7);

  void getData() async {
    var data = await getJson();
    setState(() {
      movies = data['results'];
    });
  }



  Widget callPage(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return _servicePage();
      case 1:
        return _proFile();

        break;
      default:
        return _servicePage();
    }
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();


    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('on message message');
        },
      onResume: (Map<String, dynamic> message) {
        print('on resume message');
        },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch message');
        },
    );
    firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    firebaseMessaging.onIosSettingsRegistered.listen((IosNotificationSettings setting){
      print('Ios setting registed');
    });
    firebaseMessaging.getToken().then((token) {
      print(token);
    });

    _transportTicketsList = new List();
    _movieTicketsList = new List();
    _foodTicketsList = new List();

    _thomasReviewList = new List();
    _kwakuReviewList = new List();
    _yaoReviewList = new List();
    _kingReviewList = new List();

    _transportTicketsQuery = _database
        .reference()
        .child("transport tickets")
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onTodoAddedSubscription = _transportTicketsQuery.onChildAdded.listen(_onEntryAdded);
    _onTodoChangedSubscription = _transportTicketsQuery.onChildChanged.listen(_onEntryChanged);

    _movieTicketsQuery = _database
        .reference()
        .child("movie tickets")
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onTodoAddedSubscription = _movieTicketsQuery.onChildAdded.listen(_monEntryAdded);
    _onTodoChangedSubscription = _movieTicketsQuery.onChildChanged.listen(_monEntryChanged);

    _foodTicketsQuery = _database
        .reference()
        .child("food tickets")
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onTodoAddedSubscription = _foodTicketsQuery.onChildAdded.listen(_fonEntryAdded);
    _onTodoChangedSubscription = _foodTicketsQuery.onChildChanged.listen(_fonEntryChanged);

    _thomasReviewQuery = _database
        .reference()
        .child("thomas review");
    _onTodoAddedSubscription = _thomasReviewQuery.onChildAdded.listen(_tonEntryAdded);
    _onTodoChangedSubscription = _thomasReviewQuery.onChildChanged.listen(_tonEntryChanged);

    _kwakuReviewQuery = _database
        .reference()
        .child("kwaku review");
    _onTodoAddedSubscription = _kwakuReviewQuery.onChildAdded.listen(_kwonEntryAdded);
    _onTodoChangedSubscription = _kwakuReviewQuery.onChildChanged.listen(_kwonEntryChanged);

    _yaoReviewQuery = _database
        .reference()
        .child("yao review");
    _onTodoAddedSubscription = _yaoReviewQuery.onChildAdded.listen(_yonEntryAdded);
    _onTodoChangedSubscription = _yaoReviewQuery.onChildChanged.listen(_yonEntryChanged);

    _kingReviewQuery = _database
        .reference()
        .child("king review");
    _onTodoAddedSubscription = _kingReviewQuery.onChildAdded.listen(_konEntryAdded);
    _onTodoChangedSubscription = _kingReviewQuery.onChildChanged.listen(_konEntryChanged);


  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  _fonEntryChanged(Event event) {
    var oldEntry = _foodTicketsList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _foodTicketsList[_foodTicketsList.indexOf(oldEntry)] = FoodTickets.fromSnapshot(event.snapshot);
    });
  }

  _fonEntryAdded(Event event) {
    setState(() {
      _foodTicketsList.add(FoodTickets.fromSnapshot(event.snapshot));
    });
  }

  _monEntryChanged(Event event) {
    var oldEntry = _movieTicketsList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _movieTicketsList[_movieTicketsList.indexOf(oldEntry)] = MovieTickets.fromSnapshot(event.snapshot);
    });
  }

  _monEntryAdded(Event event) {
    setState(() {
      _movieTicketsList.add(MovieTickets.fromSnapshot(event.snapshot));
    });
  }

  _onEntryChanged(Event event) {
    var oldEntry = _transportTicketsList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _transportTicketsList[_transportTicketsList.indexOf(oldEntry)] = TransportTickets.fromSnapshot(event.snapshot);
    });
  }

  _onEntryAdded(Event event) {
    setState(() {
      _transportTicketsList.add(TransportTickets.fromSnapshot(event.snapshot));
    });
  }

  _tonEntryChanged(Event event) {
    var oldEntry = _thomasReviewList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _thomasReviewList[_thomasReviewList.indexOf(oldEntry)] = ThomasReview.fromSnapshot(event.snapshot);
    });
  }

  _tonEntryAdded(Event event) {
    setState(() {
      _thomasReviewList.add(ThomasReview.fromSnapshot(event.snapshot));
    });
  }

  _kwonEntryChanged(Event event) {
    var oldEntry = _kwakuReviewList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _kwakuReviewList[_kwakuReviewList.indexOf(oldEntry)] = KwakuReview.fromSnapshot(event.snapshot);
    });
  }

  _kwonEntryAdded(Event event) {
    setState(() {
      _kwakuReviewList.add(KwakuReview.fromSnapshot(event.snapshot));
    });
  }

  _yonEntryChanged(Event event) {
    var oldEntry = _yaoReviewList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _yaoReviewList[_yaoReviewList.indexOf(oldEntry)] = YaoReview.fromSnapshot(event.snapshot);
    });
  }

  _yonEntryAdded(Event event) {
    setState(() {
      _yaoReviewList.add(YaoReview.fromSnapshot(event.snapshot));
    });
  }

  _konEntryChanged(Event event) {
    var oldEntry = _kingReviewList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _kingReviewList[_kingReviewList.indexOf(oldEntry)] = KingReview.fromSnapshot(event.snapshot);
    });
  }

  _konEntryAdded(Event event) {
    setState(() {
      _kingReviewList.add(KingReview.fromSnapshot(event.snapshot));
    });
  }



  _addTReview(String reviewContent) {
    if (reviewContent.length > 0) {
      ThomasReview todo = new ThomasReview(reviewContent.toString() );
      _database.reference().child("thomas review").push().set(todo.toJson());
    }
  }
  _addKwReview( String reviewContent) {
    if (reviewContent.length > 0) {
      KwakuReview todo = new KwakuReview(reviewContent.toString() );
      _database.reference().child("kwaku review").push().set(todo.toJson());
    }
  }
  _addYReview(String reviewContent) {
    if (reviewContent.length > 0) {
      YaoReview todo = new YaoReview(reviewContent.toString() );
      _database.reference().child("yao review").push().set(todo.toJson());
    }
  }
  _addKiReview(String reviewContent) {
    if (reviewContent.length > 0) {
      KingReview todo = new KingReview(reviewContent.toString() );
      _database.reference().child("king review").push().set(todo.toJson());
    }
  }




  _updateTransport (TransportTickets tickets){
    //Toggle completed
    tickets.completed = "Successful";
    if (tickets != null) {
      _database.reference().child("transport tickets").child(tickets.key).set(tickets.toJson());
    }
  }

  _updateMovie(MovieTickets tickets){
    //Toggle completed
    tickets.completed = "Successful";
    if (tickets != null) {
      _database.reference().child("movie tickets").child(tickets.key).set(tickets.toJson());
    }
  }

  _updateFood (FoodTickets tickets){
    //Toggle completed
    tickets.completed = "Successful";
    if (tickets != null) {
      _database.reference().child("food tickets").child(tickets.key).set(tickets.toJson());
    }
  }

  _deleteTodo(String ticketsId, int index) {
    _database.reference().child("transport tickets").child(ticketsId).remove().then((_) {
      print("Delete $ticketsId successful");
      setState(() {
        _transportTicketsList.removeAt(index);
      });
    });
  }





  _showTicketDetailsDialog( String subject,String typeofTicket, String time,String numberOfTicket,String amountPaid, String date) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {

          return new Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: true,
                //`true` if you want Flutter to automatically add Back Button when needed,
                //or `false` if you want to force your own back button every where
                leading: IconButton(icon:Icon(Icons.arrow_back),
                  onPressed:() => Navigator.pop(context),
                )
            ),

            backgroundColor: Colors.white.withOpacity(0.4),
            body: Center(
              child: FlutterTicketWidget(
                width: 350.0,
                height: 350.0,
                isCornerRounded: true,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 9.0, 20.0, 0.0) ,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Column(
                              children:<Widget>[
                                Container(
                                  padding: EdgeInsets.fromLTRB(9.0, 3.0, 9.0, 0.0) ,
                                  child:Text(typeofTicket , style:TextStyle(fontSize:12.0),textAlign: TextAlign.center,),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(9.0, 3.0, 9.0, 0.0) ,
                                  child:Text(subject , style:TextStyle(fontSize:17.0,fontWeight:FontWeight.bold), textAlign: TextAlign.center ),
                                )
                              ],
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child:ShaderMask(
                            shaderCallback:(rect){
                              return LinearGradient(
                                begin:Alignment.topCenter,
                                end:Alignment.bottomCenter,
                                colors:[Colors.white,Colors.transparent],
                              ).createShader(Rect.fromLTRB(0,120,rect.width,rect.height));
                            },
                            blendMode:BlendMode.dstIn,
                            child: Image.asset('assets/location.jpg' ,fit:BoxFit.contain),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: Row(
                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              _ticketContent('DATE', date, 'No. of Tickets', numberOfTicket,' ($amountPaid)'),
                              _ticketContent('TIME', time, 'Amount Paid', amountPaid,''),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 80.0, left: 30.0, right: 30.0),
                          child: new Container(
                            width: 250.0,
                            height: 60.0,

                          ),

                        ),

                        Padding(
                          padding:
                          const EdgeInsets.fromLTRB(80.0, 10.0, 30.0, 10.0),
                          //child: Text( todoId, style: TextStyle(color: Colors.black,fontSize: 11.0) ,textAlign: TextAlign.center,),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
    );





  }

  _showMovieTicketDetailsDialog( String subject,String typeofTicket, String time,String numberOfTicket,String amountPaid, String cinemaRoom, String date) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {

          return new Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: true,
                //`true` if you want Flutter to automatically add Back Button when needed,
                //or `false` if you want to force your own back button every where
                leading: IconButton(icon:Icon(Icons.arrow_back),
                  onPressed:() => Navigator.pop(context),
                )
            ),

            backgroundColor: Colors.white.withOpacity(0.4),
            body: Center(
              child: FlutterTicketWidget(
                width: 350.0,
                height: 350.0,
                isCornerRounded: true,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 9.0, 20.0, 0.0) ,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Column(
                              children:<Widget>[
                                Container(
                                  padding: EdgeInsets.fromLTRB(9.0, 3.0, 9.0, 0.0) ,
                                  child:Text(typeofTicket , style:TextStyle(fontSize:12.0),textAlign: TextAlign.center,),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(9.0, 3.0, 9.0, 0.0) ,
                                  child:Text(subject , style:TextStyle(fontSize:17.0,fontWeight:FontWeight.bold), textAlign: TextAlign.center ),
                                )
                              ],
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child:ShaderMask(
                            shaderCallback:(rect){
                              return LinearGradient(
                                begin:Alignment.topCenter,
                                end:Alignment.bottomCenter,
                                colors:[Colors.white,Colors.transparent],
                              ).createShader(Rect.fromLTRB(0,120,rect.width,rect.height));
                            },
                            blendMode:BlendMode.dstIn,
                            child: Image.asset('assets/cinematicketimage.jpg' ,fit:BoxFit.scaleDown ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: Row(
                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              _ticketContent('DATE', date , 'No. of Tickets', numberOfTicket,' ($amountPaid)'),
                              _ticketContent('TIME', time, 'Cinema Room', cinemaRoom,''),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 80.0, left: 30.0, right: 30.0),
                          child: new Container(
                            width: 250.0,
                            height: 60.0,

                          ),

                        ),

                        Padding(
                          padding:
                          const EdgeInsets.fromLTRB(80.0, 10.0, 30.0, 10.0),
                          //child: Text( todoId, style: TextStyle(color: Colors.black,fontSize: 11.0) ,textAlign: TextAlign.center,),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
    );





  }

  _showFoodTicketDetailsDialog( String subject,String typeofTicket, String numberOfPacks ,String amountPaid, String size) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {

          return new Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: true,
                //`true` if you want Flutter to automatically add Back Button when needed,
                //or `false` if you want to force your own back button every where
                leading: IconButton(icon:Icon(Icons.arrow_back),
                  onPressed:() => Navigator.pop(context),
                )
            ),

            backgroundColor: Colors.white.withOpacity(0.4),
            body: Center(
              child: FlutterTicketWidget(
                width: 350.0,
                height: 350.0,
                isCornerRounded: true,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 9.0, 20.0, 0.0) ,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Column(
                              children:<Widget>[
                                Container(
                                  padding: EdgeInsets.fromLTRB(9.0, 3.0, 9.0, 0.0) ,
                                  child:Text(typeofTicket , style:TextStyle(fontSize:12.0),textAlign: TextAlign.center,),
                                ),
                                Container(
                                  padding: EdgeInsets.fromLTRB(9.0, 3.0, 9.0, 0.0) ,
                                  child:Text(subject , style:TextStyle(fontSize:17.0,fontWeight:FontWeight.bold), textAlign: TextAlign.center ),
                                )
                              ],
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child:ShaderMask(
                            shaderCallback:(rect){
                              return LinearGradient(
                                begin:Alignment.topCenter,
                                end:Alignment.bottomCenter,
                                colors:[Colors.white,Colors.transparent],
                              ).createShader(Rect.fromLTRB(0,120,rect.width,rect.height));
                            },
                            blendMode:BlendMode.dstIn,
                            child: Image.asset('assets/meatloverspizza.jpg' ,fit:BoxFit.contain),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: Row(
                            mainAxisAlignment:MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              _ticketContent('Size',size, 'No. of Packs', numberOfPacks,' ($amountPaid)'),
                              _ticketContent('Destination', 'sowo', '','',''),
                            ],
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(top: 80.0, left: 30.0, right: 30.0),
                          child: new Container(
                            width: 250.0,
                            height: 60.0,

                          ),

                        ),

                        Padding(
                          padding:
                          const EdgeInsets.fromLTRB(80.0, 10.0, 30.0, 10.0),
                          //child: Text( todoId, style: TextStyle(color: Colors.black,fontSize: 11.0) ,textAlign: TextAlign.center,),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
    );





  }

  _ticketContent(t1,d1,t2,d2,d11) {
    return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[

            Container(
                padding: EdgeInsets.only(
                    left: 1.0, right: 1.0, top: 2, bottom: 0),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                          left: 9.0, right: 9.0, top: 6, bottom: 6),
                      child: Text(t1, style: TextStyle(fontSize: 9.0)),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 9.0, right: 9.0, top: 6, bottom: 6),
                      child: Text(d1, style: TextStyle(fontSize: 10.0,)),
                    )
                  ],
                )
            ),

            Container(
                padding: EdgeInsets.only(
                    left: 1.0, right: 1.0, top: 2, bottom: 0),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(
                          left: 9.0, right: 9.0, top: 6, bottom: 6),
                      child: Text(t2, style: TextStyle(fontSize: 9.0)),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: 9.0, right: 9.0, top: 6, bottom: 6),
                      child: Text(d2+d11, style: TextStyle(fontSize: 10.0,)),
                    )
                  ],
                )
            ),

          ],
        )
    );
  }


  _showTicketList() {
    if (_transportTicketsList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _transportTicketsList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId = _transportTicketsList[index].key;
            String typeofTicket = _transportTicketsList[index].typeofTicket;
            String numberOfTicket = _transportTicketsList[index].numberOfTicket;
            String time = _transportTicketsList[index].time;
            String amountPaid = _transportTicketsList[index].amountPaid;
            String subject = _transportTicketsList[index].subject;
            String date = _transportTicketsList[index].date;
            String completed = _transportTicketsList[index].completed;
            String userId = _transportTicketsList[index].userId;
            return Dismissible(
              key: Key(todoId),
              background: Container(color: Colors.red),
              onDismissed: (direction) async {
                _deleteTodo(todoId, index);
              },
              child: GestureDetector(
                  child: ListTile(
                    title: Text(
                      subject,
                      style: TextStyle(fontSize: 20.0),
                    ),
                    trailing: GestureDetector(
                      child: Text(
                        completed,
                          /*icon: (completed !='Successful')
                              ? Icon(
                            Icons.done_outline,
                            color: Colors.green,
                            size: 20.0,
                          )
                              : Icon(Icons.done, color: Colors.grey, size: 20.0),
                        icon: (completed =='Successful')
                            ? Icon(Icons.done, color: Colors.grey, size: 20.0)
                            : Icon(Icons.done_outline,color: Colors.green,size: 20.0,
                      )*/
                      ),
                       onTap: () {
                            setState(() {
                              _updateTransport (_transportTicketsList[index]);
                            });
                      }
                    ),
                  ),
                  onTap: () => _showTicketDetailsDialog(subject.toString() ,typeofTicket.toString() , time.toString(), numberOfTicket.toString() ,amountPaid.toString(), date.toString() )
              ),


            );

          });
    } else {
      return Center(child: Text("Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.0),));
    }
  }

  _showMovieTicketList() {
    if (_movieTicketsList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _movieTicketsList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId = _movieTicketsList[index].key;
            String typeofTicket = _movieTicketsList[index].typeofTicket;
            String numberOfTicket = _movieTicketsList[index].numberOfTicket;
            String cinemaRoom = _movieTicketsList[index].cinemaRoom;
            String amountPaid = _movieTicketsList[index].amountPaid;
            String time = _movieTicketsList[index].time;
            String subject = _movieTicketsList[index].subject;
            String date = _movieTicketsList[index].date;
            String completed = _movieTicketsList[index].completed;
            String userId = _movieTicketsList[index].userId;

            return Dismissible(
              key: Key(todoId),
              background: Container(color: Colors.red),
              onDismissed: (direction) async {
                _deleteTodo(todoId, index);
              },
              child: GestureDetector(
                  child: ListTile(
                    title: Text(
                      subject,
                      style: TextStyle(fontSize: 20.0),
                    ),
                    trailing:  GestureDetector(
                      child: Text(
                        completed,
                        /*icon: (completed !='Successful')
                              ? Icon(
                            Icons.done_outline,
                            color: Colors.green,
                            size: 20.0,
                          )
                              : Icon(Icons.done, color: Colors.grey, size: 20.0),
                        icon: (completed =='Successful')
                            ? Icon(Icons.done, color: Colors.grey, size: 20.0)
                            : Icon(Icons.done_outline,color: Colors.green,size: 20.0,
                      )*/
                      ),
                         onTap: () {
                            setState(() {
                              _updateMovie (_movieTicketsList[index]);
                            });

                          }
                       ),
                  ),
                  onTap: () => _showMovieTicketDetailsDialog(subject.toString() ,typeofTicket.toString() , time.toString(), numberOfTicket.toString() ,amountPaid.toString(),cinemaRoom.toString(), date.toString() )
              ),


            );

          });
    } else {
      return Center(child: Text("Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.0),));
    }
  }

  _showFoodTicketList() {
    if (_foodTicketsList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _foodTicketsList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId = _foodTicketsList[index].key;
            String typeofTicket = _foodTicketsList[index].typeofTicket;
            String numberOfPacks = _foodTicketsList[index].numberOfTicket;
            String size = _foodTicketsList[index].size;
            String amountPaid = _foodTicketsList[index].amountPaid;
            String subject = _foodTicketsList[index].subject;
            String completed = _foodTicketsList[index].completed;
            String userId = _foodTicketsList[index].userId;


            return Dismissible(
              key: Key(todoId),
              background: Container(color: Colors.red),
              onDismissed: (direction) async {
                _deleteTodo(todoId, index);
              },
              child: GestureDetector(
                  child: ListTile(
                    title: Text(
                      subject,
                      style: TextStyle(fontSize: 20.0),
                    ),
                    trailing: GestureDetector(
                      child: Text(
                        completed,
                        /*icon: (completed !='Successful')
                              ? Icon(
                            Icons.done_outline,
                            color: Colors.green,
                            size: 20.0,
                          )
                              : Icon(Icons.done, color: Colors.grey, size: 20.0),
                        icon: (completed =='Successful')
                            ? Icon(Icons.done, color: Colors.grey, size: 20.0)
                            : Icon(Icons.done_outline,color: Colors.green,size: 20.0,
                      )*/
                      ),
                        onTap: () {
                            setState(() {
                              _updateFood (_foodTicketsList[index]);
                            });

                          }
                    ),
                  ),
                  onTap: () => _showFoodTicketDetailsDialog(subject,typeofTicket,numberOfPacks, amountPaid ,size)
              ),


            );

          });
    } else {
      return Center(child: Text("Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.0),));
    }
  }


  _showThomasReview() {
    if (_thomasReviewList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _thomasReviewList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId = _thomasReviewList[index].key;
            String subject = _thomasReviewList[index].subject;
            return Container(
              child: GestureDetector(
                  child: ListTile(
                    title: Text(
                      subject,
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  onTap: () {}
              ),


            );

          });
    } else {
      return Center(child: Text("No Reviews yet",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.0),));
    }
  }

  _showKwakuReview() {
    if (_kwakuReviewList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _kwakuReviewList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId = _kwakuReviewList[index].key;
            String subject = _kwakuReviewList[index].subject;
            return Container(
              child: GestureDetector(
                  child: ListTile(
                    title: Text(
                      subject,
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  onTap: () {}
              ),


            );

          });
    } else {
      return Center(child: Text("No Reviews yet",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.0),));
    }
  }

  _showYaoReview() {
    if (_yaoReviewList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _yaoReviewList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId = _yaoReviewList[index].key;
            String subject = _yaoReviewList[index].subject;
            return Container(
              child: GestureDetector(
                  child: ListTile(
                    title: Text(
                      subject,
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  onTap: () {}
              ),


            );

          });
    } else {
      return Center(child: Text("No Reviews yet",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.0),));
    }
  }

  _showKingReview() {
    if (_kingReviewList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _kingReviewList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId = _kingReviewList[index].key;
            String subject = _kingReviewList[index].subject;
            return Container(
              child: GestureDetector(
                  child: ListTile(
                    title: Text(
                      subject,
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  onTap: () {}
              ),


            );

          });
    } else {
      return Center(child: Text("No Reviews yet",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20.0),));
    }
  }










  Widget _showUsername() {

      return Text("   Welcome " ,
        style: new TextStyle(color: Colors.white ,fontFamily: 'Arvo',
            fontWeight: FontWeight.bold,fontStyle: FontStyle.italic)
        ,);

  }

  Widget _showContact() {
    {
      return Container(
        color: Colors.white,
        margin: const EdgeInsets.all(2.0),
        child: Column(
          children: <Widget>[
            new ListTile(
                leading: Icon(Icons.call),
                title: Text('Contact 0248560299 for delivery within Accra'),
                onTap: () {}
            ),
            Container(
              width: 300.0,
              height: 0.5,
              color: const Color(0xD2D2E1ff),
              margin: const EdgeInsets.fromLTRB(4.0,0.0,4.0,0.0),
            ),
            new ListTile(
                leading: Icon(Icons.call),
                title: Text('Contact 055560255 for delivery outside Accra'),
                onTap: () {}
            ),
            Container(
              width: 300.0,
              height: 0.5,
              color: const Color(0xD2D2E1ff),
              margin: const EdgeInsets.fromLTRB(4.0,0.0,4.0,0.0),
            ),

          ],
        ),
      );
    }
  }

  Widget _showKumasiPersonnel() {
    {
      return Container(
        color: Colors.white,
        margin: const EdgeInsets.all(2.0),
        child: Column(
          children: <Widget>[
            new ListTile(
                leading: Icon(Icons.person),
                title: Text('Thomas Agyare \n 0247514302',style: new TextStyle(color: Colors.black ,fontFamily: 'Arvo',
                    fontWeight: FontWeight.bold,fontSize: 16.0 )
                ),
                trailing: Text("Review", style: new TextStyle(fontSize: 12.0),),
                contentPadding: EdgeInsets.fromLTRB(
                    5.0, 15.0, 20.0, 10.0),
                onTap: () => _thomasReview(),
            ),
            Container(
              width: 300.0,
              height: 0.5,
              color: const Color(0xD2D2E1ff),
              margin: const EdgeInsets.fromLTRB(4.0,0.0,4.0,0.0),
            ),

            new ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Kwaku Adusei \n 0557413698',style: new TextStyle(color: Colors.black,fontFamily: 'Arvo',
                      fontWeight: FontWeight.bold,fontSize: 16.0 )
                  ),
                trailing: Text("Review", style: new TextStyle(fontSize: 12.0),),
                contentPadding: EdgeInsets.fromLTRB(
                    5.0, 15.0, 20.0, 10.0),
                  onTap: () => _kwakuReview(),
              ),

            Container(
              width: 300.0,
              height: 0.5,
              color: const Color(0xD2D2E1ff),
              margin: const EdgeInsets.fromLTRB(4.0,0.0,4.0,0.0),
            ),

          ],
        ),
      );
    }
  }

  Widget _showOutsidePersonnel() {
    {
      return Container(
        color: Colors.white,
        margin: const EdgeInsets.all(2.0),
        child: Column(
          children: <Widget>[

            new ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Yao Senyo \n 0264318702',style: new TextStyle(color: Colors.black ,fontFamily: 'Arvo',
                      fontWeight: FontWeight.bold,fontSize: 16.0 )
                  ),
                trailing: Text("Review", style: new TextStyle(fontSize: 12.0),),
                contentPadding: EdgeInsets.fromLTRB(
                    5.0, 15.0, 20.0, 10.0),
              onTap: () => _yaoReview(),
              ),

            Container(
              width: 300.0,
              height: 0.5,
              color: const Color(0xD2D2E1ff),
              margin: const EdgeInsets.fromLTRB(4.0,0.0,4.0,0.0),
            ),

            new ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Kingsley Boakye \n 0573297530',style: new TextStyle(color: Colors.black ,fontFamily: 'Arvo',
                      fontWeight: FontWeight.bold,fontSize: 16.0 )),
                trailing: Text("Review", style: new TextStyle(fontSize: 12.0),),
                contentPadding: EdgeInsets.fromLTRB(
                    5.0, 15.0, 20.0, 10.0),
              onTap: () => _kingReview(),
              ),

            Container(
              width: 300.0,
              height: 0.5,
              color: const Color(0xD2D2E1ff),
              margin: const EdgeInsets.fromLTRB(4.0,0.0,4.0,0.0),
            ),

          ],
        ),
      );
    }
  }



  _thomasReview() async {
    await showDialog(
        context: context,
        builder: (BuildContext context){
      return new Scaffold(
        appBar: new AppBar(
          centerTitle: true,
          backgroundColor: Color(0xff01A0C7),
          title: new Text(
            ' Review ',
            style: new TextStyle(color: Colors.white,
              fontFamily: 'Arvo',
              fontWeight: FontWeight.bold,),
          ),

        ),

        body: new Column(
          children: <Widget>[
            new Expanded(
              flex:7,
                child: new Container(
                  child: _showThomasReview(),
                )

            ),
            new Expanded(
                flex:3,
                child:
                new Container(
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                          flex:8,
                          child: new TextField(
                            maxLines: 4,
                            controller: reviewController,
                            keyboardType: TextInputType.text,
                            autofocus: false,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                border:
                                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
                            ),
                          ),
                      ),
                      new Expanded(
                          flex:2,
                          child:
                          new RaisedButton(
                              color: Color(0xff01A0C7),
                              child: new Text('Submit',
                                  style: new TextStyle(
                                      fontSize: 15.0, color: Colors.white)),
                              onPressed: () {
                                _addTReview(reviewController.text);
                                reviewController.clear();
                              }
                          ),
                      ),
                    ],
                  ),
                )
            ),

          ],
        )





      );

    },
    );
  }

  _kwakuReview() async {
    await showDialog(
      context: context,
      builder: (BuildContext context){
        return new Scaffold(
            appBar: new AppBar(
              centerTitle: true,
              backgroundColor: Color(0xff01A0C7),
              title: new Text(
                ' Review ',
                style: new TextStyle(color: Colors.white,
                  fontFamily: 'Arvo',
                  fontWeight: FontWeight.bold,),
              ),

            ),

            body: new Column(
              children: <Widget>[
                new Expanded(
                    flex:7,
                    child: new Container(
                      child: _showKwakuReview(),
                    )

                ),
                new Expanded(
                    flex:3,
                    child:
                    new Container(
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                            flex:8,
                            child: new TextField(
                              maxLines: 4,
                              controller: reviewController,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                  border:
                                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
                              ),
                            ),
                          ),
                          new Expanded(
                            flex:2,
                            child:
                            new RaisedButton(
                                color: Color(0xff01A0C7),
                                child: new Text('Submit',
                                    style: new TextStyle(
                                        fontSize: 15.0, color: Colors.white)),
                                onPressed: () {
                                  _addKwReview(reviewController.text);
                                  reviewController.clear();

                                }
                            ),
                          ),
                        ],
                      ),
                    )
                ),

              ],
            )
        );

      },
    );
  }

  _yaoReview() async {
    await showDialog(
      context: context,
      builder: (BuildContext context){
        return new Scaffold(
            appBar: new AppBar(
              centerTitle: true,
              backgroundColor: Color(0xff01A0C7),
              title: new Text(
                ' Review ',
                style: new TextStyle(color: Colors.white,
                  fontFamily: 'Arvo',
                  fontWeight: FontWeight.bold,),
              ),

            ),

            body: new Column(
              children: <Widget>[
                new Expanded(
                    flex:7,
                    child:new Container(
                      child: _showYaoReview(),
                    )

                ),
                new Expanded(
                    flex:3,
                    child:
                    new Container(
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                            flex:8,
                            child: new TextField(
                              maxLines: 4,
                              controller: reviewController,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                  border:
                                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
                              ),
                            ),
                          ),
                          new Expanded(
                            flex:2,
                            child:
                            new RaisedButton(
                                color: Color(0xff01A0C7),
                                child: new Text('Submit',
                                    style: new TextStyle(
                                        fontSize: 15.0, color: Colors.white)),
                                onPressed: () {
                                  _addYReview(reviewController.text);
                                  reviewController.clear();
                                }
                            ),
                          ),
                        ],
                      ),
                    )
                ),

              ],
            )

        );

      },
    );
  }

  _kingReview() async {
    await showDialog(
      context: context,
      builder: (BuildContext context){
        return new Scaffold(
            appBar: new AppBar(
              centerTitle: true,
              backgroundColor: Color(0xff01A0C7),
              title: new Text(
                ' Review ',
                style: new TextStyle(color: Colors.white,
                  fontFamily: 'Arvo',
                  fontWeight: FontWeight.bold,),
              ),

            ),

            body: new Column(
              children: <Widget>[
                new Expanded(
                    flex:7,
                    child: new Container(
                      child: _showKingReview(),
                    )

                ),
                new Expanded(
                    flex:3,
                    child:
                    new Container(
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                            flex:8,
                            child: new TextField(
                              maxLines: 4,
                              controller: reviewController,
                              keyboardType: TextInputType.text,
                              autofocus: false,
                              decoration: InputDecoration(
                                  contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                  border:
                                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
                              ),
                            ),
                          ),
                          new Expanded(
                            flex:2,
                            child:
                            new RaisedButton(
                                color: Color(0xff01A0C7),
                                child: new Text('Submit',
                                    style: new TextStyle(
                                        fontSize: 15.0, color: Colors.white)),
                                onPressed: () {
                                  _addKiReview(reviewController.text);
                                  reviewController.clear();
                                }
                            ),
                          ),
                        ],
                      ),
                    )
                ),

              ],
            )





        );

      },
    );
  }



  Widget _proFile() {

    return new Scaffold(

      body: new Container(
        color: Colors.white,

        child: new Column(
          children: <Widget>[

            Expanded(
              flex: 3, // 40%
              child: Container(
                  color: Color(0xff01A0C7),

                  child: new Column(
                    children: <Widget>[


                      Expanded(flex: 3,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
                          color: Color(0xff01A0C7),
                          child: Center(
                            child: _showUsername(),
                          ),
                        ),
                      ),

                      Expanded(flex: 7,
                        child: Container(
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            radius: 50.0,
                            child: Icon(Icons.person, size: 100.0, color: Colors.white.withOpacity(0.5) ,  ),
                          ),
                        ),
                      ),




                    ],
                  )

              ),
            ),


            Expanded(
              flex: 6, // 60%
              child: Container(
                color: Colors.white,
                margin: const EdgeInsets.all(2.0),
                child: Column(
                  children: <Widget>[
                    new ListTile(
                        leading: Icon(Icons.confirmation_number),
                        title: Text('Movie Tickets'),
                        onTap: () => _movieTickEts(context)
                    ),
                    Container(
                      width: 300.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(4.0,0.0,4.0,0.0),
                    ),
                    new ListTile(
                        leading: Icon(Icons.directions_bus),
                        title: Text('Transport Tickets'),
                        onTap: () => _tickEts(context)
                    ),
                    Container(
                      width: 300.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(4.0,0.0,4.0,0.0),
                    ),
                    new ListTile(
                        leading: Icon(Icons.fastfood),
                        title: Text('Food Tickets'),
                        onTap: () => _foodTickEts(context)
                    ),
                    Container(
                      width: 300.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(4.0,0.0,4.0,0.0),
                    ),
                    new ListTile(
                        leading: Icon(Icons.call),
                        title: Text('Contact us'),
                        onTap: () => _contactUs(context)
                    ),
                    Container(
                      width: 300.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(4.0,0.0,4.0,0.0),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );



  }


  _movieP(){
    return  new Center(
      child: FutureBuilder(
        future: buildText(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return CircularProgressIndicator(backgroundColor: Colors.blue);
          } else {
            return  new Padding(
              padding: const EdgeInsets.all(1.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new MovieTitle(mainColor),
                  new Expanded(
                    child: new ListView.builder(
                        itemCount: movies == null ? 0 : movies.length,
                        itemBuilder: (context, i) {
                          return  new FlatButton(

                              child: new MovieCell(movies,i),
                              padding: const EdgeInsets.all(0.0),
                              onPressed: () => _movieDetails(movies[i])/*{
                                  Navigator.push(context, new MaterialPageRoute(builder: (context){
                                    return new MovieDetail(movies[i]);
                                  }));
                                },*/
                            //color: Colors.white,
                          );
                        }),
                  )
                ],
              ),
            );
          }
        },
      ),
    );


}

  _transportP(){
    return  new Center(
      child: FutureBuilder(
        future: buildText(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return CircularProgressIndicator(backgroundColor: Colors.blue);
          } else {
            return new Container(
              child: SingleChildScrollView(
                child: new Column(
                  children: <Widget>[
                    new GestureDetector(
                        child: new Row(
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: new Container(
                                margin: const EdgeInsets.all(16.0),
                                child: new Container(
                                  width: 70.0,
                                  height: 70.0,
                                ),
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  image: new DecorationImage(
                                      image: new AssetImage(
                                          'assets/location.jpg'),
                                      fit: BoxFit.cover),
                                  boxShadow: [
                                    new BoxShadow(
                                        color: Colors.grey ,
                                        blurRadius: 5.0,
                                        offset: new Offset(2.0, 5.0))
                                  ],
                                ),
                              ),
                            ),

                            new Expanded(
                                child: new Container(
                                  margin: const
                                  EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                  child: new Column(children: [
                                    new Text(
                                      transportOne + '\n$transportFareOne GHS',
                                      style: new TextStyle(
                                        fontSize: 20.0,
                                        fontFamily: 'Arvo',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,),
                                )
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> TransportDialogContent(busTicket: 'Bus Ticket', transportLocation:transportOne.toString(), transportFare:transportFareOne.toInt(),userID:widget.userId.toString(),dateselected:dateSelected.toString() )));
                          //_showTransportTicketDialog('Bus Ticket' ,transportOne.toString(),transportFareOne.toInt()) ;
                          }


                    ),
                    new Container(
                      width: 300.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    ),

                    new GestureDetector(
                        child: new Row(
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: new Container(
                                margin: const EdgeInsets.all(16.0),
                                child: new Container(
                                  width: 70.0,
                                  height: 70.0,
                                ),
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  image: new DecorationImage(
                                      image: new AssetImage(
                                          'assets/location.jpg'),
                                      fit: BoxFit.cover),
                                  boxShadow: [
                                    new BoxShadow(
                                        color:Colors.grey ,
                                        blurRadius: 5.0,
                                        offset: new Offset(2.0, 5.0))
                                  ],
                                ),
                              ),
                            ),
                            new Expanded(
                                child: new Container(
                                  margin: const
                                  EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                  child: new Column(children: [
                                    new Text(
                                      transportTwo + '\n$transportFareTwo GHS',
                                      style: new TextStyle(
                                        fontSize: 20.0,
                                        fontFamily: 'Arvo',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,),
                                )
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>TransportDialogContent(busTicket: 'Bus Ticket', transportLocation:transportTwo.toString(), transportFare:transportFareTwo.toInt(), userID:widget.userId.toString(),dateselected:dateSelected.toString() )));
                          //_showTransportTicketDialog('Bus Ticket', transportTwo.toString(), transportFareTwo.toInt());
                        }
                    ),
                    new Container(
                      width: 300.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    ),

                    new GestureDetector(
                        child: new Row(
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: new Container(
                                margin: const EdgeInsets.all(16.0),
                                child: new Container(
                                  width: 70.0,
                                  height: 70.0,
                                ),
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  image: new DecorationImage(
                                      image: new AssetImage(
                                          'assets/location.jpg'),
                                      fit: BoxFit.cover),
                                  boxShadow: [
                                    new BoxShadow(
                                        color: Colors.grey ,
                                        blurRadius: 5.0,
                                        offset: new Offset(2.0, 5.0))
                                  ],
                                ),
                              ),
                            ),
                            new Expanded(
                                child: new Container(
                                  margin: const
                                  EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                  child: new Column(children: [
                                    new Text(
                                      transportThree + '\n$transportFareThree GHS',
                                      style: new TextStyle(
                                        fontSize: 20.0,
                                        fontFamily: 'Arvo',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,),
                                )
                            ),
                          ],
                        ),
                        onTap:() {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>TransportDialogContent(busTicket: 'Bus Ticket', transportLocation:transportThree.toString(), transportFare:transportFareThree.toInt(),userID:widget.userId.toString(), dateselected:dateSelected.toString() )));
                          //_showTransportTicketDialog('Bus Ticket', transportThree.toString(), transportFareThree.toInt());
                        }
                    ),
                    new Container(
                      width: 300.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    ),

                    new GestureDetector(
                        child: new Row(
                          children: <Widget>[
                            new Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: new Container(
                                margin: const EdgeInsets.all(16.0),
                                child: new Container(
                                  width: 70.0,
                                  height: 70.0,
                                ),
                                decoration: new BoxDecoration(
                                  borderRadius: new BorderRadius.circular(10.0),
                                  color: Colors.white,
                                  image: new DecorationImage(
                                      image: new AssetImage(
                                          'assets/location.jpg'),
                                      fit: BoxFit.cover),
                                  boxShadow: [
                                    new BoxShadow(
                                        color: Colors.grey ,
                                        blurRadius: 5.0,
                                        offset: new Offset(2.0, 5.0))
                                  ],
                                ),
                              ),
                            ),
                            new Expanded(
                                child: new Container(
                                  margin: const
                                  EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                  child: new Column(children: [
                                    new Text(
                                      transportFour + '\n$transportFareFour GHS',
                                      style: new TextStyle(
                                        fontSize: 20.0,
                                        fontFamily: 'Arvo',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,),
                                )
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>TransportDialogContent(busTicket: 'Bus Ticket', transportLocation:transportFour.toString(), transportFare:transportFareFour.toInt(), userID:widget.userId.toString(), dateselected:dateSelected.toString())));
                          //_showTransportTicketDialog('Bus Ticket', transportFour.toString(), transportFareFour.toInt());
                        }
                    ),
                    new Container(
                      width: 300.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    ),

                    new GestureDetector(
                      child: new Row(
                        children: <Widget>[
                          new Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: new Container(
                              margin: const EdgeInsets.all(16.0),
                              child: new Container(
                                width: 70.0,
                                height: 70.0,
                              ),
                              decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.circular(10.0),
                                color: Colors.white,
                                image: new DecorationImage(
                                    image: new AssetImage(
                                        'assets/location.jpg'),
                                    fit: BoxFit.cover),
                                boxShadow: [
                                  new BoxShadow(
                                      color: Colors.grey ,
                                      blurRadius: 5.0,
                                      offset: new Offset(2.0, 5.0))
                                ],
                              ),
                            ),
                          ),
                          new Expanded(
                              child: new Container(
                                margin: const
                                EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                child: new Column(children: [
                                  new Text(
                                    transportFive + '\n$transportFareFive GHS' ,
                                    style: new TextStyle(
                                      fontSize: 20.0,
                                      fontFamily: 'Arvo',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,),
                              )
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>TransportDialogContent(busTicket: 'Bus Ticket', transportLocation:transportFive.toString(), transportFare:transportFareFive.toInt(),userID:widget.userId.toString(), dateselected:dateSelected.toString() )));
                       // _showTransportTicketDialog("Bus Ticket" , transportFive.toString(), transportFareFive.toInt());
                      }
                    ),
                    new Container(
                      width: 300.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    ),

                  ],
                ),
              ),
            );
          }
        },
      ),
    );


  }

  _foodP(){
    return  new Center(
      child: FutureBuilder(
        future: buildText(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return CircularProgressIndicator(backgroundColor: Colors.blue);
          } else {
            return new Container(

              child:SingleChildScrollView(
                child: new Column(
                  children: <Widget>[
                    new GestureDetector(
                      child: new Row(
                        children: <Widget>[
                          new Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: new Container(
                              margin: const EdgeInsets.all(16.0),
                              child: new Container(
                                width: 70.0,
                                height: 70.0,
                              ),
                              decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.circular(10.0),
                                color: Colors.white,
                                image: new DecorationImage(
                                    image: new AssetImage(
                                        'assets/Friedrice&grilledchicken.jpg'),
                                    fit: BoxFit.cover),
                                boxShadow: [
                                  new BoxShadow(
                                      color: Colors.grey ,
                                      blurRadius: 5.0,
                                      offset: new Offset(2.0, 5.0))
                                ],
                              ),
                            ),
                          ),
                          new Expanded(
                              child: new Container(
                                margin: const
                                EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                child: new Column(children: [
                                  new Text(
                                    foodOne + '\n $foodFareOne GHS',
                                    style: new TextStyle(
                                      fontSize: 20.0,
                                      fontFamily: 'Arvo',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,),
                              )
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>FoodDialogContent(busTicket: 'Food Ticket', transportLocation:foodOne.toString(), transportFare:foodFareOne.toInt(),userID:widget.userId.toString())));

                       // _showFoodTicketDialog('Food Ticket',foodOne.toString(), foodFareOne.toInt());
                      }
                    ),
                    new Container(
                      width: 300.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    ),

                    new GestureDetector(
                      child: new Row(
                        children: <Widget>[
                          new Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: new Container(
                              margin: const EdgeInsets.all(16.0),
                              child: new Container(
                                width: 70.0,
                                height: 70.0,
                              ),
                              decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.circular(10.0),
                                color: Colors.white,
                                image: new DecorationImage(
                                    image: new AssetImage(
                                        'assets/jollof&chicken.jpg'),
                                    fit: BoxFit.cover),
                                boxShadow: [
                                  new BoxShadow(
                                      color: Colors.grey ,
                                      blurRadius: 5.0,
                                      offset: new Offset(2.0, 5.0))
                                ],
                              ),
                            ),
                          ),
                          new Expanded(
                              child: new Container(
                                margin: const
                                EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                child: new Column(children: [
                                  new Text(
                                    foodTwo + '\n $foodFareTwo GHS',
                                    style: new TextStyle(
                                      fontSize: 20.0,
                                      fontFamily: 'Arvo',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,),
                              )
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>FoodDialogContent(busTicket: 'Food Ticket', transportLocation:foodTwo.toString(), transportFare:foodFareTwo.toInt(),userID:widget.userId.toString())));
                        //_showFoodTicketDialog('Food Ticket', foodTwo.toString(),foodFareTwo.toInt());
                      }
                    ),
                    new Container(
                      width: 300.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    ),

                    new GestureDetector(
                      child: new Row(
                        children: <Widget>[
                          new Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: new Container(
                              margin: const EdgeInsets.all(16.0),
                              child: new Container(
                                width: 70.0,
                                height: 70.0,
                              ),
                              decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.circular(10.0),
                                color: Colors.white,
                                image: new DecorationImage(
                                    image: new AssetImage(
                                        'assets/fries&chickenwings.jpg'),
                                    fit: BoxFit.cover),
                                boxShadow: [
                                  new BoxShadow(
                                      color: Colors.grey ,
                                      blurRadius: 5.0,
                                      offset: new Offset(2.0, 5.0))
                                ],
                              ),
                            ),
                          ),
                          new Expanded(
                              child: new Container(
                                margin: const
                                EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                child: new Column(children: [
                                  new Text(
                                    foodThree + '\n $foodFareThree GHS',
                                    style: new TextStyle(
                                      fontSize: 20.0,
                                      fontFamily: 'Arvo',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,),
                              )
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>FoodDialogContent(busTicket: 'Food Ticket', transportLocation:foodThree.toString(), transportFare:foodFareThree.toInt(),userID:widget.userId.toString() )));

                       // _showFoodTicketDialog('Food Ticket', foodThree.toString(),foodFareThree.toInt());
                      }
                    ),
                    new Container(
                      width: 300.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    ),

                    new GestureDetector(
                      child: new Row(
                        children: <Widget>[
                          new Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: new Container(
                              margin: const EdgeInsets.all(16.0),
                              child: new Container(
                                width: 70.0,
                                height: 70.0,
                              ),
                              decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.circular(10.0),
                                color: Colors.white,
                                image: new DecorationImage(
                                    image: new AssetImage(
                                        'assets/meatloverspizza.jpg'),
                                    fit: BoxFit.cover),
                                boxShadow: [
                                  new BoxShadow(
                                      color: Colors.grey ,
                                      blurRadius: 5.0,
                                      offset: new Offset(2.0, 5.0))
                                ],
                              ),
                            ),
                          ),
                          new Expanded(
                              child: new Container(
                                margin: const
                                EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                child: new Column(children: [
                                  new Text(
                                    foodFour + '\n $foodFareFour GHS',
                                    style: new TextStyle(
                                      fontSize: 20.0,
                                      fontFamily: 'Arvo',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,),
                              )
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>FoodDialogContent(busTicket: 'Food Ticket', transportLocation:foodFour.toString(), transportFare:foodFareFour.toInt(), userID:widget.userId.toString() )));
                        //_showFoodTicketDialog('Food Ticket', foodFour.toString(),foodFareFour.toInt());
                      }
                    ),
                    new Container(
                      width: 300.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    ),

                    new GestureDetector(
                      child: new Row(
                        children: <Widget>[
                          new Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: new Container(
                              margin: const EdgeInsets.all(16.0),
                              child: new Container(
                                width: 70.0,
                                height: 70.0,
                              ),
                              decoration: new BoxDecoration(
                                borderRadius: new BorderRadius.circular(10.0),
                                color: Colors.white,
                                image: new DecorationImage(
                                    image: new AssetImage(
                                        'assets/BankuTilapia.jpg'),
                                    fit: BoxFit.cover),
                                boxShadow: [
                                  new BoxShadow(
                                      color: Colors.grey ,
                                      blurRadius: 5.0,
                                      offset: new Offset(2.0, 5.0))
                                ],
                              ),
                            ),
                          ),
                          new Expanded(
                              child: new Container(
                                margin: const
                                EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                child: new Column(children: [
                                  new Text(
                                    foodFive + '\n $foodFareFive GHS',
                                    style: new TextStyle(
                                      fontSize: 20.0,
                                      fontFamily: 'Arvo',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start,),
                              )
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>FoodDialogContent(busTicket: 'Food Ticket', transportLocation:foodFive.toString(), transportFare:foodFareFive.toInt(), userID:widget.userId.toString() )));
                        //_showFoodTicketDialog('Food Ticket', foodFive.toString(), foodFareFive.toInt());
                      }
                    ),
                    new Container(
                      width: 300.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    ),

                  ],
                ),
              ),



            );
          }
        },
      ),
    );


  }

  Future buildText() {
    return new Future.delayed(
        const Duration(seconds: 2), () => print('waiting'));
  }

  Widget _servicePage() {

    _moviePage (BuildContext context) async {

      await showDialog(
          context: context,
          builder: (BuildContext context){
            return new Scaffold(

                appBar: new AppBar(
                  centerTitle: true,
                  backgroundColor: Color(0xff01A0C7),
                  title: new Text(
                    ' Cinema ',
                    style: new TextStyle(color: Colors.white,
                      fontFamily: 'Arvo',
                      fontWeight: FontWeight.bold,),
                  ),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Icon(
                        Icons.date_range, size: 20.0, color: Colors.white,),
                      onPressed:  () => _selectDate(context),
                    )
                  ],

                ),

                body: _movieP(),


            );

          }
      );

    }

    _transportationPage(BuildContext context) async {
      await showDialog(
          context: context,
          builder: (BuildContext context) {

            return new Scaffold(

                appBar: new AppBar(
                  centerTitle: true,
                  backgroundColor: Color(0xff01A0C7),
                  title: new Text(
                    ' Transportation Service ',
                    style: new TextStyle(color: Colors.white,
                      fontFamily: 'Arvo',
                      fontWeight: FontWeight.bold,),
                  ),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Icon(
                        Icons.date_range, size: 20.0, color: Colors.white,),
                        onPressed:  () => _selectDate(context),
                    )
                  ],

                ),


                body: _transportP()


            );
          }
      );
    }

    _foodPage(BuildContext context) async {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return new Scaffold(

              appBar: new AppBar(
                centerTitle: true,
                backgroundColor: Color(0xff01A0C7),
                title: new Text(
                  ' Food Service ',
                  style: new TextStyle(color: Colors.white,
                    fontFamily: 'Arvo',
                    fontWeight: FontWeight.bold,),
                ),

              ),

              body: _foodP()




            );
          }
      );
    }

    _deliveryPage(BuildContext context) async {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return new Scaffold(

              appBar: new AppBar(
                centerTitle: true,
                backgroundColor: Color(0xff01A0C7),
                title: new Text(
                  ' Delivery Service ',
                  style: new TextStyle(color: Colors.white,
                    fontFamily: 'Arvo',
                    fontWeight: FontWeight.bold,),
                ),

              ),

              body: new Container(
                color: Colors.white,
                margin: const EdgeInsets.all(2.0),
                child: Column(
                  children: <Widget>[
                    new ListTile(
                        leading: Icon(Icons.place),
                        title: Text('Within Kumasi' ,style: TextStyle(fontSize: 20.0),),
                        subtitle: Text("charge based on destination in Kumasi", style: TextStyle(fontSize: 20.0),),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        contentPadding: EdgeInsets.fromLTRB(
                            5.0, 10.0, 20.0, 10.0),
                        onTap: () =>  _kumasiPersonnel(context)
                    ),
                    Container(
                      width: 400.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
                    ),
                    new ListTile(
                        leading: Icon(Icons.place),
                        title: Text('Outside Kumasi', style: TextStyle(fontSize: 20.0),),
                        subtitle: Text(
                            "charge based on destination outside Accra", style: TextStyle(fontSize: 20.0),),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        contentPadding: EdgeInsets.fromLTRB(
                            1.0, 10.0, 10.0, 10.0),
                        onTap: () =>  _outsidePersonnel(context)
                    ),
                    Container(
                      width: 400.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
                    ),


                  ],
                ),
              ),


            );
          }
      );
    }


    return new Scaffold(

        body:

        new GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20.0),
          crossAxisSpacing: 10.0,
          crossAxisCount: 2,

          children: <Widget>[

            new GestureDetector(
                child: new Card(
                  color: Color(0xff01A0C7),
                  elevation: 5.0,
                  child: new Container(
                      alignment: Alignment.centerLeft,
                      margin: new EdgeInsets.only(
                          top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        verticalDirection: VerticalDirection.down,
                        children: <Widget>[
                          new Icon(
                            Icons.movie, size: 100.0, color: Colors.white,),
                          new Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text('Cinema', style: TextStyle(
                                    fontWeight: FontWeight.bold ,fontSize: 25.0,
                                    color: Colors.white.withOpacity(0.8))),
                              ],
                            ),
                          )
                        ],
                      )
                  ),
                ),
                onTap:() => _moviePage(context) /*{

                  Navigator.push(context, new MaterialPageRoute(
                      builder: (context) =>
                      new CinemaPage())
                  );

                },*/
            ),

            new GestureDetector(
                child: new Card(
                  color: Color(0xff01A0C7),
                  elevation: 5.0,
                  child: new Container(
                      alignment: Alignment.centerLeft,
                      margin: new EdgeInsets.only(
                          top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        verticalDirection: VerticalDirection.down,
                        children: <Widget>[
                          new Icon(Icons.directions_bus, size: 100.0,
                            color: Colors.white,),
                          new Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text('Bus Transportation',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,fontSize: 25.0,
                                        color: Colors.white.withOpacity(
                                            0.8))),
                              ],
                            ),
                          )
                        ],
                      )
                  ),
                ),
                onTap: () => _transportationPage(context)
            ),

            new GestureDetector(
                child: new Card(
                  color: Color(0xff01A0C7),
                  elevation: 5.0,
                  child: new Container(
                      alignment: Alignment.centerLeft,
                      margin: new EdgeInsets.only(
                          top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        verticalDirection: VerticalDirection.down,
                        children: <Widget>[
                          new Icon(Icons.fastfood, size: 100.0,
                            color: Colors.white,),
                          new Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text('Food', style: TextStyle(
                                    fontWeight: FontWeight.bold,fontSize: 25.0,
                                    color: Colors.white.withOpacity(0.8))),
                              ],
                            ),
                          )
                        ],
                      )
                  ),
                ),

                onTap: () => _foodPage(context)

            ),

            new GestureDetector(
                child: new Card(
                  color: Color(0xff01A0C7),
                  elevation: 5.0,
                  child: new Container(
                      alignment: Alignment.centerLeft,
                      margin: new EdgeInsets.only(
                          top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        verticalDirection: VerticalDirection.down,
                        children: <Widget>[
                          new Icon(Icons.motorcycle, size: 100.0,
                            color: Colors.white,),
                          new Padding(
                            padding: EdgeInsets.only(left: 10.0),
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text('Courier', style: TextStyle(
                                    fontWeight: FontWeight.bold,fontSize: 25.0,
                                    color: Colors.white.withOpacity(0.8))),
                              ],
                            ),
                          )
                        ],
                      )
                  ),
                ),
                onTap: () => _deliveryPage(context)
            ),

          ],
        )
    );

  }

  _tickEts (BuildContext context) async {

    await showDialog(
        context: context,
        builder: (BuildContext context){
          return new Scaffold(
            appBar: new AppBar(
              centerTitle: true,
              backgroundColor: Color(0xff01A0C7),
              title: new Text(
                ' Tickets ',
                style: new TextStyle(color: Colors.white,
                  fontFamily: 'Arvo',
                  fontWeight: FontWeight.bold,),
              ),

            ),

            body: _showTicketList(),
            /*new Container(
                child:SingleChildScrollView(
                  child: Column(
                    children: _showTicketList() + _showMovieTicketList(),
                  ),
                )
            ),*/



          );

        }
    );

  }

  _movieTickEts (BuildContext context) async {

    await showDialog(
        context: context,
        builder: (BuildContext context){
          return new Scaffold(
            appBar: new AppBar(
              centerTitle: true,
              backgroundColor: Color(0xff01A0C7),
              title: new Text(
                ' Tickets ',
                style: new TextStyle(color: Colors.white,
                  fontFamily: 'Arvo',
                  fontWeight: FontWeight.bold,),
              ),

            ),

            body: _showMovieTicketList(),
            /*new Container(
                child:SingleChildScrollView(
                  child: Column(
                    children: _showTicketList() + _showMovieTicketList(),
                  ),
                )
            ),*/



          );

        }
    );

  }

  _foodTickEts (BuildContext context) async {

    await showDialog(
        context: context,
        builder: (BuildContext context){
          return new Scaffold(
            appBar: new AppBar(
              centerTitle: true,
              backgroundColor: Color(0xff01A0C7),
              title: new Text(
                ' Tickets ',
                style: new TextStyle(color: Colors.white,
                  fontFamily: 'Arvo',
                  fontWeight: FontWeight.bold,),
              ),

            ),

            body: _showFoodTicketList(),
            /*new Container(
                child:SingleChildScrollView(
                  child: Column(
                    children: _showTicketList() + _showMovieTicketList(),
                  ),
                )
            ),*/



          );

        }
    );

  }

  _contactUs (BuildContext context) async {

    await showDialog(
        context: context,
        builder: (BuildContext context){
          return new Scaffold(
            appBar: new AppBar(
              centerTitle: true,
              backgroundColor: Color(0xff01A0C7),
              title: new Text(
                ' Contact Us ',
                style: new TextStyle(color: Colors.white,
                  fontFamily: 'Arvo',
                  fontWeight: FontWeight.bold,),
              ),

            ),

            body:  _showContact(),


          );

        }
    );

  }


  _kumasiPersonnel (BuildContext context) async {

    await showDialog(
        context: context,
        builder: (BuildContext context){
          return new Scaffold(
            appBar: new AppBar(
              centerTitle: true,
              backgroundColor: Color(0xff01A0C7),
              title: new Text(
                ' Courier Personnel ',
                style: new TextStyle(color: Colors.white,
                  fontFamily: 'Arvo',
                  fontWeight: FontWeight.bold,),
              ),

            ),

            body:  _showKumasiPersonnel(),


          );

        }
    );

  }

  _outsidePersonnel (BuildContext context) async {

    await showDialog(
        context: context,
        builder: (BuildContext context){
          return new Scaffold(
            appBar: new AppBar(
              centerTitle: true,
              backgroundColor: Color(0xff01A0C7),
              title: new Text(
                ' Courier Personnel ',
                style: new TextStyle(color: Colors.white,
                  fontFamily: 'Arvo',
                  fontWeight: FontWeight.bold,),
              ),

            ),

            body:  _showOutsidePersonnel(),


          );

        }
    );

  }




  Future<Map> getJson() async {
    var url = 'http://api.themoviedb.org/3/movie/now_playing?api_key=4d9f16101775dd8297a527c24262292e';

    http.Response response = await http.get(url);
    return json.decode(response.body);
  }

  Future<http.Response> createRequest(String mobNumber) async {

    Map data = {
      "price": totalCost,
      "network": "mtn",
      "recipient_number": "0248560299",
      "sender": mobNumber.toString() ,
      "option": "rmtm",
      "apikey": "eb06c120fd259b0277f344ebbe37fa57719ac8e4",
      "orderID": "dfd"
    };
    var body = json.encode(data);

//First we have to create a Payment_Request.
//then we'll take the response of our request.
    var resp = await http.post(
        'https://client.teamcyst.com/api_call.php',
        headers: {
          "Content-Type": "application/json",
        },
        body: body

    );

    print("${resp.statusCode}");
    print("${resp.body}");
    return resp;
    //return json.decode(resp.body);
    //print(resp.body);

  }

  Future<http.Response> getRequest() async {

    var resp = await http.get(
        'https://client.teamcyst.com/checktransaction.php?dfd=<id>',
        headers: {
          "Content-Type": "application/json",
        },

    );

    print("${resp.statusCode}");
    print("${resp.body}");
    return resp;
    //return json.decode(resp.body);
    //print(resp.body);

  }


   _movieDetails (movie) async {
    var image_url = 'https://image.tmdb.org/t/p/w500/';
    await showDialog(
        context: context,
        builder: (BuildContext context){

          int amount = 35;

          return new Scaffold(
              appBar: AppBar(
                  backgroundColor: Color(0xff01A0C7),
                  automaticallyImplyLeading: true,
                  //`true` if you want Flutter to automatically add Back Button when needed,
                  //or `false` if you want to force your own back button every where
                  leading: IconButton(icon:Icon(Icons.arrow_back),
                    onPressed:() => Navigator.pop(context),
                  ),
              ),

              body: new Container(
                child: new Column(
                  children: <Widget>[

                    Expanded(
                      flex: 4, // 40%

                      child: new Stack(
                        fit: StackFit.expand,
                        children: <Widget>[

                          new SizedBox.expand(
                            child: new Image.network(
                              image_url + movie['poster_path'],
                              fit: BoxFit.fill,
                            ),
                          ),

                          new BackdropFilter(
                            filter: new ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                            child: new Container(
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ),

                          new Container(
                            child: new Row(
                              children: <Widget>[
                                new Expanded(
                                    flex: 5,
                                    child: new Image.network(
                                      image_url + movie['poster_path'],
                                    )
                                ),
                                new Expanded(
                                  flex: 5,
                                  child: Container(
                                    child: new Column(
                                      children: <Widget>[
                                        new ListTile(
                                          title: Text(movie['title'],style: new TextStyle(color: Colors.white,fontSize: 20.0,fontFamily: 'Arvo')),
                                        ),
                                        new ListTile(
                                          title: Text('${movie['vote_average']}/10',style: new TextStyle(color: Colors.white,fontSize: 20.0,fontFamily: 'Arvo')),
                                        ),
                                        new ListTile(
                                          title: Text('$amount GHS',style: new TextStyle(color: Colors.white,fontSize: 20.0,fontFamily: 'Arvo')),
                                        ),
                                      ],
                                    ),
                                  ),
                                  /*child: new Text(
                                      '${movie['vote_average']}/10',
                                      style: new TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontFamily: 'Arvo'),
                                    )*/
                                )
                              ],
                            ),
                          )


                        ],
                      ),

                    ),


                    Expanded(
                      flex: 2, // 40%
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                        color: Colors.white,
                        child: new Column(
                          children: <Widget>[
                            new Expanded(
                                flex: 2,
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: new Text(
                                      'Trailer',
                                      style: new TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Arvo'),
                                      textAlign: TextAlign.left,
                                    ))),
                            new Expanded(
                              flex: 8,
                              child: Container(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3, // 40%
                      child: new Container(
                        margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                        child: new Column(
                          children: <Widget>[
                            new Expanded(
                                flex: 2,
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: new Text(
                                      movie['title'],
                                      style: new TextStyle(
                                          color: Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Arvo'),
                                      textAlign: TextAlign.left,
                                    ))),
                            new Expanded(
                              flex: 8,
                              child: new Text(movie['overview'],
                                  style: new TextStyle(
                                      color: Colors.black, fontFamily: 'Arvo')),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1, // 40%
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                            flex: 9,
                            child: new RaisedButton(
                                color: Colors.redAccent,
                                child: new Text('Book',
                                    style: new TextStyle(
                                        fontSize: 20.0, color: Colors.white)),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>MovieDialogContent(busTicket: 'Movie Ticket', transportLocation: movie['title'].toString(), transportFare:amount.toInt(),userID:widget.userId.toString(),dateselected:dateSelected.toString())));
                                  //_showMovieTicketDialog('Movie Ticket', movie['title'].toString(),amount.toInt());
                                }
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: new RaisedButton(
                                color: Colors.redAccent,
                                child: new Text('',
                                    style: new TextStyle(
                                        fontSize: 20.0, color: Colors.white)),
                                onPressed: () {}),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )

          );

        }
    );

  }



 /* _showDateTimePicker() async {
    select = await showDatePicker(
      context: context,
      initialDate: new DateTime.now(),
      firstDate: new DateTime(2019),
      lastDate: new DateTime(2020),
    );

    setState(() {});
  }*/






  @override
  Widget build(BuildContext context) {
    getData();
    return new MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: 3,
            child: new Scaffold(
              appBar: new AppBar(
                centerTitle: true,
                backgroundColor: Color(0xff01A0C7),
                title: new Text(
                  ' SERVICES  ',
                  style: new TextStyle(color: Colors.white,
                    fontFamily: 'Arvo',
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,),
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text('Logout', style: new TextStyle(
                        fontSize: 17.0, color: Colors.white)),
                    onPressed: _signOut,
                  )
                ],
              ),


              body: callPage(_currentIndex),


              bottomNavigationBar: BottomNavigationBar(

                currentIndex: _currentIndex,
                // this will be set when a new tab is tapped
                onTap: (value) {
                  _currentIndex = value;
                  setState(() {

                  });
                },

                items: [
                  new BottomNavigationBarItem(
                    icon: new Icon(Icons.class_),
                    title: new Text('Services'),
                  ),
                  new BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      title: Text('Profile')
                  )
                ],

              ),


            )
        )
    );
  }



}



/* class MyDialogContent extends StatefulWidget {
  MyDialogContent({
    Key key,
    this.items,
  }): super(key: key);

  final List<DropdownMenuItem<String>> items;

  @override
  State<StatefulWidget> createState() => new _MyDialogContentState();
} */

/* class _MyDialogContentState extends State<MyDialogContent> {
  String selected;

  List<DropdownMenuItem<String>> items = [
    new DropdownMenuItem(
      child: new Text('Student'),
      value: 'Student',
    ),
    new DropdownMenuItem(
      child: new Text('Professor'),
      value: 'Professor',
    ),
  ];

  int numberT = 0;

  void add() {
    setState(() {
      numberT++;
    });
  }

  void minus() {
    setState(() {
      if (numberT != 0)
        numberT--;
    });
  }

  _getContent() {
    return new Container(
          width: 400.0,
          height: 250.0,
          color: Colors.white,
          child: Column(
            children: <Widget>[
              new Container(
                padding: EdgeInsets.fromLTRB(30.0,10.0,30.0,10.0),
                child: Text('Do you want to buy Bus Ticket',style: new TextStyle(color: Colors.black,
                  fontFamily: 'Arvo',
                  fontWeight: FontWeight.bold,),
                ),
              ),
              new Row(
                children: <Widget>[
                  new Container(
                    padding: EdgeInsets.fromLTRB(30.0,10.0,30.0,10.0),
                    child: Text('Time: ',style: new TextStyle(color: Colors.black,
                      fontFamily: 'Arvo',
                      fontWeight: FontWeight.bold,),),
                  ),
                  new Container(
                    padding: EdgeInsets.fromLTRB(15.0,10.0,30.0,10.0),
                    child: DropdownButton(
                      value: selected,
                      items: items,
                      hint: new Text('Profession'),
                      onChanged: (String value){
                        selected  = value;
                        setState(() {
                          selected;

                        });
                      },
                    ),
                  )
                ],
              ),

              new Row(
                children: <Widget>[
                  new Container(
                    padding: EdgeInsets.fromLTRB(30.0,10.0,15.0,10.0),
                    child: Text('Number of Tickets: ',style: new TextStyle(color: Colors.black,
                      fontFamily: 'Arvo',
                      fontWeight: FontWeight.bold,),),
                  ),
                  new  Container(
                    padding: EdgeInsets.fromLTRB(0.0,10.0,0.0,10.0),
                    width: 40.0,
                    height: 40.0,
                    child: new RawMaterialButton(
                      shape: new CircleBorder(),
                      elevation: 0.0,
                      child: new Icon(Icons.add, color: Colors.black,),
                      onPressed: add,
                    ),
                  ),

                  new Text(' $numberT ',
                      style: new TextStyle(fontSize: 30.0)),

                  new  Container(
                    padding: EdgeInsets.fromLTRB(0.0,10.0,0.0,10.0),
                    width: 40.0,
                    height: 40.0,
                    child: new RawMaterialButton(
                      shape: new CircleBorder(),
                      elevation: 0.0,
                      child: new Icon(const IconData(0xe15b, fontFamily: 'MaterialIcons'),color: Colors.black),
                      onPressed: minus,
                    ),
                  ),

                ],
              ),




            ],
          ) ,

        );



  }


  @override
  Widget build(BuildContext context) {
    return _getContent();
  }
}*/





/*class CinemaPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }

}*/

/*class _HomePageState extends State<CinemaPage> {
  @override

  var movies;
  Color mainColor = const Color(0xff3C3261);

  void getData() async {
    var data = await getJson();
    setState(() {
      movies = data['results'];
    });
  }


  Widget build(BuildContext context) {
    getData();

    return new Scaffold(

        appBar: new AppBar(
          centerTitle: true,
          backgroundColor: Color(0xff01A0C7),
          title: new Text(
            ' Cinema ',
            style: new TextStyle(color: Colors.white,
              fontFamily: 'Arvo',
              fontWeight: FontWeight.bold,),
          ),

        ),

        body: new Padding(
          padding: const EdgeInsets.all(1.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new MovieTitle(mainColor),
              new Expanded(
                child: new ListView.builder(
                    itemCount: movies == null ? 0 : movies.length,
                    itemBuilder: (context, i) {
                      return  new FlatButton(

                        child: new MovieCell(movies,i),
                        padding: const EdgeInsets.all(0.0),
                        onPressed: (){
                          Navigator.push(context, new MaterialPageRoute(builder: (context){
                            return new MovieDetail(movies[i]);
                          }));
                        },
                        color: Colors.white,
                      );           }),
              )
            ],
          ),
        )


    );

  }

}*/


/*class MovieDetail extends StatelessWidget {
  final movie;
  var image_url = 'https://image.tmdb.org/t/p/w500/';

  MovieDetail(this.movie);

  Color mainColor = const Color(0xff01A0C7);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(


        body: new Container(
          child: new Column(
            children: <Widget>[

              Expanded(
                flex: 4, // 40%

                child: new Stack(
                  fit: StackFit.expand,
                  children: <Widget>[

                    new SizedBox.expand(
                      child: new Image.network(
                        image_url + movie['poster_path'],
                        fit: BoxFit.fill,
                      ),
                    ),

                    new BackdropFilter(
                      filter: new ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: new Container(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),

                    new Container(
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                              flex: 5,
                              child: new Image.network(
                                image_url + movie['poster_path'],
                              )
                          ),
                          new Expanded(
                              flex: 5,
                              child: new Text(
                                '${movie['vote_average']}/10',
                                style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                    fontFamily: 'Arvo'),
                              )
                          )
                        ],
                      ),
                    )


                  ],
                ),

              ),


              Expanded(
                flex: 2, // 40%
                child: Container(
                  margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  color: Colors.white,
                  child: new Column(
                    children: <Widget>[
                      new Expanded(
                          flex: 2,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: new Text(
                                'Trailer',
                                style: new TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Arvo'),
                                textAlign: TextAlign.left,
                              ))),
                      new Expanded(
                        flex: 8,
                        child: Container(),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3, // 40%
                child: new Container(
                  margin: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: new Column(
                    children: <Widget>[
                      new Expanded(
                          flex: 2,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: new Text(
                                movie['title'],
                                style: new TextStyle(
                                    color: Colors.black,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Arvo'),
                                textAlign: TextAlign.left,
                              ))),
                      new Expanded(
                        flex: 8,
                        child: new Text(movie['overview'],
                            style: new TextStyle(
                                color: Colors.black, fontFamily: 'Arvo')),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1, // 40%
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 9,
                      child: new RaisedButton(
                          color: Colors.redAccent,
                          child: new Text('Book',
                              style: new TextStyle(
                                  fontSize: 20.0, color: Colors.white)),
                          onPressed: () {}),
                    ),
                    Expanded(
                      flex: 1,
                      child: new RaisedButton(
                          color: Colors.redAccent,
                          child: new Text('',
                              style: new TextStyle(
                                  fontSize: 20.0, color: Colors.white)),
                          onPressed: () {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )

    );
  }
}*/



class MovieTitle extends StatelessWidget{

  final Color mainColor;

  MovieTitle(this.mainColor);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
      child: new Text(
        'Now Showing',
        style: new TextStyle(
            fontSize: 16.0,
            color: mainColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arvo'
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

}

class MovieCell extends StatelessWidget{

  final movies;
  final i;
  Color mainColor = const Color(0xff01A0C7);
  var image_url = 'https://image.tmdb.org/t/p/w500/';
  MovieCell(this.movies,this.i);

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(0.0),
              child: new Container(
                margin: const EdgeInsets.all(16.0),
                child: new Container(
                  width: 70.0,
                  height: 70.0,
                ),
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(10.0),
                  color: Colors.white ,
                  image: new DecorationImage(
                      image: new NetworkImage(
                          image_url + movies[i]['poster_path']),
                      fit: BoxFit.cover),
                  boxShadow: [
                    new BoxShadow(
                        color: Colors.grey ,
                        blurRadius: 5.0,
                        offset: new Offset(2.0, 5.0))
                  ],
                ),
              ),
            ),
            new Expanded(

                child: new Container(
                  margin: const      EdgeInsets.fromLTRB(8.0,0.0,8.0,0.0),
                  child: new Column(children: [
                    new Text(
                      movies[i]['title'],
                      style: new TextStyle(
                          fontSize: 20.0,
                          fontFamily: 'Arvo',
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    new Padding(padding: const EdgeInsets.all(2.0)),
                    new Text(movies[i]['overview'],
                      maxLines: 3,
                      style: new TextStyle(
                          color: const Color(0xff8785A4),
                          fontFamily: 'Arvo'
                      ),)
                  ],
                    crossAxisAlignment: CrossAxisAlignment.start,),
                )
            ),
          ],
        ),
        new Container(
          width: 300.0,
          height: 0.5,
          color: const Color(0xD2D2E1ff),
          margin: const EdgeInsets.fromLTRB(16.0,8.0,16.0,8.0),
        )
      ],
    );

  }

}
