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




class MainHome extends StatefulWidget {
  MainHome({this.auth,this.userId, this.onSignedOut,});

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

  String foodOne = 'Fried Rice with Grilled Chicken';
  String foodTwo = 'Jollof rice with Chicken ';
  String foodThree = 'Fries with Chicken Wings';
  String foodFour = 'Meat-Lovers Pizza';
  String foodFive = 'Banku with Tilapia';

  String selected;
  int numberT = 1;

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

  List<Tickets> _ticketsList;

  //List<Users> _usersList;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onTodoAddedSubscription;
  StreamSubscription<Event> _onTodoChangedSubscription;

  Query _ticketsQuery;
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


    _ticketsList = new List();
    _ticketsQuery = _database
        .reference()
        .child("tickets")
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onTodoAddedSubscription = _ticketsQuery.onChildAdded.listen(_onEntryAdded);
    _onTodoChangedSubscription = _ticketsQuery.onChildChanged.listen(_onEntryChanged);

  }

  @override
  void dispose() {
    _onTodoAddedSubscription.cancel();
    _onTodoChangedSubscription.cancel();
    super.dispose();
  }

  _onEntryChanged(Event event) {
    var oldEntry = _ticketsList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _ticketsList[_ticketsList.indexOf(oldEntry)] = Tickets.fromSnapshot(event.snapshot);
    });
  }

  _onEntryAdded(Event event) {
    setState(() {
      _ticketsList.add(Tickets.fromSnapshot(event.snapshot));
    });
  }


  _addNewTodo(String ticketsType, String ticketsName ,String ticketsTime , int numberOfTickets) {
    if (ticketsName.length > 0) {
      Tickets todo = new Tickets(ticketsType.toString(),ticketsName.toString(), ticketsTime.toString(), numberOfTickets.toString(), widget.userId, false);
      _database.reference().child("tickets").push().set(todo.toJson());
    }
  }

  _updateTodo(Tickets tickets){
    //Toggle completed
    tickets.completed = !tickets.completed;
    if (tickets != null) {
      _database.reference().child("tickets").child(tickets.key).set(tickets.toJson());
    }
  }

  _deleteTodo(String ticketsId, int index) {
    _database.reference().child("tickets").child(ticketsId).remove().then((_) {
      print("Delete $ticketsId successful");
      setState(() {
        _ticketsList.removeAt(index);
      });
    });
  }


  void add() {
    setState(() {
      numberT++;
    });
  }

  void minus() {
    setState(() {
      if (numberT != 1)
        numberT--;
    });
  }


  _showTransportTicketDialog(String typeTicket , String location ,) async {
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

            body: new Container(
              padding: EdgeInsets.fromLTRB(30.0,30.0,30.0,50.0),
              width: 500,
              height: 400.0,

              child: new Column(
                children: <Widget>[
                  //new MyDialogContent(items: items),
                  new Container(
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
                                _addNewTodo(typeTicket.toString() ,location.toString(), selected.toString(), numberT );
                                createRequest();
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
    );

  }

  _showMovieTicketDialog(String typeTicket ,String title) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new Text(
                      'Do you want to buy Movie Ticket',
                    )
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Buy'),
                  onPressed: () {
                    _addNewTodo(typeTicket.toString() ,title.toString(), selected.toString(), numberT );
                    //_addNewTodo(typeTicket.toString() ,title.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        }
    );
  }

  _showFoodTicketDialog(String typeTicket, String food) async {
    _textEditingController.clear();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: <Widget>[
                new Expanded(
                    child: new Text(
                      'Do you want to buy Ticket',
                    )
                ),
                new Expanded(
                    child: new Text(
                      'Do you want to buy Ticket',
                    )
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Buy'),
                  onPressed: () {
                    //_addNewTodo(typeTicket.toString() ,food.toString());
                    Navigator.pop(context);
                  })
            ],
          );
        }
    );
  }

  _showTicketDetailsDialog( subject, typeofTicket, numberOfTicket, time) async {
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
                height: 500.0,
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
                              _ticketContent('DATE', subject, 'No. of Tickets', typeofTicket),
                              _ticketContent('TIME', time, '', typeofTicket),
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

  _ticketContent(t1,d1,t2,d2) {
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
                      child: Text(d2, style: TextStyle(fontSize: 10.0,)),
                    )
                  ],
                )
            ),

          ],
        )
    );
  }


  _showTicketList() {
    if (_ticketsList.length > 0) {
      return ListView.builder(
          shrinkWrap: true,
          itemCount: _ticketsList.length,
          itemBuilder: (BuildContext context, int index) {
            String todoId = _ticketsList[index].key;
            String typeofTicket = _ticketsList[index].typeofTicket;
            String numberOfTicket = _ticketsList[index].numberOfTicket;
            String time = _ticketsList[index].time;
            String subject = _ticketsList[index].subject;
            bool completed = _ticketsList[index].completed;
            String userId = _ticketsList[index].userId;
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
                    trailing: IconButton(
                        icon: (completed)
                            ? Icon(
                          Icons.done_outline,
                          color: Colors.green,
                          size: 20.0,
                        )
                            : Icon(Icons.done, color: Colors.grey, size: 20.0),
                        onPressed: () {
                          _updateTodo(_ticketsList[index]);
                        }),
                  ),
                  onTap: () => _showTicketDetailsDialog(subject,typeofTicket, numberOfTicket, time)
              ),


            );

          });
    } else {
      return Center(child: Text("Welcome. Your list is empty",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30.0),));
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
                        title: Text('My Tickets'),
                        onTap: () => _tickEts(context)
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
                                  onPressed: () => _movieDetails(movies[i])/*{
                                  Navigator.push(context, new MaterialPageRoute(builder: (context){
                                    return new MovieDetail(movies[i]);
                                  }));
                                },*/
                                //color: Colors.white,
                              );           }),
                      )
                    ],
                  ),
                )


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

                ),


                body: new Container(
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
                                          transportOne + ' 45GHC',
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
                            onTap: () =>  _showTransportTicketDialog('Bus Ticket' ,transportOne.toString())
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
                                          transportTwo + ' 30GHC',
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
                            onTap: () => _showTransportTicketDialog('Bus Ticket', transportTwo.toString())
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
                                          transportThree + ' 40GHC',
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
                            onTap:() => _showTransportTicketDialog('Bus Ticket', transportThree.toString())
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
                                          transportFour + ' 55GHC',
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
                            onTap: () => _showTransportTicketDialog('Bus Ticket', transportFour.toString())
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
                                        transportFive + ' 40GHC',
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
                          onTap: () => _showTransportTicketDialog("Bus Ticket" , transportFive.toString()),
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
                )


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

              body: new Container(

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
                                      foodOne + ' 25GHC',
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
                        onTap: () => _showFoodTicketDialog('Food Ticket',foodOne.toString()),
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
                                      foodTwo + ' 30GHC',
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
                        onTap: () => _showFoodTicketDialog('Food Ticket', foodTwo.toString()),
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
                                      foodThree + ' 20GHC',
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
                        onTap: () =>
                            _showFoodTicketDialog('Food Ticket', foodThree.toString()),
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
                                      foodFour + ' 40GHC',
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
                        onTap: () => _showFoodTicketDialog('Food Ticket', foodFour.toString()),
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
                                      foodFive + ' 20GHC',
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
                        onTap: () => _showFoodTicketDialog('Food Ticket', foodFive.toString()),
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



              ),




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
                        title: Text('Within Accra'),
                        subtitle: Text("charge based on destination in Accra"),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        contentPadding: EdgeInsets.fromLTRB(
                            5.0, 10.0, 20.0, 10.0),
                        onTap: () => _showContact()
                    ),
                    Container(
                      width: 400.0,
                      height: 0.5,
                      color: const Color(0xD2D2E1ff),
                      margin: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
                    ),
                    new ListTile(
                        leading: Icon(Icons.place),
                        title: Text('Outside Accra'),
                        subtitle: Text(
                            "charge based on destination outside Accra"),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        contentPadding: EdgeInsets.fromLTRB(
                            1.0, 10.0, 10.0, 10.0),
                        onTap: () => _showContact()
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
                                    fontWeight: FontWeight.bold,
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
                                        fontWeight: FontWeight.bold,
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
                                    fontWeight: FontWeight.bold,
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
                                    fontWeight: FontWeight.bold,
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

  Future<Map> getJson() async {
    var url = 'http://api.themoviedb.org/3/movie/now_playing?api_key=4d9f16101775dd8297a527c24262292e';

    http.Response response = await http.get(url);
    return json.decode(response.body);
  }

  Future<http.Response> createRequest() async {

    Map data = {
      "price": 1,
      "network": "mtn",
      "recipient_number": "0248560299",
      "sender": "0242824653",
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


  _movieDetails (movie) async {
    var image_url = 'https://image.tmdb.org/t/p/w500/';
    await showDialog(
        context: context,
        builder: (BuildContext context){

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
                                  child: Container(
                                    child: new Column(
                                      children: <Widget>[
                                        new ListTile(
                                          title: Text(movie['title'],style: new TextStyle(color: Colors.white,fontSize: 20.0,fontFamily: 'Arvo')),
                                        ),
                                        new ListTile(
                                          title: Text('${movie['vote_average']}/10',style: new TextStyle(color: Colors.white,fontSize: 20.0,fontFamily: 'Arvo')),
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
                                onPressed: () => _showMovieTicketDialog('Movie Ticket', movie['title'].toString())
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
