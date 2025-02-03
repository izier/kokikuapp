import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kokiku/constants/services/localization_service.dart';
import 'package:kokiku/datas/models/remote/access_id.dart';
import 'package:kokiku/presentations/blocs/inventory/inventory_bloc.dart';
import 'package:kokiku/presentations/pages/inventory/qr_scanner_page.dart';
import 'package:kokiku/presentations/widgets/custom_toast.dart';
import 'package:uuid/uuid.dart';

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

    final localization = LocalizationService.of(context)!;

    String? accessIdName = await _showCreateAccessIdDialog(context);
    if (accessIdName == null || accessIdName.isEmpty) {
      if (mounted) {
        showToast(
          context: context,
          icon: Icon(Icons.question_mark),
          title: localization.translate('no_name_entered'),
          message: localization.translate('enter_name_for_access_id'),
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

      showSuccessToast(
        context: context,
        title: localization.translate('access_id_added'),
        message: "${localization.translate('successfully_added_access_id')}: ${newAccess.name}",
      );
      if (mounted) {
        context.read<InventoryBloc>().add(LoadInventory());
      }
    } catch (e) {
      if (mounted) {
        showErrorToast(
          context: context,
          title: localization.translate('error_occurred'),
          message: "${localization.translate('error')}: $e",
        );
      }
    }
  }

  void _openQRScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScannerPage(onScan: _saveAccessId),
      ),
    );
  }

  Future<void> _saveAccessId(String scannedCode) async {
    final localization = LocalizationService.of(context)!;
    if (scannedCode.isEmpty) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      var accessIdDoc = await _firestore.collection('accessIds').doc(scannedCode).get();

      if (accessIdDoc.exists) {
        await _firestore.collection('users').doc(user.uid).update({
          'accessIds': FieldValue.arrayUnion([scannedCode])
        });
        showSuccessToast(
          context: context,
          title: localization.translate('access_id_connected'),
          message: "${localization.translate('successfully_connected_access_id')}: $scannedCode",
        );
        context.read<InventoryBloc>().add(LoadInventory());
      } else {
        showErrorToast(
          context: context,
          title: localization.translate('error_occurred'),
          message: localization.translate('invalid_access_id'),
        );
      }
    } catch (e) {
      showErrorToast(
        context: context,
        title: localization.translate('error_occurred'),
        message: localization.translate('error_saving_access_id'),
      );
    }
  }

  Future<String?> _showCreateAccessIdDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    final localization = LocalizationService.of(context)!;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localization.translate('create_new_access_id')),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: localization.translate('access_id_name'),
                hintText: localization.translate('i_e_my_house'),
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
              child: Text(localization.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, nameController.text.trim());
              },
              child: Text(localization.translate('create_access_id')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationService.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            localization.translate('no_access_id_added'),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _createNewAccessId,
            icon: Icon(Icons.add),
            label: Text(localization.translate('create_new_access_id')),
          ),
          ElevatedButton.icon(
            onPressed: _openQRScanner,
            icon: Icon(Icons.qr_code_scanner),
            label: Text(localization.translate('scan_qr_code')),
          ),
        ],
      ),
    );
  }
}
