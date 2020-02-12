import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:share/share.dart';
import 'search.dart';

void main() {
  runApp(MyApp());
}
  var temp; //xml фаел
var founded; //xml с результатами поиска
  int pages = 1;
var searchTerm;

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
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
  return searcher(checker);
  }

 }

FutureBuilder searcher(checker) {
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
          var owners = temp.findAllElements('photo').map((each) =>
              each.getAttribute('owner')).toList();
          var titles = temp.findAllElements('photo').map((each) =>
              each.getAttribute('title')).toList();
          return GridView.count(
              primary: true,
              padding: const EdgeInsets.all(10),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              children: List.generate(100, (index) {
                return new InkResponse(
                    enableFeedback: true,
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      imageUrl: 'https://farm' + farms[index] +
                          '.staticflickr.com/' +
                          servers[index] + '/' + ids[index] + '_' +
                          secrets[index] +
                          '.jpg',
                    ),
                    onTap: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              WebViewPage(
                                  owners[index], ids[index], titles[index])),
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

class WebViewPage extends StatelessWidget {
  final String owner, id, title;
  WebViewPage(this.owner, this.id, this.title);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: WebviewScaffold(
          appBar: new AppBar(
            backgroundColor: Colors.brown,
            title: Text(title),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back), tooltip: 'Previous page',
                onPressed: () { Navigator.pop(context);},
              ),
              IconButton(
                icon: Icon(Icons.share), tooltip: 'Share via',
                onPressed: ()  {
Share.share("Check out what I've found in Flickr! " + 'https://www.flickr.com/photos/' + owner + '/' + id);
                },
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
      home: HomeScr(),
      );
  }

}

class HomeScr extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      extendBodyBehindAppBar: true,
      drawer: showDrawer(),
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.red),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchWidget()),
          ),)
        ],
      ),
      body:
      MyStatefulWidget(),
    );
  }
}

Widget showDrawer() {
 return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black12,
            ),
            child: ListView(
              padding: EdgeInsets.all(5),
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                Text('FlickrFetchr',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
                IconButton(
                  iconSize: 50,
                  icon: Icon(Icons.account_circle),
                  tooltip: 'Login',
                  onPressed:() => debugPrint(''), //ДОБАВИТЬ ЭКШОНОВ
                ),
                FlatButton(
                  onPressed: () => debugPrint(''),
                  child: Text('Account'),
                ),
              ],
            )
        ),
        ListTile(
          title: Text('Favourites'),
          onTap: () => debugPrint(''),
        ),
        ListTile(
          title: Text('About'),
          onTap: () => debugPrint(''),
        )
      ],
    ),
  );
}

class SearchWidget extends StatefulWidget {
  SearchWidget({Key key}) : super(key: key);

  @override
  SearchWidgetState createState() => SearchWidgetState();
}

// страница поиска
class SearchWidgetState extends State<SearchWidget> {
  final _searchKey = GlobalKey<ScaffoldState>();
  Widget build(BuildContext context)  {
  return new Builder(builder: (ctx) {
    return Scaffold(
      key: _searchKey,
      drawer: showDrawer(),
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.red),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back), tooltip: 'Previous page',
            onPressed: () { Navigator.pop(context);},
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          TextField(
            controller: searchController,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 18.0, color: Colors.lightBlue.shade50),
                ),
                hintText: 'Enter a search term'
            ),
          ),
          FlatButton(onPressed: () => startingSearch(),
              color: Colors.lightGreen,
              textColor: Colors.white,
              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20)),
              child: Text('Search'))
        ],
      ) 
    );
    }
  );
  }

  final searchController = TextEditingController();
  @override
  void dispose() {
    searchTerm = '';
    searchController.dispose();
    super.dispose();
  }

  final snackBarError = SnackBar(content: Text('Write a correct search result!'));

  void startingSearch() {
    searchTerm = searchController.text;
    if (searchController.text == '') {
    _searchKey.currentState.showSnackBar(snackBarError);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Search(searchTerm)),
      );
    }

  }
}