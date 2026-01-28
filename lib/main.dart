import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:todo_list/firebase_options.dart';

Future <void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'To Do List',),
      
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final CollectionReference _todos=FirebaseFirestore.instance.collection("todos");
  final TextEditingController _controller =TextEditingController();

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
     
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
       
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Add new Task",
                  border: OutlineInputBorder(
                  ),
                  suffixIcon: IconButton(
                    onPressed: ()async{
                       if(_controller.text.isEmpty){
                      ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Le task ne doit pas être null'))
                              );
                              return;  // ✅ Correct
                                }
  // ...
                        
                      await _todos.add({
                        'task':_controller.text,
                        'done':false
                      });
                      _controller.clear();
                    },
                     icon: Icon(Icons.add))
                ),
              ),),
            Expanded(
              child:StreamBuilder<QuerySnapshot>(
               stream: _todos.snapshots(),
               builder: (context, snapshot)
               {
                if(snapshot.hasData){
                     return ListView(
                  children: snapshot.data!.docs.map((doc)
                  {
                    return ListTile(
                      onLongPress: () async{
                        await _todos.doc(doc.reference.id).delete();
                      },
                      onTap: () async{
                        await _todos.doc(doc.reference.id).update(
                          {'task':_controller.text}
                        );
                        _controller.clear();
                      },
                      title: Text(doc['task'],style: TextStyle(
                        decoration: doc['done'] ? TextDecoration.lineThrough : null
                      ),),
                      leading: Checkbox(
                        value: doc['done'],
                       onChanged: (value){
                        _todos.doc(doc.reference.id).update(
                          {'done':value},
                        );
                       }),
                    );
                  }).toList()
                );
                } else if(snapshot.connectionState ==ConnectionState.waiting){
                  return Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                } else{
                  return Center(
                    child: Text("No task found"),
                  );
                }
             
               }
               ) )

          ],
        ),
       
      ),
    );
  }
}
