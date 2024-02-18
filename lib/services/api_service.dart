import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';

class ApiService {
  HttpClient httpClient = HttpClient();

  ApiService({bool useTLS = false});

  Future<void> init({bool useTLS = false}) async {
    if (useTLS) {
      await createSelfSignedAPIClient();
    }
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
      HttpClientRequest request;

      // Initialize the request based on the method
      switch (method) {
        case 'POST':
          request = await httpClient.postUrl(uri);
          break;
        case 'PUT':
          request = await httpClient.putUrl(uri);
          break;
        case 'DELETE':
          request = await httpClient.deleteUrl(uri);
          break;
        case 'GET':
          request = await httpClient.getUrl(uri);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // Set Content-Type and prepare the body
      if (body != null) {
        if (body is String) {
          // For plain text content
          request.headers.set(HttpHeaders.contentTypeHeader, 'text/plain; charset=UTF-8');
          request.headers.contentLength = body.length;
          request.write(body); // Directly write the string body
        } else if (body is Map || body is List) {
          // For JSON content
          var encodedBody = utf8.encode(json.encode(body));
          request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=UTF-8');
          request.headers.contentLength = encodedBody.length;
          request.add(encodedBody); // Use add for byte data
        } else {
          // Handle other types if necessary, default to JSON
          var encodedBody = utf8.encode(json.encode(body.toString()));
          request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=UTF-8');
          request.add(encodedBody);
        }
      }

      HttpClientResponse response = await request.close();
      // Process the response
      return _processResponse(response);
    } catch (e) {
      throw Exception('Failed to execute $method request: $e');
    }
  }



  Future<bool> uploadFile(String endpoint, String filePath) async {
    try {
      final uri = Uri.parse(endpoint);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filePath');

      // Read the file as bytes
      final fileBytes = await file.readAsBytes();

      // Base64 encode the bytes
      final String base64Encoded = base64Encode(fileBytes);

      // Send the Base64-encoded string as the request body
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'text/plain'},
        body: base64Encoded,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('File uploaded successfully');
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
      try {
        // Attempt to decode JSON only if the content is not empty
        if (content.isNotEmpty) {
          return jsonDecode(content);
        } else {
          return {}; // Return an empty object if the content is empty
        }
      } catch (e) {
        // If jsonDecode throws an exception (e.g., not valid JSON), return the raw content
        return content;
      }
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
