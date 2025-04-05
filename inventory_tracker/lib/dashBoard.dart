import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_tracker/itemCard.dart';


class dashBoard extends StatefulWidget {
  const dashBoard({super.key});

  @override
  State<dashBoard> createState() => _dashBoardState();
}

class HomePageState extends State<dashBoard> {
  DatabaseReference ref = FirebaseDatabase.instance.ref();

  List<itemCard> itemCards = [];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            child: Column(children: <Widget>[
              Text('Inventory Tracker',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),

              ScrollConfiguration(
              behavior: 
                  scrollConfiguration.of(context).copywith(dragDevices: {
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
}