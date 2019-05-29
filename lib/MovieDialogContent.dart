import 'package:flutter/material.dart';
import 'mainhome.dart';
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

class MovieDialogContent extends StatefulWidget {

  final String busTicket, transportLocation, userID, dateselected;
  final int transportFare;

  MovieDialogContent({
    Key key,
    this.items,
    @required this.busTicket,
    @required this.transportLocation,
    @required this.transportFare,
    @required this.userID,
    @required this.dateselected,
  }): super(key: key);



  final List<DropdownMenuItem<String>> items;

  @override
  State<StatefulWidget> createState() => new _MovieDialogContentState(BusTicket:busTicket, TransportLocation:transportLocation, TransportFare:transportFare, UserID:userID, DateSelected:dateselected );
}

class _MovieDialogContentState extends State<MovieDialogContent> {
  _MovieDialogContentState({Key key, @required this.BusTicket, @required this.TransportLocation, @required this.TransportFare, @required this.UserID, @required this.DateSelected});
  String selected;
  final String BusTicket, TransportLocation, UserID , DateSelected ;
  final int TransportFare;


  final numberController =  TextEditingController();

  String selectedMovieTime;
  String selectedCinemaRoom;
  int numberT = 1;
  int totalCost;
  String mobNumber;


  List<DropdownMenuItem<String>> movieTimeItems = [
    new DropdownMenuItem(
      child: new Text('1PM'),
      value: '1PM',
    ),
    new DropdownMenuItem(
      child: new Text('3PM'),
      value: '3PM',
    ),
    new DropdownMenuItem(
      child: new Text('5PM'),
      value: '5PM',
    ),
  ];

  List<DropdownMenuItem<String>> cinemaRoomItems = [
    new DropdownMenuItem(
      child: new Text('Cinema 1'),
      value: 'Cinema 1',
    ),
    new DropdownMenuItem(
      child: new Text('Cinema 2'),
      value: 'Cinema 2',
    ),
    new DropdownMenuItem(
      child: new Text('Cinema 3'),
      value: 'Cinema 3',
    ),
  ];

  List<MovieTickets> _movieTicketsList;
  var decodedJson;
  Query _movieTicketsQuery;

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();


    _movieTicketsList = new List();

    _movieTicketsQuery = _database
        .reference()
        .child("movie tickets")
        .orderByChild("userId")
        .equalTo(UserID.toString());
    _onTodoAddedSubscription = _movieTicketsQuery.onChildAdded.listen(_monEntryAdded);
    _onTodoChangedSubscription = _movieTicketsQuery.onChildChanged.listen(_monEntryChanged);

  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
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

  _addNewMovie(String ticketsType, String ticketsName ,String movieTime ,String cinemaRoom , int numberOfTickets, int amountPaid,String completed) {
    if (ticketsName.length > 0) {
      MovieTickets todo = new MovieTickets(ticketsType.toString(),ticketsName.toString(), movieTime.toString(), cinemaRoom.toString(), numberOfTickets.toString(), amountPaid.toString(), DateSelected.toString() , UserID.toString() , completed.toString() );
      _database.reference().child("movie tickets").push().set(todo.toJson());
    }
  }




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

  /*_getContent() {
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



  }*/


  _totalMoviePrice(String typeTicket,String title ,String selectedMovieTime, String selectedCinemaRoom, int number, int amount,String mobNumber)async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        int numberTicket = number.toInt();
        int cost = amount.toInt();
        totalCost = numberTicket * cost ;
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Confirm Payment"),
          //"Total Amount to Pay\n $totalCost " + ' GHS'

          content: Text("1. Dial *170# \n 2. Select option 6 Wallet \n 3. Select option 3 My Approvals \n 4. Enter Mobile Money PIN \n 5. Select the transaction from the list \n 6. Confirm the transaction.",
            style: new TextStyle(color: Colors.black,
              fontFamily: 'Arvo',
              fontWeight: FontWeight.bold,fontSize: 20.0,),textAlign: TextAlign.center ,),
          actions: <Widget>[
            new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new FlatButton(
                    child: new Text("Dismiss"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    child: new Text("Pay"),
                    onPressed: () {
                      createRequest(mobNumber.toString());
                      getRequest();
                      _addNewMovie(typeTicket.toString(), title.toString(),selectedMovieTime.toString(),selectedCinemaRoom.toString(), number , totalCost, decodedJson['status'].toString());
                      Navigator.of(context).pop();
                    },
                  ),
                ]
            ),
          ],
        );
      },
    );

  }


  @override
  Widget build(BuildContext context) {
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

      body: new Container(
        padding: EdgeInsets.fromLTRB(30.0,30.0,30.0,50.0),
        width: 500,
        height: 500.0,

        /*Column(
                children: <Widget>[
                  MyDialogContent(),
                  new Text('s'),
                  new Container(
                      width: 400,
                      height: 50,
                      color: Colors.white,
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          new FlatButton(
                              child: Text('Cancel',style: new TextStyle(color: Colors.black,fontFamily: 'Arvo',),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                          new FlatButton(
                              child: Text('Pay', style: new TextStyle(color: Colors.black,fontFamily: 'Arvo',),
                              ),
                              onPressed: () {
                                _addNewTodo(typeTicket.toString() ,location.toString(), selected.toString(), numberT );
                                createRequest();
                                Navigator.pop(context);
                              }
                          )

                        ],
                      )
                  ),


                ],
              )*/

        child:new Column(
      children: <Widget>[
      //new MyDialogContent(items: items),
      new Container(
        width: 400.0,
        height: 250.0,
        color: Colors.white,
        child: ListView(
          children: <Widget>[
            new Container(
              padding: EdgeInsets.fromLTRB(30.0,10.0,30.0,10.0),
              child: Text('Do you want to buy Movie Ticket',style: new TextStyle(color: Colors.black,
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
                    value: selectedMovieTime,
                    items: movieTimeItems,
                    hint: new Text('Choose Time'),
                    onChanged: (String value){
                      selectedMovieTime  = value;
                      setState(() {
                        selectedMovieTime;

                      });
                    },
                  ),
                )
              ],
            ),

            new Row(
              children: <Widget>[
                new Container(
                  padding: EdgeInsets.fromLTRB(30.0,10.0,30.0,10.0),
                  child: Text('Cinema Room:',style: new TextStyle(color: Colors.black,
                    fontFamily: 'Arvo',
                    fontWeight: FontWeight.bold,),),
                ),
                new Container(
                  padding: EdgeInsets.fromLTRB(10.0,10.0,20.0,10.0),
                  child: DropdownButton(
                    value: selectedCinemaRoom,
                    items: cinemaRoomItems,
                    hint: new Text('Select Room'),
                    onChanged: (String value){
                      selectedCinemaRoom  = value;
                      setState(() {
                        selectedCinemaRoom;

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

            new Row(
              children: <Widget>[
                new Container(
                  padding: EdgeInsets.fromLTRB(30.0,10.0,30.0,10.0),
                  child: Text('MoMo number: ',style: new TextStyle(color: Colors.black,
                    fontFamily: 'Arvo',
                    fontWeight: FontWeight.bold,),),
                ),
                Expanded(
                  child: new Container(
                    padding: EdgeInsets.fromLTRB(15.0,10.0,30.0,10.0),
                    child: new TextField(
                      controller: numberController,
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      autofocus: false,
                      decoration: new InputDecoration(
                        hintText: 'Mobile Money Number',
                      ),
                    ),
                  ),
                )
              ],
            ),




          ],
        ) ,

      ),

      new Container(
          width: 400,
          height: 50,
          color: Colors.white,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new FlatButton(
                  child: Text('Cancel',style: new TextStyle(color: Colors.black,fontFamily: 'Arvo',),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: Text('Buy', style: new TextStyle(color: Colors.black,fontFamily: 'Arvo',),
                  ),
                  onPressed: () {
                    if(selectedMovieTime != null || selectedCinemaRoom != null){
                      Navigator.popAndPushNamed(context, _totalMoviePrice(BusTicket.toString(), TransportLocation.toString(),selectedMovieTime.toString(),selectedCinemaRoom.toString(), numberT, TransportFare.toInt(), numberController.text));

                    }else{
                      Fluttertoast.showToast(
                        msg: "Select time and Room",
                        textColor: Colors.white,
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIos: 2,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.indigo.withOpacity(0.5),

                      );
                    }

                    Navigator.pop(context);
                  }
              )

            ],
          )
      ),

      ],
    ),

      ),


    );
  }


  Future<http.Response> createRequest(String mobNumber) async {

    Map data = {
      "price": 1.2,
      "network": "mtn",
      "recipient_number": "0248560299",
      "sender": mobNumber.toString() ,
      "option": "rmtm",
      "apikey": "eb06c120fd259b0277f344ebbe37fa57719ac8e4",
      "orderID": ""
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

  Future<String> getRequest() async {

    var resp = await http.get(
      'https://client.teamcyst.com/checktransaction.php?orderID=ffz',
      headers: {
        "Content-Type": "application/json",
      },

    );
    decodedJson=json.decode(resp.body);
    print("${resp.statusCode}");
    print(decodedJson["status"]);
    return (decodedJson['status'].toString());
    //return json.decode(resp.body);
    //print(resp.body);

  }


}