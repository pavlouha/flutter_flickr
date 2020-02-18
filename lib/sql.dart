
import 'package:flutter/material.dart';
import 'package:flutter_flickr/db.dart';
import 'package:flutter_flickr/main.dart';

abstract class FavoriteModel {
  int id;
  String owner;
  String title;
  static fromMap() {}
  toMap() {}
}

class TodoItem {
  static String table = 'favs';

  int id;
  String owner;
  String title;

  TodoItem({ this.id, this.owner, this.title});

  Map<String, dynamic> toMap() {

    Map<String, dynamic> map = {
      'id': id,
      'owner': owner,
      'title' : title,
    };

    if (id != null) { map['id'] = id; }
    return map;
  }

  static TodoItem fromMap(Map<String, dynamic> map) {

    return TodoItem(
        id: map['id'],
        owner: map['owner'],
        title: map['title'],
    );
  }
}


class Favorites extends StatefulWidget {
  @override
  FavoritesState createState() => FavoritesState();
}

void init() async {
  await DB.init();
}

class FavoritesState extends State<Favorites> {
  List<TodoItem> tasks = [];


  @override
  Widget build(BuildContext context) {
    List<Widget> getItems = tasks.map((item) => format(item)).toList();
   // _tasks = _results.map((item) => TodoItem.fromMap(item)).toList();
    return Scaffold(
      appBar: AppBar(
        iconTheme: new IconThemeData(color: Colors.red),
        backgroundColor: Colors.brown,
      ),
      body:
      Center(
          child: ListView( children: getItems ),
      ),
      );
  }

  Widget format(TodoItem item) {
    return Dismissible(
      key: Key(item.id.toString()),
      child: Padding(
          padding: EdgeInsets.fromLTRB(12, 6, 12, 4),
          child: FlatButton(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(item.title),
                ]
            ),
            onPressed: () =>  Navigator.push(
            context,
    MaterialPageRoute(builder: (context) => WebViewPage(item.owner, item.id.toString(), item.title))),
          )
      ),
      onDismissed: (DismissDirection direction) => delete(item),
    );
  }
  @override
  void initState() {
    refresh();
    super.initState();
  }

  void refresh() async {
    List<Map<String, dynamic>> _results = await DB.query(TodoItem.table);
    tasks = _results.map((item) => TodoItem.fromMap(item)).toList();
    setState(() { });
  }

  void delete(TodoItem item) async {
    DB.delete('favs', item);
    refresh();
  }
}


void save(id, owner, title) async {

  TodoItem item = TodoItem(
      id: id,
      owner: owner,
    title: title,
  );

  await DB.insert('favs', item);
}

