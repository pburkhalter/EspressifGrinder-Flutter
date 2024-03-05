import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:espressif_grinder_flutter/services/cert_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';

class ApiService {
  HttpClient httpClient = HttpClient();
  CertificateService certService = CertificateService();
  bool useTLS = false;

  SharedPreferences? _prefs;

  ApiService();

  Future<void> init({bool useTLS = false}) async {
    this.useTLS = useTLS;
    _prefs ??= await SharedPreferences.getInstance();

    if (this.useTLS) {
      await createSelfSignedAPIClient();
    }
  }

  Future<void> createSelfSignedAPIClient() async {
    Uint8List? cert = await certService.loadCertPem();

    if(cert != null){
      SecurityContext securityContext = SecurityContext(withTrustedRoots: true);
      securityContext.setTrustedCertificatesBytes(cert.buffer.asUint8List());
      httpClient = HttpClient(context: securityContext);
    }
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

      // Retrieve the token from SharedPreferences and add it to the request headers
      String? token = await _getToken();
      if (token != null) {
        request.headers.set(HttpHeaders.authorizationHeader, "Bearer $token");
      }

      if (body != null) {
        if (body is String) {
          // For plain text content
          request.headers
              .set(HttpHeaders.contentTypeHeader, 'text/plain; charset=UTF-8');
          request.headers.contentLength = body.length;
          request.write(body);
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
      print(e);
      throw Exception('Failed to execute $method request: $e');
    }
  }

  Future<String?> _getToken() async {
    return _prefs?.getString('token');
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

  Future<bool> uploadCert(String endpoint, String certName) async {
    try {
      final uri = Uri.parse(endpoint);
      final fileBytes = await certService.loadCert(certName);

      // Base64 encode the bytes
      if(fileBytes != null){
        final String base64Encoded = base64Encode(fileBytes);

        // Send the Base64-encoded string as the request body
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'text/plain'},
          body: base64Encoded,
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          logger.i('File uploaded successfully');
          return true;
        } else {
          logger.e('Failed to upload file: Server responded with status code ${response.statusCode}');
        }
      } else {
        logger.e('Could not load certificate: $certName');
      }
    } catch (e) {
      logger.e('Failed to upload file: $e');
    }
    return false;
  }

  Future<dynamic> get(String endpoint) => _sendRequest(endpoint, 'GET');
  Future<dynamic> post(String endpoint, dynamic body) => _sendRequest(endpoint, 'POST', body);
  Future<dynamic> put(String endpoint, dynamic body) => _sendRequest(endpoint, 'PUT', body);
  Future<dynamic> delete(String endpoint) => _sendRequest(endpoint, 'DELETE');
}
