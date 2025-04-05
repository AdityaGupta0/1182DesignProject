//import 'dart.io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
//import 'package:cloud_functions/cloud_functions.dart';

class itemCard extends StatefulWidget {
  final int itemId;
  itemCard({super.key, required this.itemId});

  @override
  State<itemCard> createState() => _itemCardState();
}

class _itemCardState extends State<itemCard> {
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  late int itemId;
  String? itemName;
  int? itemQuantity;
  int? threshold;


  @override
  void initState() {
    super.initState();
    itemId = widget.itemId;
    reload();
    listenForChange();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: (itemQuantity != null && itemQuantity! > threshold!)
          ? Colors.green[600]
          : Colors.red[300],
      child: Padding(
        // padding: const EdgeInsets.only(top: 36.0, left: 6.0, right: 6.0, bottom: 6.0),
        padding:
            const EdgeInsets.only(top: 6.0, left: 6.0, right: 6.0, bottom: 6.0),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: DefaultTextStyle(
            style: TextStyle(
                color: (itemQuantity != null && itemQuantity! > threshold!)
                    ? Colors.black
                    : Theme.of(context).colorScheme.onSurface),
            child: ExpansionTile(
              title: Text('Item: $itemName',
                  style: TextStyle(
                      color: (itemQuantity != null && itemQuantity! > threshold!)
                          ? Colors.black
                          : Theme.of(context).colorScheme.onSurface)),
              children: <Widget>[
                Text('Item: $itemName'),
                Text('Quantity: $itemQuantity'),
                Text('Threshold: $threshold'),
                Text('Item ID: $itemId'),
                Visibility(
                    visible: itemQuantity == null,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () async {
                            //await FirebaseFunctions.instance
                               //.httpsCallable('uidSignOut')
                               //.call({"uid": uid});
                          },
                          child: const Text('Tare')),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void listenForChange() {
    FirebaseDatabase.instance
        .ref('$itemId/state')
        .onValue
        .listen((DatabaseEvent event) {
      reload();
    });
  }

  void reload() async {
    DataSnapshot snapshot = await ref.child('$itemId').get();
    setState(() {
      itemQuantity = int.parse(snapshot.child('quantity').value.toString());
      threshold = int.parse(snapshot.child('threshold').value.toString());
      itemId = int.parse(snapshot.child('itemId').value.toString());
      itemName = snapshot.child('itemName').value.toString();
    });
  }

}