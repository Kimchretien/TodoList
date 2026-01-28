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
                      title: Text(doc['task']),
                      leading: Checkbox(
                        value: doc['done'],
                       onChanged: (value){
                        _todos.doc(doc.reference.id).update(
                          {'done':value}
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
