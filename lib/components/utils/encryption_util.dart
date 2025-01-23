import 'package:encrypt/encrypt.dart';

class EncryptionUtil {
  // Define encryption key and IV
  static final _key = Key.fromUtf8('SLPWMazw6EZ2XX3CfEu02RH7xYX0DSP4'); // Must be 32 bytes
  static final _iv = IV.fromLength(16); // Must be 16 bytes

  // Encrypt data
  static String encryptData(String plaintext) {
    final encrypter = Encrypter(AES(_key));
    final encrypted = encrypter.encrypt(plaintext, iv: _iv);
    return encrypted.base64;
  }

  // Decrypt data
  static String decryptData(String ciphertext) {
    final encrypter = Encrypter(AES(_key));
    final decrypted = encrypter.decrypt64(ciphertext, iv: _iv);
    return decrypted;
  }
}

