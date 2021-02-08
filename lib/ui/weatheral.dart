import 'dart:io';
import 'package:flutter/material.dart';
import '../util/utils.dart' as util;
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class Weatheral extends StatefulWidget {
  @override
  _WeatheralState createState() => _WeatheralState();
}

class _WeatheralState extends State<Weatheral> {
  String _cityEntered;

  Future _goToNextScreen(BuildContext context) async{
    Map results = await Navigator.of(context).push(
       MaterialPageRoute(builder: (BuildContext context) {
         return ChangeCity();
      })
    );

    if(results != null && results.containsKey('enter')) {

      _cityEntered = results['enter'];

   //   debugPrint("From First Screen" + results['enter'].toString());
    }
  }

  void showStuff() async{
    Map data = await getWeather(util.appId, util.defaultCity);
    print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Weatheral'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          new IconButton(
            icon: new Icon(Icons.menu),
            onPressed: () {_goToNextScreen(context);},
          ),
        ],
      ),
      body: new Stack(
        children: [
          new Center(
            child: new Image.asset('images/weather.jpg', width: 490.0, height: 1200.0, fit: BoxFit.fill,),
          ),
          new Container(
            alignment: Alignment.topRight,
            margin: const EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
            child: Text('${_cityEntered == null ? util.defaultCity : _cityEntered}',
            style: cityStyle(),
            ),
          ),

          new Container(
            alignment: Alignment.center,
            child: Image.asset('images/rain.png'),
          ),

          //container which has our weather data
          new Container(
            margin: const EdgeInsets.fromLTRB(30.0, 290.0, 0.0, 0.0),
            child: updateTempWidget(_cityEntered),
          ),
        ],
      ),
    );
  }

  Future<Map> getWeather(String appId, String city) async {
    //http://api.openweathermap.org/data/2.5/weather?q=Ajmer%20&appid=59a2e7a6bdf7bd844150e7ca6aba0ca3&units=metric
    //http://api.openweathermap.org/data/2.5/weather?q=$city%20&appid='
    //        '${util.appId}&units=metric'

   String apiUrl = 'http://api.openweathermap.org/data/2.5/weather?q=$city&appid='
       '${util.appId}&units=metric';

    http.Response response = await http.get(apiUrl);

    return jsonDecode(response.body);
  }

  Widget updateTempWidget(String city) {
    return new FutureBuilder(
            future: getWeather(util.appId, city == null ? util.defaultCity : city),
            builder: (BuildContext context, AsyncSnapshot<Map> snapshot){
              if(snapshot.hasData){
                Map content = snapshot.data;
                 return new Container(
                   child: Column(
                     children: [
                       ListTile(
                         title: Text(content['main']['temp'].toString(),
                         style: TextStyle(
                           fontStyle: FontStyle.normal,
                           fontSize: 49.9,
                           color: Colors.white,
                           fontWeight: FontWeight.w500
                         ),),
                       )
                     ],
                   ),
                 );
              }
              else{
                return new Container();
                    }

            });

  }

}

class ChangeCity extends StatelessWidget {

  final _cityFieldController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Change City'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Image.asset('images/fog.jpg',
            width: 490.0, height: 1200.0, fit: BoxFit.fill,),
          ),
          ListView(
            children: [
              ListTile(
                title: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter City'
                  ),
                  controller: _cityFieldController,
                  keyboardType: TextInputType.text,
                ),
              ),
              ListTile(
                title: FlatButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'enter': _cityFieldController.text
                    });
                  },
                  textColor: Colors.white70,
                  color: Colors.redAccent,
                  child: Text('Get Weather'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}


TextStyle cityStyle(){
  return new TextStyle(
    color: Colors.white,
    fontSize: 22.9,
    fontStyle: FontStyle.italic,
  );
}

TextStyle tempStyle(){
  return new TextStyle(
    color: Colors.white,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w500,
    fontSize: 49.9
  );
}