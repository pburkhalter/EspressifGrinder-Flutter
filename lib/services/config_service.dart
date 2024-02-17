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
      await file.writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      print('Config file copied to ${file.path}');
    } else {
      print('Config file already exists at ${file.path}');
    }
  }

  Future<String> get(String key) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/config.json';

    try {
      final jsonString = await File(filePath).readAsString();
      final Map<String, dynamic> config = json.decode(jsonString);
      return config['service_discovery_type'];
    } catch (e) {
      print('Could not read from config file!');
    }
    return '';
  }

  Future<void> set(String key, String value) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/config.json';
    final file = File(filePath);

    Map<String, dynamic> config = {key: value};

    await file.writeAsString(json.encode(config));
  }

}