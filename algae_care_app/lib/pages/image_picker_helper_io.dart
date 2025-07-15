import 'package:file_picker/file_picker.dart';
import 'dart:convert';

Future<String?> pickImage() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
  if (result != null && result.files.single.bytes != null) {
    return 'data:image/png;base64,' + base64Encode(result.files.single.bytes!);
  }
  return null;
} 