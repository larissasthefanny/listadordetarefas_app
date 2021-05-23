import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main () {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
 
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _toDoController = TextEditingController();

    List _toDoList = [];
      Map< String, dynamic> _lastRemoved;
      int _lastRemovedPos;




    
     @override
  void initState() {
    super.initState();

      _readData().then((data) {
        setState(() {
                    _toDoList = json.decode(data);
                });
      });    
  }

    void _addToDo () {
      setState(() {
        Map<String, dynamic> newToDo = Map ();
       newToDo["title"]= _toDoController.text;
      _toDoController.text = "";
      newToDo ["ok"] = false;
      _toDoList.add(newToDo); 
      _saveData();  
  });
    
    }

    Future<Null> _refresh ()async {
     await Future.delayed(Duration(seconds: 1));
     setState(() {
              _toDoList.sort((a,b){
          if(a["ok"] && !b["ok"]) return 1;
          else if (!a["ok"] && b["ok"]) return -1;
          else return 0;
      });

      _saveData();
          });

      return null;
    }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),


      floatingActionButton: FloatingActionButton(
        backgroundColor: color(Colors.pink),
        elevation: 40, onPressed: _addToDo,
        child: Icon(Icons.add, color: Colors.white,),
      ),



      body:
       Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _toDoController,
                    decoration: InputDecoration(
                      labelText: "Nova Tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent)
                    ),
                  )
                  ),
              ]
              ,)
          ),

            Expanded(
              child: RefreshIndicator( onRefresh: _refresh,
                
                child: ListView.builder( //filho do refreshIndicator
                padding: EdgeInsets.only(top: 10),
                itemCount: _toDoList.length,
                itemBuilder: buildItem),
                ),
                
                ),
               ],
              ),
            );
           }


    Widget buildItem(BuildContext context, int index) { 
      // widget responsavel por fzr cada um dos itens 
                  return Dismissible( //item p/ deslizar pro lado 
                  key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
                    background: Container(
                      color: Colors.red,
                      child: Align(
                        alignment: Alignment(-0.9,0.0),
                      child: Icon(Icons.delete, color: Colors.white,
                      ),
                      ),
                    ),


                    direction: DismissDirection.startToEnd, //desliza pro lado até o final 
                    child: CheckboxListTile(
                    title: Text(_toDoList[index] ["title"]),
                    value: _toDoList[index]["ok"],
                    secondary: CircleAvatar(
                      child: Icon(_toDoList[index]["ok"] ?
                        Icons.check: Icons.error),
                    ),


                    onChanged: (c) {
                     setState(() {
                        _toDoList [index] ["ok"] = c;
                        _saveData();
                      });
                    },
                  ),


                  onDismissed: (direction) { //desfazer a ação de removed
                    setState(() {
                    _lastRemoved = Map.from(_toDoList[index]); 
                    _lastRemovedPos = index;
                    _toDoList.removeAt(index);  

                    _saveData();

                    final snack = SnackBar(
                      content: Text("Tarefa \"${_lastRemoved ["title"]}\" removida!"),
                      action: SnackBarAction(label: "Desfazer", 
                      onPressed: (){
                        setState(() {
                                 _toDoList.insert(_lastRemovedPos, _lastRemoved);
                        _saveData();
                         });
                      }),
                      duration: Duration(seconds: 2),
                    );

                    // ignore: deprecated_member_use
                    Scaffold.of(context).showSnackBar(snack); //para mostrar a ação

                    });
                  },
              );
           }






  Future<File> _getFile() async { //sempre q precisar do arquivo, é so chamar o _getfile 
  // ignore: non_constant_identifier_names
  final Directory = await getApplicationDocumentsDirectory();
  return File("${Directory.path}/data.json");
}

Future<File> _saveData() async {
    String data = json.encode(_toDoList);
    
    // ignore: non_constant_identifier_names
    final File =  await _getFile();
    return File.writeAsString(data);
}

Future<String> _readData() async {
  try {
    // ignore: non_constant_identifier_names
    final File = await _getFile();
    return File.readAsString();
  
  } catch (e) {
      return null;
  }
}

  color(MaterialColor pink) {}

}

