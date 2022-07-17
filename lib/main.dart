import 'package:flutter/material.dart';
import 'dart:io';
import 'package:screen_capturer/screen_capturer.dart';

import 'package:clipboard/clipboard.dart';
import 'package:zxing2/qrcode.dart';
import 'package:image/image.dart' as img;

void main() async {
  runApp(const MyApp());
}

String tempImageLoc = '/tmp/captured_image.png';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? qrContentText;
  bool isCopied = false;

  Widget buildExtractedQRString() {
    return InkWell(
      onTap: () async {
        await FlutterClipboard.copy(qrContentText!);
        setState(() {
          isCopied = true;
        });
      },
      child: Container(
          padding: const EdgeInsets.all(50),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.copy),
              const SizedBox(width: 16),
              isCopied
                  ? const Text('Copied!')
                  : SelectableText(
                      qrContentText ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
            ],
          )),
    );
  }

  Widget buildScanQRButton() {
    return ElevatedButton(
        onPressed: () async {
          final readContent = await captureAndReadQRCode();

          setState(() {
            isCopied = false;
            qrContentText = readContent;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.qr_code_scanner, size: 100),
              Text(
                'Scan QR',
                style: TextStyle(fontSize: 50),
              )
            ],
          ),
        ));
  }

  Future<String> captureAndReadQRCode() async {
    try {
      CapturedData? capturedData = await ScreenCapturer.instance.capture(
        mode: CaptureMode.region, // screen, window
        imagePath: tempImageLoc,
      );

      var image = img.decodePng(File(tempImageLoc).readAsBytesSync())!;

      LuminanceSource source = RGBLuminanceSource(image.width, image.height,
          image.getBytes(format: img.Format.abgr).buffer.asInt32List());
      var bitmap = BinaryBitmap(HybridBinarizer(source));

      var reader = QRCodeReader();
      var result = reader.decode(bitmap);

      await FlutterClipboard.copy(result.text);
      return result.text;
    } on Exception {
      return 'Could not read QR code';
    }

    // return qrCode.content?.text ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Desktop QR Scanner',
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (qrContentText != null) buildExtractedQRString(),
              const SizedBox(height: 100),
              buildScanQRButton()
            ],
          ),
        ),
      ),
    );
  }
}
