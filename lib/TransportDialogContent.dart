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

class TransportDialogContent extends StatefulWidget {

  final String busTicket, transportLocation, userID, dateselected;
  final int transportFare;

  TransportDialogContent({
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
  State<StatefulWidget> createState() => new _TransportDialogContentState(BusTicket:busTicket, TransportLocation:transportLocation, TransportFare:transportFare, UserID:userID, DateSelected:dateselected );
}

class _TransportDialogContentState extends State<TransportDialogContent> {
  _TransportDialogContentState({Key key, @required this.BusTicket, @required this.TransportLocation, @required this.TransportFare, @required this.UserID, @required this.DateSelected});

  String selected;
  final String BusTicket, TransportLocation, UserID, DateSelected;
  final int TransportFare;

  final numberController =  TextEditingController();

  String userActivity = "Choose Time";
  int userActivity1 = 1;

  int numberT = 1;

  int totalCost;
  String mobNumber;

  List<DropdownMenuItem<String>> items = [
    new DropdownMenuItem(
      child: new Text('9AM'),
      value: '9AM',
    ),
    new DropdownMenuItem(
      child: new Text('12PM'),
      value: '12PM',
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



  List<TransportTickets> _transportTicketsList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  var decodedJson;
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _transportTicketsQuery;

  @override
  void initState() {
    super.initState();




    _transportTicketsList = new List();

    _transportTicketsQuery = _database
        .reference()
        .child("transport tickets")
        .orderByChild("userId")
        .equalTo(UserID.toString() );
    _onTodoAddedSubscription = _transportTicketsQuery.onChildAdded.listen(_onEntryAdded);
    _onTodoChangedSubscription = _transportTicketsQuery.onChildChanged.listen(_onEntryChanged);

  }


  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
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

  _addTransport(String ticketsType, String ticketsName ,String ticketsTime , String numberOfTickets, int amountPaid,String completed) {
    if (ticketsName.length > 0) {
      TransportTickets todo = new TransportTickets(ticketsType.toString(),ticketsName.toString(), ticketsTime.toString(), numberOfTickets.toString(), amountPaid.toString(), DateSelected.toString() , UserID.toString(), completed.toString());
      _database.reference().child("transport tickets").push().set(todo.toJson());
    }
  }



  void add() {
    setState(() {
      if (numberT != 5)
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




  _totalTransPrice(String typeTicket,String location ,String selected, int number, String numberOfTicket ,int amount, String mobNumber)async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        int numberTicket = number.toInt();
        int cost = amount.toInt();
        totalCost = numberTicket * cost ;

        String numberTicketsss = numberTicket.toString();
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Confirm Payment"),

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
                      _addTransport(typeTicket.toString(), location.toString(),selected.toString(), numberTicketsss.toString() , totalCost, decodedJson['status'].toString() );

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
        height: 400.0,

        child:


        new Column(
          children: <Widget>[
            //new MyDialogContent(items: items),
            new Container(
              width: 400.0,
              height: 250.0,
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  new Container(
                    padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                    child: Text('Do you want to buy Bus Ticket',
                      style: new TextStyle(color: Colors.black,
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
                          hint: new Text('Choose Time'),
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
                        padding: EdgeInsets.fromLTRB(
                            30.0, 10.0, 10.0, 10.0),
                        child: Text('No of Tickets: ',
                          style: new TextStyle(color: Colors.black,
                            fontFamily: 'Arvo',
                            fontWeight: FontWeight.bold,),),
                      ),
                      new Container(
                        padding: EdgeInsets.fromLTRB(
                            0.0, 10.0, 0.0, 10.0),
                        width: 40.0,
                        height: 40.0,
                        child: new RawMaterialButton(
                          shape: new CircleBorder(),
                          elevation: 0.0,
                          child: new Icon(
                            Icons.add, color: Colors.black,),
                          onPressed: add,
                        ),
                      ),

                      new Text(' $numberT ',
                          style: new TextStyle(fontSize: 30.0)),

                      new Container(
                        padding: EdgeInsets.fromLTRB(
                            0.0, 10.0, 0.0, 10.0),
                        width: 40.0,
                        height: 40.0,
                        child: new RawMaterialButton(
                          shape: new CircleBorder(),
                          elevation: 0.0,
                          child: new Icon(const IconData(
                              0xe15b, fontFamily: 'MaterialIcons'),
                              color: Colors.black),
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

                  new Row(
                    children: <Widget>[
                      new Container(
                        padding: EdgeInsets.fromLTRB(
                            30.0, 10.0, 10.0, 10.0),
                        child: Text('Total amount:',
                          style: new TextStyle(color: Colors.black,
                            fontFamily: 'Arvo',
                            fontWeight: FontWeight.bold,fontSize: 20.0,),),
                      ),
                      new Container(
                        padding: EdgeInsets.fromLTRB(15.0,10.0,30.0,10.0),
                        child: Text(TransportFare.toString() + ' GHS',
                          style: new TextStyle(color: Colors.black,
                            fontFamily: 'Arvo',
                            fontWeight: FontWeight.bold,fontSize: 20.0,),textAlign: TextAlign.center ,),
                      )
                    ],
                  ),

                ],
              ),

            ),

            new Container(
                width: 400,
                height: 50,
                color: Colors.white,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new FlatButton(
                        child: Text('Cancel', style: new TextStyle(
                          color: Colors.black, fontFamily: 'Arvo',),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    new FlatButton(
                      child: Text('Buy', style: new TextStyle(
                        color: Colors.black, fontFamily: 'Arvo',),
                      ),
                      onPressed: () {
                        if(selected != null){
                          Navigator.popAndPushNamed(context, _totalTransPrice(BusTicket.toString(), TransportLocation.toString(),selected.toString(), numberT.toInt(),numberT.toString() , TransportFare.toInt(),numberController.text));
                        }else{
                          Fluttertoast.showToast(
                            msg: "Select time",
                            textColor: Colors.white,
                            toastLength: Toast.LENGTH_SHORT,
                            timeInSecForIos: 2,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.indigo.withOpacity(0.5),

                          );
                        }

                      },
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
      "price": 1.1,
      "network": "mtn",
      "recipient_number": "0248560299",
      "sender": mobNumber.toString() ,
      "option": "rmtm",
      "apikey": "eb06c120fd259b0277f344ebbe37fa57719ac8e4",
      "orderID": "ffz"
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