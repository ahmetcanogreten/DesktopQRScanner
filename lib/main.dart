import 'package:flutter/material.dart';
import 'dart:io';
import 'package:screen_capturer/screen_capturer.dart';
import 'package:qr_code_vision/qr_code_vision.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dart_reed_solomon_nullsafety/dart_reed_solomon_nullsafety.dart';

void main() async {
  runApp(const MyApp());
}

String tempImageLoc = '/tmp/captured_image.png';

Future<String> captureAndReadQRCode() async {
  late QrCode qrCode;

  try {
    qrCode = QrCode();
    CapturedData? capturedData = await ScreenCapturer.instance.capture(
      mode: CaptureMode.region, // screen, window
      imagePath: tempImageLoc,
    );

    final imageByte = await File(tempImageLoc).readAsBytes();

    final im = await decodeImageFromList(imageByte);
    final byteImage = await im.toByteData();
    final byteListImage = byteImage!.buffer.asUint8List();

    qrCode.scanRgbaBytes(
        byteListImage, capturedData!.imageWidth!, capturedData.imageHeight!);

    if (qrCode.content != null) {
      await FlutterClipboard.copy(qrCode.content!.text);
    }
  } on ReedSolomonException {
    print('Cannot read');
  }

  return qrCode.content?.text ?? '';
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? qrContentText;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (qrContentText != null)
                InkWell(
                  onTap: () async {
                    await FlutterClipboard.copy(qrContentText!);
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
                          SelectableText(
                            qrContentText ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      )),
                ),
              const SizedBox(height: 100),
              ElevatedButton(
                  onPressed: () async {
                    late final readContent;
                    try {
                      readContent = await captureAndReadQRCode();
                    } on Exception {
                      readContent = '';
                    }

                    if (readContent.isEmpty) {
                      print('No QR Code Read.');
                    } else {
                      setState(() {
                        qrContentText = readContent;
                      });
                    }
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
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
