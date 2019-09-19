import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override 
  void initState(){
    super.initState();

    _readData().then((data){     
      setState(() {
        _toDoList = jsonDecode(data);
      });
    });
  }

  List _toDoList = [];
  Map<String,dynamic> _lastRemoved;
  int _lastRemovedPosition;

  final _toDoController = TextEditingController();

  void addToDo(){
    setState(() {
      Map<String,dynamic> newToDo = Map();
      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";
      newToDo["ok"]=false;
      _toDoList.add(newToDo); 
      _saveData();
    });
  }

  Widget BuildTile(context,index){
        return Dismissible(
          key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
          background: Container(
            color: Colors.red,
            child: Align(
              alignment: Alignment(-0.9,0),
              child: Icon(Icons.delete,color: Colors.white,),
            ),
          ),
          direction: DismissDirection.startToEnd,
          child: CheckboxListTile(
                          title: Text(_toDoList[index]["title"],style: TextStyle(color: Colors.black),),
                          value: _toDoList[index]["ok"],
                          secondary: CircleAvatar(child: Icon(_toDoList[index]["ok"]?
                            Icons.check : Icons.error
                          ),),
                          onChanged: (value){
                            setState(() {
                              _toDoList[index]["ok"] = value;
                              _saveData();
                            });
                          },
                        ),
          onDismissed: (direction){
            setState(() {
              _lastRemoved = Map.from(_toDoList[index]);
              _lastRemovedPosition = index;
              _toDoList.removeAt(index);
              _saveData(); 

              final snack = SnackBar(
                content: Text("Tarefa ${_lastRemoved["title"]} removida"),
                action: SnackBarAction(
                  label: "Desfazer",
                  onPressed: (){
                    setState(() {
                      _toDoList.insert(_lastRemovedPosition,_lastRemoved);
                      _saveData(); 
                    });
                  },
                ),
                duration: Duration(seconds: 2),
              );
              Scaffold.of(context).showSnackBar(snack);
            });
          },
        ); 
   } 

                      
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.indigoAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child:TextFormField(
                      controller: _toDoController,
                      decoration: InputDecoration(
                      labelText: "Nome da tarefa",
                      labelStyle: TextStyle(color:Colors.indigoAccent
                      ),
                    )
                  )
                  ),
                  Padding(
                    padding: EdgeInsets.only(top:12),
                    child: RaisedButton(
                    onPressed:()=>addToDo(),
                    color: Colors.indigoAccent,      
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),                                                    
                    child: Text("Adicionar",style: TextStyle(color: Colors.white),)
                  ),
                  ),
                ],
            ),            
            ),
            Container(
              height: 550 ,
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.builder(
                      padding: EdgeInsets.only(top:10),
                      itemCount: _toDoList.length,
                      itemBuilder: BuildTile,
                    ),
                    )
                  ),                  
            
          ],
        ),
      ),
    );  
     
  }

  Future<File> _getFile() async{
  final dir = await getApplicationDocumentsDirectory(); // Get the directory where i can place files without permissions and this things
  return File("${dir.path}/data.json");
  }

  Future<File> _saveData() async{
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _readData() async{
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }

 Future <Null> _refresh() async {
   await Future.delayed(Duration(seconds: 1));
   
   setState(() {
     _saveData(); 
     _toDoList.sort((a,b){
      if(a["ok"] && !b["ok"]) return 1;
      else if(!a["ok"] && b["ok"] ) return -1;
      else return 0;
      });
   });
  }
}

