import 'dart:async';
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

// ...existing code...
class _itemCardState extends State<itemCard> {
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  late int itemId;
  String? itemName;
  int? itemQuantity;
  int? threshold;
  // Add a StreamSubscription to manage the listener
  StreamSubscription<DatabaseEvent>? _itemSubscription;

  @override
  void initState() {
    super.initState();
    itemId = widget.itemId;
    listenForChange();
  }

  // Cancel the subscription when the widget is disposed
  @override
  void dispose() {
    _itemSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator or placeholder if data hasn't loaded yet
    if (itemName == null || itemQuantity == null || threshold == null) {
      // You might want a more sophisticated loading widget
      return const Card(child: Center(child: CircularProgressIndicator()));
    }

    return Card(
      color: (itemQuantity! > threshold!) // Null check already happened
          ? Colors.green[600]
          : Colors.red[300],
      child: Padding(
        padding:
            const EdgeInsets.only(top: 6.0, left: 6.0, right: 6.0, bottom: 6.0),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: DefaultTextStyle(
            style: TextStyle(
                color: (itemQuantity! > threshold!) // Null check already happened
                    ? Colors.black
                    : Theme.of(context).colorScheme.onSurface),
            child: ExpansionTile(
              title: Text('$itemName', // Null check already happened
                  style: TextStyle(
                      color: (itemQuantity! > threshold!) // Null check already happened
                          ? Colors.black
                          : Theme.of(context).colorScheme.onSurface)),
              children: <Widget>[
                Text('Item: $itemName'),
                Text('Quantity: $itemQuantity'),
                Text('Threshold: $threshold'),
                Text('Item ID: $itemId'),
                Visibility(
                    visible: itemQuantity != null, // Keep this check for safety
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () async {
                            await ref.child('items/$itemId').update({
                              'itemQuantity': 100, // Corrected field name
                            });
                          },
                          child: const Text('Tare')),
                    )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () async {
                        await ref.child('items/$itemId').update({
                          'itemQuantity': 0, // Corrected field name
                        });
                      },
                      child: const Text('Reset')),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: _editItem, // Call the new edit function
                      child: const Text('Edit')),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () async {
                        // Cancel the listener first
                        await _itemSubscription?.cancel();
                        _itemSubscription = null; // Set to null after cancelling

                        //Then remove the item from the database
                        try {
                          await ref.child('items/$itemId').remove();
                          //Show feedback (only if remove succeeds)
                          if (mounted) { // Check if widget is still mounted
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(
                                 content: Text('Item Deleted'),
                               ),
                             );
                          }
                        } catch (e) {
                           // Handle potential errors during removal
                           print("Error removing item $itemId: $e");
                           if (mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                 content: Text('Error deleting item: $e'),
                               ),
                             );
                           }                        }
                        // The Dashboard listener will handle removing the card UI element.
                      },
                      child: const Text('Delete')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _editItem() async {
    // Controllers pre-filled with current values
    final TextEditingController nameController = TextEditingController(text: itemName);
    // Use current threshold, default to '0' if null (shouldn't happen with current logic)
    final TextEditingController thresholdController = TextEditingController(text: threshold?.toString() ?? '0');

    String? updatedName = itemName; // Store potential new values
    int? updatedThreshold = threshold;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
                autofocus: true, // Optional: focus name field first
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
                // Get potential new values from controllers
                updatedName = nameController.text;
                updatedThreshold = int.tryParse(thresholdController.text);
                Navigator.of(context).pop(); // Close the dialog to proceed with update
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    // Perform validation and DB update *after* the dialog is closed
    // Check if the values obtained from the dialog are valid
    if (updatedName != null && updatedName!.isNotEmpty &&
        updatedThreshold != null && updatedThreshold !> 0 && updatedThreshold !< 100)
    {
      // Check if values actually changed to avoid unnecessary database write
      if (updatedName != itemName || updatedThreshold != threshold) {
        try {
          // Use update to only change specific fields
          await ref.child('items/$itemId').update({
            'itemName': updatedName,
            'threshold': updatedThreshold,
          });

          // Check mounted before showing SnackBar after async gap
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item updated!')),
            );
          }
        } catch (e) {
          print("Error updating item $itemId: $e");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating item: $e')),
            );
          }
        }
      }
      // else: No changes were made, do nothing.
    } else {
      // Show validation error if inputs were invalid after trying to save
      // Check mounted before showing SnackBar after async gap
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid input. Item not updated.')),
        );
      }
    }
  }
  void listenForChange() {
    // Cancel any previous subscription
    _itemSubscription?.cancel();

    // Listen to the specific item's path
    _itemSubscription = FirebaseDatabase.instance
        .ref('items/$itemId')
        .onValue
        .listen((DatabaseEvent event) {
      // Process the snapshot directly from the event
      final snapshot = event.snapshot;
      if (snapshot.exists && mounted) { // Check if snapshot exists and widget is mounted
        final data = snapshot.value as Map<dynamic, dynamic>?; // Cast to Map
        if (data != null) {
          setState(() {
            // Use data[] instead of snapshot.child()
            itemQuantity = int.tryParse(data['itemQuantity']?.toString() ?? '0') ?? 0;
            threshold = int.tryParse(data['threshold']?.toString() ?? '0') ?? 0;
            // itemId = int.tryParse(snapshot.key ?? '0') ?? 0; // itemId doesn't change, remove this
            itemName = data['itemName']?.toString() ?? 'Unknown Item';
          });
        } else {
           // Handle case where data might be null unexpectedly, though snapshot.exists should prevent this
           if (mounted) {
             setState(() {
               itemName = 'Error Loading';
               itemQuantity = 0;
               threshold = 0;
             });
           }
        }
      } 
    }, onError: (error) {
       // Handle potential errors from the stream
       print("Error listening to item $itemId: $error");
       if (mounted) {
         setState(() {
           itemName = 'Error';
           itemQuantity = 0;
           threshold = 0;
         });
       }
    });
  }

}