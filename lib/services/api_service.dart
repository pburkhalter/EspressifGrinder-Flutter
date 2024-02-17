import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show ByteData, rootBundle;

class ApiService {
  HttpClient? httpClient;

  ApiService({bool useTLS = false});

  Future<void> init({bool useTLS = false}) async {
    if (useTLS) {
      await createSelfSignedAPIClient();
    } else {
      createPlainAPIClient();
    }
  }

  void createPlainAPIClient() {

    httpClient = HttpClient();
  }

  Future<void> createSelfSignedAPIClient() async {
    ByteData certificate = await rootBundle.load("assets/certs/cert.pem");
    SecurityContext context = SecurityContext.defaultContext;
    context.setTrustedCertificatesBytes(certificate.buffer.asUint8List());
    httpClient = HttpClient(context: context);
  }

  Future<dynamic> _sendRequest(String endpoint, String method, [dynamic body]) async {
    try {
      Uri uri = Uri.parse(endpoint);
      HttpClientRequest? request;

      switch (method) {
        case 'POST':
          request = await httpClient?.postUrl(uri);
          break;
        case 'PUT':
          request = await httpClient?.putUrl(uri);
          break;
        case 'DELETE':
          request = await httpClient?.deleteUrl(uri);
          break;
        case 'GET':
        default:
          request = await httpClient?.getUrl(uri);
          break;
      }

      request?.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      if (body != null) {
        request?.write(jsonEncode(body)); // Assuming body is a Map for JSON payload
      }

      HttpClientResponse? response = await request?.close();
      return _processResponse(response!);

    } catch (e) {
      throw Exception('Failed to execute $method request: $e');
    }
  }

  Future<bool> uploadFile(String endpoint, String filePath) async {
    try {
      final uri = Uri.parse(endpoint);
      final fileContent = await File(filePath).readAsString();

      final response = await http.post(uri, body: fileContent, headers: {'Content-Type': 'text/plain'});

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        print('Failed to upload file: Server responded with status code ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Failed to upload file: $e');
      return false;
    }
  }

  Future<dynamic> _processResponse(HttpClientResponse response) async {
    final String content = await response.transform(utf8.decoder).join();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return content.isNotEmpty ? jsonDecode(content) : {};
    } else {
      throw Exception('Error: ${response.statusCode}, Body: $content');
    }
  }

  // Exposed methods
  Future<dynamic> get(String endpoint) => _sendRequest(endpoint, 'GET');
  Future<dynamic> post(String endpoint, dynamic body) => _sendRequest(endpoint, 'POST', body);
  Future<dynamic> put(String endpoint, dynamic body) => _sendRequest(endpoint, 'PUT', body);
  Future<dynamic> delete(String endpoint) => _sendRequest(endpoint, 'DELETE');
}
