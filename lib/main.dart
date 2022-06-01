import 'package:flutter/material.dart';
import 'dart:io';
import 'package:screen_capturer/screen_capturer.dart';

import 'package:clipboard/clipboard.dart';
import 'package:zxing2/qrcode.dart';
import 'package:image/image.dart' as img;

void main() async {
  runApp(const MyApp());
}

String tempImageLoc = '/home/ogreten/Desktop/captured_image.png';

Future<String> captureAndReadQRCode() async {
  try {
    CapturedData? capturedData = await ScreenCapturer.instance.capture(
      mode: CaptureMode.region, // screen, window
      imagePath: tempImageLoc,
    );
    // await Process.run('scrot', ['-s', '-o', tempImageLoc]);

    var image = img.decodePng(File(tempImageLoc).readAsBytesSync())!;

    LuminanceSource source = RGBLuminanceSource(image.width, image.height,
        image.getBytes(format: img.Format.abgr).buffer.asInt32List());
    var bitmap = BinaryBitmap(HybridBinarizer(source));

    var reader = QRCodeReader();
    var result = reader.decode(bitmap);

    await FlutterClipboard.copy(result.text);

    return result.text;
  } on Exception {
    print('Cannot read');
    return '';
  }

  // return qrCode.content?.text ?? '';
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
