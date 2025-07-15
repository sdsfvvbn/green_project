// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';

Future<String?> pickImage() async {
  final uploadInput = html.FileUploadInputElement();
  uploadInput.accept = 'image/*';
  uploadInput.click();
  final completer = Completer<String?>();
  uploadInput.onChange.listen((event) {
    final file = uploadInput.files?.first;
    if (file != null) {
      final reader = html.FileReader();
      reader.readAsDataUrl(file);
      reader.onLoadEnd.listen((event) {
        completer.complete(reader.result as String?);
      });
    }
  });
  return completer.future;
} 