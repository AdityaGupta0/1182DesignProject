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
      home: const MyHomePage(title: 'Quantifi'),
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
    String? itemName;
    int? threshold;

    await showDialog(
    context: context,
    builder: (BuildContext context) {
      final TextEditingController nameController = TextEditingController();
      final TextEditingController thresholdController = TextEditingController();

      return AlertDialog(
        title: const Text('Add New Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: thresholdController,
              decoration: const InputDecoration(labelText: 'Threshold'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog without saving
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              itemName = nameController.text;
              threshold = int.tryParse(thresholdController.text);
              Navigator.of(context).pop(); // Close the dialog and save input
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
  if (itemName != null && itemName!.isNotEmpty && threshold! > 0 && threshold ! < 100) {
    int itemId = DateTime.now().millisecondsSinceEpoch;
    await ref.child('items/$itemId').set({
      'itemName': itemName,
      'itemQuantity': 0, // Default quantity
      'maxQuant': 0, // Default max quantity
      'currQuant': 0, // Default current quantity
      'threshold': threshold,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item added!')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid input. Item not added.')),
    );
  }
}
}