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
  int? maxQuant;
  int? currQuant;
  int? threshold;
  int? itemQuantity; // Added to store the quantity of the item
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
    if (itemName == null || maxQuant == null || threshold == null || currQuant == null || itemQuantity == null) {
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
                color: (itemQuantity! > threshold!) 
                    ? Colors.black
                    : Theme.of(context).colorScheme.onSurface),
            child: ExpansionTile(
              title: Text('$itemName', 
                  style: TextStyle(
                      fontSize: 20,
                      color: (itemQuantity! > threshold!) 
                          ? Colors.black
                          : Theme.of(context).colorScheme.onSurface)),
              subtitle: Text(itemQuantity != null 
                  ? '$itemQuantity%'
                  : 'Loading...'),
              children: <Widget>[
                Text('Threshold: $threshold%',style: TextStyle(fontWeight: FontWeight.w500)),
                Text('Absolute Quantity: $currQuant',style: TextStyle(fontWeight: FontWeight.w300)),
                Text('Absolute max Quantity: $maxQuant', style: TextStyle(fontWeight: FontWeight.w300)),
                Text('ID: $itemId' , style: TextStyle(fontWeight: FontWeight.w300)),
                Visibility(
                    visible: itemQuantity != null, 
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () async {
                            // Check if currQuant is valid before updating
                            if (currQuant != null && currQuant! >= 0) {
                              try {
                                await ref.child('items/$itemId').update({
                                  // Set 'maxQuant' field to the current 'currQuant' value
                                  'maxQuant': currQuant,
                                });
                                // Optional: Show feedback
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Max quantity tared!')),
                                  );
                                }
                              } catch (e) {
                                print("Error taring item $itemId: $e");
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error taring item: $e')),
                                  );
                                }
                              }
                            } else {
                              // Handle case where currQuant is null or invalid (optional)
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Cannot tare: Invalid current quantity.')),
                                );
                              }
                            }
                          },
                          child: const Text('Tare')),
                    )),
                /*    
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () async {
                        await ref.child('items/$itemId').update({
                          'itemQuantity': 0, 
                        });
                      },
                      child: const Text('Reset')),
                ),
                */
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
                        await _itemSubscription?.cancel();
                        _itemSubscription = null; // Set to null after cancelling
                        //Then remove the item from the database
                        try {
                          await ref.child('items/$itemId').remove();
                          //show feedback (only if remove succeeds)
                          if (mounted) { //check if widget is still mounted
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(
                                 content: Text('Item Deleted'),
                               ),
                             );
                          }
                        } catch (e) {
                           //handle potential errors during removal
                           print("Error removing item $itemId: $e");
                           if (mounted) {
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                 content: Text('Error deleting item: $e'),
                               ),
                             );
                           }                        }
                        //the Dashboard listener will handle removing the card UI element.
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
            //itemQuantity = int.tryParse(data['itemQuantity']?.toString() ?? '0') ?? 0;
            currQuant = int.tryParse(data['currQuant']?.toString() ?? '0') ?? 0;
            maxQuant = int.tryParse(data['maxQuant']?.toString() ?? '0') ?? 0;
            threshold = int.tryParse(data['threshold']?.toString() ?? '0') ?? 0;
            // itemId = int.tryParse(snapshot.key ?? '0') ?? 0; 
            itemName = data['itemName']?.toString() ?? 'Unknown Item';
          });
          if (maxQuant != null && maxQuant! > 0 && currQuant != null) {
              // Ensure currQuant doesn't exceed maxQuant for percentage calculation
              int effectiveCurrQuant = (currQuant! > maxQuant!) ? maxQuant! : currQuant!;
              itemQuantity = (effectiveCurrQuant / maxQuant! * 100).toInt();
            } else {
              itemQuantity = 0; // Default to 0% if calculation isn't possible
            }
        } else {
           // Handle case where data might be null unexpectedly, though snapshot.exists should prevent this
           if (mounted) {
             setState(() {
               itemName = 'Error Loading';
               currQuant = 0;
               maxQuant = 0;
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
           maxQuant = 0;
           currQuant = 0;
           itemQuantity = 0;
           threshold = 0;
         });
       }
    });
  }

}