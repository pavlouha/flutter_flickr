import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

var temp;

class Search extends StatefulWidget {

 final String question;
  Search(this.question);

@override
SearchState createState() => SearchState(question);
}

class SearchState extends State<Search> {
  String question;
  SearchState(this.question);
  Future<String> findAnswer() async {
    final response = await http.get(
        'https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=26735e19238420ad886787ff3db6b7c5&text='+question + '&per_page=500');
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
    checker = findAnswer();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      searcher(checker),
    );

  }
}
