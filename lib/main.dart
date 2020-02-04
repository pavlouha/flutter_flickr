import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:cached_network_image/cached_network_image.dart';

//создадим распарсиватель
Future<String> fetchPhoto() async{
  final response = await http.get('https://www.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=26735e19238420ad886787ff3db6b7c5');
  if (response.statusCode == 200) {
    // Если отвечает код двести, то парсим
    return response.body;
  } else {
    throw Exception('Невозможно запарсить xml');
  }
}

void main() => runApp(MyApp());
var temp; //xml фаел
int i = 0;

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  Future<String> fetchPhoto() async {
    final response = await http.get(
        'https://www.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=26735e19238420ad886787ff3db6b7c5');
    if (response.statusCode == 200) {
      // Если отвечает код двести, то парсим
      return response.body;
    } else {
      throw Exception('Невозможно запарсить xml');
    }
  }

  Future<String> checker;
  @override
  void initState() {
    super.initState();
    checker = fetchPhoto();
  }

Widget build(BuildContext context) {
  return FutureBuilder(
      future: checker,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          xml.XmlDocument temp = xml.parse(snapshot.data);
          var ids = temp.findAllElements('photo').map((each) =>
              each.getAttribute('id')).toList();
          var farms = temp.findAllElements('photo').map((each) =>
              each.getAttribute('farm')).toList();
          var servers = temp.findAllElements('photo').map((each) =>
              each.getAttribute('server')).toList();
          var secrets = temp.findAllElements('photo').map((each) =>
              each.getAttribute('secret')).toList();
          while (i < ids.length) {
            i++;
            return Center(child: Image.network(
                'https://farm' + farms[i - 1] + '.staticflickr.com/' +
                    servers[i - 1] + '/' + ids[i - 1] + '_' + secrets[i - 1] +
                    '.jpg'),
            );
          }
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
        // By default, show a loading spinner.
      }
  );
}
}

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Flicr Flutter',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flicr Fetcher'),
        ),
        body: GridView.count(
          primary: true,
          padding: const EdgeInsets.all(10),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          children: List.generate(100, (index){
            return MyStatefulWidget();
          })
          ),
        ),
      );
  }
}

