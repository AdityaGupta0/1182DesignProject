import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:inventory_tracker/dashBoard.dart';
import 'firebase_options.dart';
//import 'package:firebase_database/firebase_database.dart';

void main() async {
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
      title: 'inventory_tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Inventory Tracker Home Page'),
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
  DatabaseReference ref = FirebaseDatabase.instance.ref();
 

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Dashboard(),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
        ),

        );

  }

  void _addItem() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    int itemId = DateTime.now().millisecondsSinceEpoch;
    await ref.child('items/$itemId').set({
      'itemName': 'RiceBowlMutherfucker',
      'itemQuantity': 10,
      'threshold': 5,
    });
    
    /*
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item added!'),
      ),
    );
    */
  }
}
