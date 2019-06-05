import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in a Flutter IDE). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: _widgetForRoute(window.defaultRouteName),//MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

Widget _widgetForRoute(String route) {
  switch (route) {
    case 'route1':
      return  MyHomePage(title: '1>Flutter Demo Home Page');
    case 'route2':
      return  MyHomePage(title: '2>Flutter Demo Home Page');
    default:
      return  MyHomePage(title: '3>Flutter Demo Home Page');

  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  static const toAndroidPlugin = const MethodChannel('com.angrypanda.androidflutter/toandroid');
  static const fromAndroiPlugin = const EventChannel('com.angrypanda.androidflutter/toflutter');
  StreamSubscription _fromAndroiSub;
  var _nativeParams;


  @override
  void initState() {
    super.initState();
    _startfromAndroiPlugin();
  }

  void _startfromAndroiPlugin(){
    if(_fromAndroiSub == null){
      _fromAndroiSub =  fromAndroiPlugin.receiveBroadcastStream()
          .listen(_onfromAndroiEvent,onError: _onfromAndroiError);
    }
  }

  void _onfromAndroiEvent(Object event) {
    setState(() {
      _nativeParams = event;
    });
  }

  void _onfromAndroiError(Object error) {
    setState(() {
      _nativeParams = "error";
      print(error);
    });
  }


  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Future<Null> _jumpToNative() async {
    String result = await toAndroidPlugin.invokeMethod('withoutParams');

    print(result);
  }


  Future<Null> _jumpToNativeWithParams() async {

    Map<String, String> map = { "flutter": "这是一条来自flutter的参数" };

    String result = await toAndroidPlugin.invokeMethod('withParams', map);

    print(result);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
            new RaisedButton(onPressed: (){
              _jumpToNative();
            },
            child: new Text("without params"),),
            new RaisedButton(onPressed: (){
              _jumpToNativeWithParams();
            },
              child: new Text("with params"),
            ),
            new Text("from android : $_nativeParams"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
