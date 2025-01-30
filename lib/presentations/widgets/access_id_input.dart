import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/datas/models/remote/access_id.dart';
import 'package:kokiku/presentations/blocs/inventory/inventory_bloc.dart';
import 'package:kokiku/presentations/widgets/custom_toast.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AccessIdInput extends StatefulWidget {
  const AccessIdInput({super.key});

  @override
  State<AccessIdInput> createState() => _AccessIdInputState();
}

class _AccessIdInputState extends State<AccessIdInput> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _createNewAccessId() async {
    final user = _auth.currentUser;
    if (user == null) return;

    String? accessIdName = await _showCreateAccessIdDialog(context);
    if (accessIdName == null || accessIdName.isEmpty) {
      if (mounted) {
        showToast(
          context: context,
          icon: Icon(Icons.question_mark),
          title: 'No Name Entered',
          message: 'Please enter a name for the Access ID',
          color: Colors.black,
        );
      }
      return;
    }

    String newAccessId = Uuid().v4();
    AccessId newAccess = AccessId(
      id: newAccessId,
      name: accessIdName,
      createdAt: DateTime.now(),
    );

    try {
      await _firestore.collection('accessIds').doc(newAccessId).set(newAccess.toFirestore());

      await _firestore.collection('users').doc(user.uid).update({
        'accessIds': FieldValue.arrayUnion([newAccessId])
      });

      if (mounted) {
        context.read<InventoryBloc>().add(LoadInventory());
      }
    } catch (e) {
      if (mounted) {
        showErrorToast(
          context: context,
          title: 'Error Occurred!',
          message: 'Error: $e',
        );
      }
    }
  }

  void _openQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(onScan: _saveAccessId),
      ),
    );
  }

  Future<void> _saveAccessId(String scannedCode) async {
    if (scannedCode.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      var accessIdDoc = await _firestore.collection('accessIds').doc(scannedCode).get();

      if (accessIdDoc.exists) {
        await _firestore.collection('users').doc(user.uid).update({
          'accessIds': FieldValue.arrayUnion([scannedCode])
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Access ID added: $scannedCode')));
        if (mounted) {
          context.read<InventoryBloc>().add(LoadInventory());
        }
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid Access ID')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving Access ID')));
    }
  }

  Future<String?> _showCreateAccessIdDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create New Access ID'),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Access ID Name',
                hintText: 'i.e. My House',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, nameController.text.trim());
              },
              child: Text('Create Access ID'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "It appears you haven't added any Access ID.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _createNewAccessId,
            icon: Icon(Icons.add),
            label: Text("Create New Access ID"),
          ),
          ElevatedButton.icon(
            onPressed: _openQRScanner,
            icon: Icon(Icons.qr_code_scanner),
            label: Text("Scan QR Code"),
          ),
        ],
      ),
    );
  }
}

class QRScannerScreen extends StatelessWidget {
  final Function(String) onScan;

  const QRScannerScreen({super.key, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan QR Code")),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            String scannedCode = barcodes.first.rawValue ?? "";
            onScan(scannedCode);
          }
        },
      ),
    );
  }
}
