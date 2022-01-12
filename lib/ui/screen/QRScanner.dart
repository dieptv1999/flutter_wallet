import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wallet/model/transaction.dart';
import 'package:flutter_wallet/services/db_service.dart';
import 'package:flutter_wallet/services/web3_service.dart';
import 'package:flutter_wallet/util/file_path.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:web3dart/credentials.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key,}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Web3Service web3Service = Web3Service();
  DbService db = DbService();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if (result != null)
                      Text(
                          'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                    else
                      const Text('Scan a code', style: TextStyle(fontSize: 14),),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 500 ||
        MediaQuery.of(context).size.height < 500)
        ? 200.0
        : 500.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });
      String? code = scanData.code;
      try {
        EthereumAddress address = EthereumAddress.fromHex(code!);
        controller.pauseCamera();
        String result = await web3Service.sendTransaction(address.hexEip55, 0.01);
        db.insertTransaction(TransactionCustom(
          createdMillis: DateTime.now().millisecondsSinceEpoch,
          name: result,
          point: 0.01,
          status: 1,
        ));
        Navigator.pop(context);
      } catch(e) {
        print(e);
        controller.resumeCamera();
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}