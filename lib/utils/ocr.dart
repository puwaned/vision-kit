import 'package:flutter/services.dart';

const platform = MethodChannel('flutter.poc.ocr');

class OcrHelper {
  const OcrHelper._();

  static Future<String?> imageToText({
    required String imagePath,
  }) async {
    try {
      final result = await platform.invokeMethod('getText', imagePath);
      print('not error');
      return result;
    } catch (err) {
      print(err);
      return null;
    }
  }
}

