import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/logger.dart';

class CertificateService {
  CertificateService();

  Future<bool> generateAndSaveCertificates() async {
    try{
      // iOS & macOS prohibit TLS connections if validity period exceeds 825 days
      // we must also provide the SANs and EKUs in addition to the CN or the
      // handshake will fail

      var pair = CryptoUtils.generateEcKeyPair();
      var privateKey = pair.privateKey as ECPrivateKey;
      var publicKey = pair.publicKey as ECPublicKey;

      var dn = {
        'C': 'CH',
        'ST': 'LU',
        'L': 'LU',
        'O': 'CoffeeGrinder',
        'OU': 'CoffeeGrinder',
        'CN': 'coffeegrinder',
      };

      List<String> sans = ['coffeegrinder.local', 'coffeegrinder'];
      List<ExtendedKeyUsage> eku = [
        ExtendedKeyUsage.CLIENT_AUTH,
        ExtendedKeyUsage.SERVER_AUTH
      ];

      var csr = X509Utils.generateEccCsrPem(dn, privateKey, publicKey, san: sans);
      var x509PEM = X509Utils.generateSelfSignedCertificate(privateKey, csr, 365, sans: sans, extKeyUsage: eku);
      var privateKeyPem = CryptoUtils.encodeEcPrivateKeyToPem(privateKey);

      print(x509PEM);

      // Save the csr
      await saveCert('csr.pem', csr);
      await saveCert('csr.der', await convertPemToDer(csr));

      // Save the certificate
      await saveCert('cert.pem', x509PEM);
      await saveCert('cert.der', await convertPemToDer(x509PEM));

      // Save the private key
      await saveCert('key.pem', privateKeyPem);
      await saveCert('key.der', await convertPemToDer(privateKeyPem));

      return true;
    }
    catch(e){
      logger.e('Error generating certificate: $e');
      return false;
    }
  }

  Future<Uint8List?> convertPemToDer(String pemContent) async {
    try {
      // Identify and remove the appropriate PEM header and footer for certificates and keys
      pemContent = pemContent
          .replaceAll('-----BEGIN CERTIFICATE-----', '')
          .replaceAll('-----END CERTIFICATE-----', '')
          .replaceAll('-----BEGIN EC PRIVATE KEY-----', '')
          .replaceAll('-----END EC PRIVATE KEY-----', '')
          .replaceAll('-----BEGIN PUBLIC KEY-----', '')
          .replaceAll('-----END PUBLIC KEY-----', '')
          .replaceAll('\r\n', '')
          .replaceAll('\n', '');

      // Base64 decode to get DER bytes
      return base64.decode(pemContent);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveCert(String filename, dynamic content) async {
    final directory = await getApplicationDocumentsDirectory();
    final certsDirectory = Directory('${directory.path}/certs');
    final filePath = '${certsDirectory.path}/$filename';

    try{
      // Check if the certs directory exists, and if not, create it
      if (!await certsDirectory.exists()) {
        await certsDirectory.create(recursive: true);
      }

      // Check format of the certificate and save according to its type
      if(content is String){
        await File(filePath).writeAsString(content);
      } else if (content is Uint8List){
        await File(filePath).writeAsBytes(content);
      } else {
        Type type = content.runtimeType;
        logger.e('Certificate seems to have wrong type: $type');
      }
      logger.i('Certificate saved to $filePath');
      return true;
    } catch (e){
      logger.e('Error saving certificate $filePath: $e');
      return false;
    }
  }

  Future<Uint8List?> loadCert(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/certs/$filename';
    final file = File(filePath);

    try {
      if (await file.exists()) {
        final contentBytes = await file.readAsBytes();
        logger.i('Certificate loaded from $filePath');
        return contentBytes;
      } else {
        logger.e('Certificate not found: $filePath');
      }
    } catch (e) {
      logger.e('Error loading certificate: $e');
    }
    return null;
  }

  Future<Uint8List?> loadCSRPem() async {
    return loadCert('csr.pem');
  }

  Future<Uint8List?> loadCSRDer() async {
    return loadCert('csr.der');
  }

  Future<Uint8List?> loadCertPem() async {
    return loadCert('cert.pem');
  }

  Future<Uint8List?> loadKeyPem() async {
    return loadCert('key.pem');
  }

  Future<Uint8List?> loadCertDer() async {
    return loadCert('cert.der');
  }

  Future<Uint8List?> loadKeyDer() async {
    return loadCert('key.der');
  }
}
