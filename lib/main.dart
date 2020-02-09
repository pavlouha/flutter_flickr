import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void main() => runApp(MyApp());
var temp; //xml фаел
int pages = 1;
class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  MyStatefulWidgetState createState() => MyStatefulWidgetState();
}

class MyStatefulWidgetState extends State<MyStatefulWidget> {
  Future<String> fetchPhoto(page) async {
    final response = await http.get(
        'https://www.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=26735e19238420ad886787ff3db6b7c5&page=' + page.toString());
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
    checker = fetchPhoto(pages);
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
          var owners = temp.findAllElements('photo').map((each) => each.getAttribute('owner')).toList();
            return GridView.count(
                primary: true,
                padding: const EdgeInsets.all(10),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                children: List.generate(100, (index){
                  return new InkResponse(
                    enableFeedback: true,
                    child: CachedNetworkImage(
                      placeholder: (context, url) => CircularProgressIndicator(),
                      imageUrl: 'https://farm' + farms[index] + '.staticflickr.com/' +
                          servers[index] + '/' + ids[index] + '_' + secrets[index] +
                          '.jpg',
                    ),
                    onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecondPage(owners[index], ids[index])),
                  )
                  );
                })
            );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      }
      );
  }
}

class SecondPage extends StatelessWidget {
  final String owner, id;
  SecondPage(this.owner, this.id);

  @override
  Widget build(BuildContext context) {
    var title = 'Flickr';
    return MaterialApp(
        title: title,
        home: WebviewScaffold(
          appBar: new AppBar(
            backgroundColor: Colors.brown,
            title: new Text('Flickr'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back), tooltip: 'Previous page',
                onPressed: () { Navigator.pop(context);},
              )
            ],
          ),
          url: 'https://www.flickr.com/photos/' + owner + '/' + id,
          withZoom: false,
          withLocalStorage: true,
        )
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
        body: MyStatefulWidget(),
        ),
      );
  }


}

