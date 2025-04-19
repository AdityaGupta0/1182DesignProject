import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
import 'package:inventory_tracker/itemCard.dart';
import 'dart:ui';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _dashBoardState();
}

class _dashBoardState extends State<Dashboard> {
  DatabaseReference ref = FirebaseDatabase.instance.ref();

  List<itemCard> itemCards = [];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Column(children: <Widget>[
              Text('Dashboard',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),

              ScrollConfiguration(
                  behavior: 
                      ScrollConfiguration.of(context).copyWith(dragDevices: {
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                    PointerDeviceKind.trackpad,
                  }),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: itemCards.length,
                  itemBuilder: (context, index) {
                    return itemCards[index];
                  },
                ),
              )
            ])
            ])
          )
      );
  }
  @override
  void initState() {
    super.initState();
    listenForItemChanges();
  }

  void listenForItemChanges() {
    ref.child('items').onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        List<itemCard> cards = [];
        data.forEach((key, value) {
          // Ensure the key can be parsed as an int
          int? itemId = int.tryParse(key);
          if (itemId != null) {
            // Add a ValueKey using the unique itemId
            cards.add(itemCard(key: ValueKey(itemId), itemId: itemId));
          } else {
            print("Warning: Could not parse item key '$key' as integer.");
          }
        });
        // Optional: Sort cards if needed, e.g., by itemId or name from value
        // cards.sort((a, b) => a.itemId.compareTo(b.itemId));

        if (mounted) { // Check if widget is still mounted before calling setState
          setState(() {
            itemCards = cards;
          });
        }
      } else {
         if (mounted) { // Check if widget is still mounted
           setState(() {
             itemCards = [];
           });
         }
      }
    }, onError: (error) {
      // Handle potential errors from the stream
      print("Error listening to items: $error");
      if (mounted) {
        setState(() {
          itemCards = []; // Clear cards on error or show an error message
        });
      }
    });
  }
  }