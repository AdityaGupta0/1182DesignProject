import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_tracker/itemCard.dart';
import 'dart:ui';


class dashBoard extends StatefulWidget {
  const dashBoard({super.key});

  @override
  State<dashBoard> createState() => _dashBoardState();
}

class _dashBoardState extends State<dashBoard> {
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
              Text('Inventory Tracker',
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
    
    createUserCards();

  }

  Future<void> createUserCards() async {
    //DatabaseReference ref = FirebaseDatabase.instance.ref('items');
    DataSnapshot snapshot = await ref.get();
    Map<dynamic, dynamic> items = snapshot.value as Map<dynamic, dynamic>;
    List<itemCard> cards = [];

    items.forEach((key, value) {
      int itemId = int.parse(key);
      cards.add(itemCard(itemId: itemId));
    });

    setState(() {
      itemCards = cards;
    });
  }
}