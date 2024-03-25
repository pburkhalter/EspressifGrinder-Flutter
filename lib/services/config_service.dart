import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ConfigService {
  ConfigService();

  Future<void> copyConfigFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/config.json';
    final file = File(filePath);

    // Check if the file already exists
    if (!(await file.exists())) {
      final byteData = await rootBundle.load('assets/config/config.json');
      final buffer = byteData.buffer;
      await file.writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      print('Config file copied to ${filePath}');
    } else {
      print('Config file already exists at ${filePath}, skipping...');
    }
  }

  Future<dynamic> get(String key) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/config.json';

    try {
      final jsonString = await File(filePath).readAsString();
      final Map<String, dynamic> config = json.decode(jsonString);
      return config[key];
    } catch (e) {
      print(e);
      print('Could not read from config file!');
    }
    return null;
  }

  Future<void> set(String key, dynamic value) async {
    // Assuming you want to read the existing content, update it, and write back.
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/config.json';
    final file = File(filePath);

    Map<String, dynamic> config;
    try {
      final jsonString = await file.readAsString();
      config = json.decode(jsonString);
    } catch (e) {
      config = {};
    }

    config[key] = value;

    await file.writeAsString(json.encode(config));
  }
}
