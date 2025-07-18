import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io' show File, Platform;

Future<String?> pickImage() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
  if (result != null) {
    if (result.files.single.bytes != null) {
      // 適用於 web
      return 'data:image/png;base64,' + base64Encode(result.files.single.bytes!);
    } else if (result.files.single.path != null) {
      // 適用於手機/桌面
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      return 'data:image/png;base64,' + base64Encode(bytes);
    }
  }
  return null;
}