
import "dart:io";
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
class Scanner extends StatefulWidget {
  final int mode;
  const Scanner({Key? key, required this.mode}) : super(key: key);

  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late QRViewController controller;
  var scannedData = 'Scan a code';
  Barcode? result;
  late int mode;

  @override
  void initState() {
    mode = widget.mode;
    super.initState();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scanner"),
      ),
      body: Stack(
        children: [
          Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Stack(
                  children: [
                    QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                    ),
                    Center(
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: result != null ? Colors.green : Colors.red,
                            width: 4,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: (result != null)
                      ? Column(
                    children: [
                      Text( mode == 1 ? 'Watcher oobi: ${result!.code}' : mode == 2 ? 'issuer and witness oobi: ${result!.code}' : mode == 3 ? 'ACDC: ${result!.code}' :
                       'Incorrect mode'),
                      RawMaterialButton(
                          onPressed: () {
                            Navigator.pop(context, result!.code);
                          },
                          child: Text("Accept", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(width: 2, color: Colors.green)
                          )
                      ),
                    ],
                  )
                      : Text('Scan a code'),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }
}