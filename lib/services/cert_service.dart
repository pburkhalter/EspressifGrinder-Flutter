import 'dart:convert';
import 'dart:io';
import 'package:basic_utils/basic_utils.dart';
import 'package:path_provider/path_provider.dart';

class CertificateService {
  CertificateService();

  Future<bool> generateAndSaveCertificates() async {
    var pair = CryptoUtils.generateEcKeyPair();
    var privateKey = pair.privateKey as ECPrivateKey;
    var publicKey = pair.publicKey as ECPublicKey;

    var dn = {
      'CN': 'Self-Signed CoffeeGrinder',
    };

    var csr = X509Utils.generateEccCsrPem(dn, privateKey, publicKey);
    var x509PEM = X509Utils.generateSelfSignedCertificate(privateKey, csr, 365);
    var privateKeyPem = CryptoUtils.encodeEcPrivateKeyToPem(privateKey);

    // Save the certificate
    await saveFile('cert.pem', x509PEM);
    await saveDerToFile('cert.der', await convertPemToDer(x509PEM));

    // Save the private key
    await saveFile('key.pem', privateKeyPem);
    await saveDerToFile('key.der', await convertPemToDer(privateKeyPem));

    return true;
  }

  Future<void> saveFile(String filename, String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';
    await File(filePath).writeAsString(content);
    print('File saved to $filePath');
  }

  Future<void> saveDerToFile(String filename, List<int> derBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);
    await file.writeAsBytes(derBytes);
    print('DER file saved to $filePath');
  }

  Future<String> loadFile(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);

      // Check if the file exists before attempting to read it
      if (await file.exists()) {
        final content = await file.readAsString();
        print('File loaded from $filePath');
        return content;
      } else {
        print('File not found: $filePath');
        return 'File not found';
      }
    } catch (e) {
      // If an error occurs, print it and return an error message
      print('Error loading file: $e');
      return 'Error loading file';
    }
  }

  Future<List<int>> loadDerFromFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';
    final file = File(filePath);

    if (await file.exists()) {
      final derBytes = await file.readAsBytes();
      return derBytes;
    } else {
      throw Exception('File not found: $filePath');
    }
  }

  Future<List<int>> convertPemToDer(String pemContent) async {
    // Remove PEM header and footer
    String base64Content = pemContent.replaceAll('-----BEGIN CERTIFICATE-----', '')
        .replaceAll('-----END CERTIFICATE-----', '')
        .replaceAll('\r\n', '')
        .replaceAll('\n', '');

    // Base64 decode to get DER bytes
    List<int> derBytes = base64.decode(base64Content);

    return derBytes;
  }

  Future<String> loadCertPem() async {
    return loadFile('cert.pem');
  }

  Future<String> loadKeyPem() async {
    return loadFile('key.pem');
  }

  Future<List<int>> loadCertDer() async {
    return loadDerFromFile('cert.der');
  }

  Future<List<int>> loadKeyDer() async {
    return loadDerFromFile('key.der');
  }
}
