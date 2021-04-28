import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:ssh_key/ssh_key.dart' as ssh_key;

class RSAKeyPair {
  late final String private;
  late final String public;

  RSAKeyPair() {
    final pair = _generateRSAKeyPair(_exampleSecureRandom());
    public = pair.publicKey.encode(ssh_key.PubKeyEncoding.openSsh);
    private = pair.privateKey.encode(ssh_key.PvtKeyEncoding.openSsh);
    print(public);
    print(private);
  }

  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> _generateRSAKeyPair(SecureRandom secureRandom,
      {int bitLength = 2048}) {
    // Create an RSA key generator and initialize it

    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64), secureRandom));

    // Use the generator

    final pair = keyGen.generateKeyPair();

    // Cast the generated key pair into the RSA key types

    final myPublic = pair.publicKey as RSAPublicKey;
    final myPrivate = pair.privateKey as RSAPrivateKey;

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
  }

  static SecureRandom _exampleSecureRandom() {
    final secureRandom = FortunaRandom();

    final seedSource = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    return secureRandom;
  }
}
