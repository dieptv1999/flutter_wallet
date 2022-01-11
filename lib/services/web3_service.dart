import 'dart:io';
import 'dart:math'; //used for the random number generator
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

const apiUrl = "https://bsc-dataseed.binance.org";
var httpClient = Client();
var ethClient = Web3Client(apiUrl, httpClient);

class Web3Service {
  static final Web3Service _singleton = Web3Service._internal();

  factory Web3Service() {
    return _singleton;
  }

  Web3Service._internal();

  Future<String> createWallet(String privateKey) async {
    EthPrivateKey privKey = EthPrivateKey.fromHex(privateKey);
    Uint8List pubKey = privateKeyToPublic(privKey.privateKeyInt);

    Uint8List address =
        publicKeyToAddress(pubKey);
    String addressHex =
        bytesToHex(address, include0x: true, forcePadLength: 40);
    var random = Random.secure();
    Wallet wallet = Wallet.createNew(privKey, "password", random);
    await writeWallet(wallet.toJson());
    return addressHex;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/wallet.json');
  }

  Future<File> writeWallet(String text) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(text);
  }

  Future<String> readWallet() async {
    try {
      final file = await _localFile;

      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      return "";
    }
  }

  Future<double> getBalance() async {
    String content = await readWallet();
    Wallet wallet = Wallet.fromJson(content, "password");
    var credentials = EthPrivateKey.fromHex(wallet.privateKey.address.hex);

    EtherAmount balance = await ethClient.getBalance(credentials.address);
    print(balance.getValueInUnit(EtherUnit.ether));
    return 0;
  }
}
