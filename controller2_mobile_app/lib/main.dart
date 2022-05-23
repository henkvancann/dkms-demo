import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:dkms_demo/scanner.dart';
import 'package:ed25519_signing_plugin/ed25519_signer.dart';
import 'package:ed25519_signing_plugin/thclab_signing_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vector_math/vector_math.dart';

import 'bridge_generated.dart';

// Simple Flutter code. If you are not familiar with Flutter, this may sounds a bit long. But indeed
// it is quite trivial and Flutter is just like that. Please refer to Flutter's tutorial to learn Flutter.

const base = 'dartkeriox';
final path = Platform.isWindows ? '$base.dll' : 'lib$base.so';
late final dylib = Platform.isIOS
    ? DynamicLibrary.process()
    : Platform.isMacOS
    ? DynamicLibrary.executable()
    : DynamicLibrary.open(path);
late final api = KeriDartImpl(dylib);

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  var signer = await THCLabSigningPlugin.establishForEd25519();
  runApp(MaterialApp(home: MyApp(signer: signer,),debugShowCheckedModeBanner: false,));
}

class MyApp extends StatefulWidget {
  final Ed25519Signer signer;
  const MyApp({Key? key, required this.signer}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Uint8List? exampleImage;
  String? exampleText;
  late Socket socket;
  var platform = const MethodChannel('samples.flutter.dev/getkey');
  var current_b64_key='';
  var next_b64_key='';
  var watcher_oobi ='';
  var issuer_oobi ='';
  var icp_event;
  var hex_signature = '';
  var hex_sig = '';
  var signature;
  var controller;
  var kel;
  var sig2;
  var isVerified;
  var key_sig_pair;
  var toVerify = '';
  //var rotated;
  var add_watcher_message;
  //var attachment = '{"v":"ACDC10JSON00019e_","d":"EzSVC7-SuizvdVkpXmHQx5FhUElLjUOjCbgN81ymeWOE","s":"EWCeT9zTxaZkaC_3-amV2JtG6oUxNA36sCC0P5MI7Buw","i":"Ew-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M","a":{"d":"EbFNz3vOMBbzp5xmYRd6rijvq08DCe07bOR-DA5fzO6g","i":"EeWTHzoGK_dNn71CmJh-4iILvqHGXcqEoKGF4VUc6ZXI","dt":"2022-04-11T20:50:23.722739+00:00","LEI":"5493001KJTIIGC8Y1R17"},"e":{},"ri":"EoLNCdag8PlHpsIwzbwe7uVNcPE1mTr-e1o9nCIDPWgM"}-JAB6AABAAA--FABEw-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M0AAAAAAAAAAAAAAAAAAAAAAAEw-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M-AABAAKcvAE-GzYu4_aboNjC0vNOcyHZkm5Vw9-oGGtpZJ8pNdzVEOWhnDpCWYIYBAMVvzkwowFVkriY3nCCiBAf8JDw';
  //String stream = '{"v":"KERI10JSON0001b7_","t":"icp","d":"Ew-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M","i":"Ew-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M","s":"0","kt":"1","k":["DruZ2ykSgEmw2EHm34wIiEGsUa_1QkYlsCAidBSzUkTU"],"nt":"1","n":["Eao8tZQinzilol20Ot-PPlVz6ta8C4z-NpDOeVs63U8s"],"bt":"3","b":["BGKVzj4ve0VSd8z_AmvhLg4lqcC_9WYX90k03q-R_Ydo","BuyRFMideczFZoapylLIyCjSdhtqVb31wZkRKvPfNqkw","Bgoq68HCmYNUDgOz4Skvlu306o_NY-NrYuKAVhk3Zh9c"],"c":[],"a":[]}-VBq-AABAA0EpZtBNLxOIncUDeLgwX3trvDXFA5adfjpUwb21M5HWwNuzBMFiMZQ9XqM5L2bFUVi6zXomcYuF-mR7CFpP8DQ-BADAAWUZOb17DTdCd2rOaWCf01ybl41U7BImalPLJtUEU-FLrZhDHls8iItGRQsFDYfqft_zOr8cNNdzUnD8hlSziBwABmUbyT6rzGLWk7SpuXGAj5pkSw3vHQZKQ1sSRKt6x4P13NMbZyoWPUYb10ftJlfXSyyBRQrc0_TFqfLTu_bXHCwACKPLkcCa_tZKalQzn3EgZd1e_xImWdVyzfYQmQvBpfJZFfg2c-sYIL3zl1WHpMQQ_iDmxLSmLSQ9jZ9WAjcmDCg-EAB0AAAAAAAAAAAAAAAAAAAAAAA1AAG2022-04-11T20c50c16d643400p00c00{"v":"KERI10JSON00013a_","t":"ixn","d":"Ek48ahzTIUA1ynJIiRd3H0WymilgqDbj8zZp4zzrad-w","i":"Ew-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M","s":"1","p":"Ew-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M","a":[{"i":"EoLNCdag8PlHpsIwzbwe7uVNcPE1mTr-e1o9nCIDPWgM","s":"0","d":"EoLNCdag8PlHpsIwzbwe7uVNcPE1mTr-e1o9nCIDPWgM"}]}-VBq-AABAAZZlCpwL0QwqF-eTuqEgfn95QV9S4ruh4wtxKQbf1-My60Nmysprv71y0tJGEHkMsUBRz0bf-JZsMKyZ3N8m7BQ-BADAA6ghW2PpLC0P9CxmW13G6AeZpHinH-_HtVOu2jWS7K08MYkDPrfghmkKXzdsMZ44RseUgPPty7ZEaAxZaj95bAgABKy0uBR3LGMwg51xjMZeVZcxlBs6uARz6quyl0t65BVrHX3vXgoFtzwJt7BUl8LXuMuoM9u4PQNv6yBhxg_XEDwACJe4TwVqtGy1fTDrfPxa14JabjsdRxAzZ90wz18-pt0IwG77CLHhi9vB5fF99-fgbYp2Zoa9ZVEI8pkU6iejcDg-EAB0AAAAAAAAAAAAAAAAAAAAAAQ1AAG2022-04-11T20c50c22d909900p00c00{"v":"KERI10JSON00013a_","t":"ixn","d":"EPYT0dEpoc_5QKIGnRYFRqpXHGpeYOhveJTmHoVC6LMU","i":"Ew-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M","s":"2","p":"Ek48ahzTIUA1ynJIiRd3H0WymilgqDbj8zZp4zzrad-w","a":[{"i":"EzSVC7-SuizvdVkpXmHQx5FhUElLjUOjCbgN81ymeWOE","s":"0","d":"EQ6RIFoVUDmmyuoMDMPPHDm14GtXaIf98j4AG2vNfZ1U"}]}-VBq-AABAAYycRM_VyvV2fKyHdUceMcK8ioVrBSixEFqY1nEO9eTZQ2NV8hrLc_ux9_sKn1p58kyZv5_y2NW3weEiqn-5KAA-BADAAQl22xz4Vzkkf14xsHMAOm0sDkuxYY8SAgJV-RwDDwdxhN4WPr-3Pi19x57rDJAE_VkyYwKloUuzB5Dekh-JzCQABk98CK_xwG52KFWt8IEUU-Crmf058ZJPB0dCffn-zjiNNgjv9xyGVs8seb0YGInwrB351JNu0sMHuEEgPJLKxAgACw556h2q5_BG6kPHAF1o9neMLDrZN_sCaJ-3slWWX-y8M3ddPN8Zp89R9A36t3m2rq-sbC5h_UDg5qdnrZ-ZxAw-EAB0AAAAAAAAAAAAAAAAAAAAAAg1AAG2022-04-11T20c50c23d726188p00c00';
  var parsedAttachment;
  var acdc ='';
  var keyForAcdc;
  var signatureForAcdc;
  var id;
  late Ed25519Signer signer;


  @override
  void initState() {
    signer = widget.signer;
    super.initState();
    //_initACDC();
    //_callExampleFfiTwo();
    // socketConn().then((value) {
    //   _callExampleFfiTwo();
    // });
  }

  Future<void> socketConn()async{
    socket = await Socket.connect('192.168.1.30', 23);
    print('connected');
    // listen to the received data event stream
    socket.listen((List<int> event) {
      print(utf8.decode(event));
    });

    // send hello
    //socket.add(utf8.encode('hello'));
  }

  Future<bool> _verify(String message, String signature, String key) async{
    var result = await platform.invokeMethod('verify', {'message': message, 'signature': signature, 'key' : key});
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 80,),
            Text('1. Scan for watcher oobi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
            //Text(attachment),
            RawMaterialButton(
                onPressed: () async{
                  watcher_oobi = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Scanner(mode: 1,)),
                  );
                  setState(() {

                  });
                  String dbPath = await getLocalPath();
                  current_b64_key = await signer.getCurrentPubKey();
                  next_b64_key = await signer.getNextPubKey();
                  //print(json.decode(watcher_oobi)[0]["eid"]);
                  await api.initKel(inputAppDir: dbPath);

                  List<PublicKey> vec1 = [];
                  vec1.add(PublicKey(algorithm: KeyType.Ed25519, key: current_b64_key));
                  List<PublicKey> vec2 = [];
                  vec2.add(PublicKey(algorithm: KeyType.Ed25519, key: next_b64_key));
                  List<String> vec3 = [];
                  print("incept keys: ${vec1[0].key}, ${vec2[0].key}");
                  icp_event = await api.incept(publicKeys: vec1, nextPubKeys: vec2, witnesses: vec3, witnessThreshold: 0);
                  hex_signature = await signer.sign(icp_event);
                  print("Hex signature: $hex_signature");

                  //Sign icp event
                  signature = Signature(algorithm: SignatureType.Ed25519Sha512, key: hex_signature);

                  controller = await api.finalizeInception(event: icp_event, signature: signature);
                  kel = await api.getKel(cont: controller);
                  print("Current controller kel: $kel");

                  add_watcher_message = await api.addWatcher(controller: controller, watcherOobi: watcher_oobi);
                  print("\nController generate end role message to add witness: $add_watcher_message");

                  hex_sig = await signer.sign(add_watcher_message);
                  signature = Signature(algorithm: SignatureType.Ed25519Sha512, key: hex_sig);

                  await api.finalizeEvent(identifier: controller, event: add_watcher_message, signature: signature);
                  // var splitList = splitMessage(attachment);
                  // print(splitList);
                  // //print(splitList[1].split('-FAB'));
                  // acdc = splitList[0] +"}";
                  // //id = acdc.toString().en
                  // print(id);
                  // var theRest = splitList[1].split('-FAB');
                  // var attachmentNew = '-FAB' + theRest[1];
                  // //print(attachment);
                  // parsedAttachment = await api.parseAttachment(attachment: attachmentNew);
                  // print(parsedAttachment[0].key);
                  // id = 'Ew-o5dU5WjDrxDBK4b4HrF82_rYb6MX6xsegjq4n0Y7M';
                  // keyForAcdc = parsedAttachment?[0].key.key;
                  // signatureForAcdc = parsedAttachment?[0].hex_signature.key;
                  // setState(() {
                  //
                  // });
                  // //isVerified = await _verify(acdc.toString(), signatureForAcdc.toString(), keyForAcdc.toString());
                  // setState(() {
                  //
                  // });
                },
                child: Text("Scan", style: TextStyle(fontWeight: FontWeight.bold),),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(width: 2)
                )
            ),
            Text(watcher_oobi.toString()),
            SizedBox(height: 20,),
            watcher_oobi.isNotEmpty ? Text('2. Scan for issuer oobi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),) : Container(),
            watcher_oobi.isNotEmpty ? RawMaterialButton(
                onPressed: () async{
                  issuer_oobi = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Scanner(mode: 2,)),
                  );
                  //var oobi_json = "[{\"cid\":\"EnXSw7ziFZR1h2TgTII5oZpwRquvlguejE5a2-RFc4tY\",\"role\":\"witness\",\"eid\":\"BSuhyBcPZEZLK-fcw5tzHn2N46wRCG_ZOoeKtWTOunRA\"},{\"eid\":\"BSuhyBcPZEZLK-fcw5tzHn2N46wRCG_ZOoeKtWTOunRA\",\"scheme\":\"http\",\"url\":\"http://192.168.1.30:3232/\"}]";
                  print("\nSending issuer oobi to watcher: $issuer_oobi");
                  await api.propagateOobi(controller: controller, oobisJson: issuer_oobi);
                  print("Querying abour issuer kel...");
                  var iss_id = "EnXSw7ziFZR1h2TgTII5oZpwRquvlguejE5a2-RFc4tY";
                  await api.query(controller: controller, queryId: iss_id);
                  var issuer_kel = await api.getKelByStr(contId: iss_id);
                  print("Issuer kel: $issuer_kel");
                  setState(() {

                  });
                },
                child: Text("Scan", style: TextStyle(fontWeight: FontWeight.bold),),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(width: 2)
                )
            ) : Container(),
            Text(issuer_oobi.toString()),
            issuer_oobi.isNotEmpty ? Text('3. Scan for ACDC:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),) : Container(),
            issuer_oobi.isNotEmpty ? RawMaterialButton(
                onPressed: () async{
                  acdc = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Scanner(mode: 3,)),
                  );
                  setState(() {

                  });
                  var splitAcdc = acdc.split('-FAB');
                  print(splitAcdc);
                  var attachmentStream = '-FAB' + splitAcdc[1];
                  toVerify = splitAcdc[0];
                  print(attachmentStream);
                  key_sig_pair = await api.getCurrentPublicKey(attachment: attachmentStream);
                  print(key_sig_pair);
                },
                child: Text("Scan", style: TextStyle(fontWeight: FontWeight.bold),),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(width: 2)
                )
            ) : Container(),
            Text(acdc),
            acdc.isNotEmpty ? Text('4. Verify ACDC:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),) : Container(),
            acdc.isNotEmpty ? RawMaterialButton(
                onPressed: () async{
                  print(key_sig_pair[0].signature.key.toString());
                  print(key_sig_pair[0].key.key.toString());
                  isVerified = await _verify(toVerify.toString(), key_sig_pair[0].signature.key.toString(), key_sig_pair[0].key.key.toString());
                  setState(() {
                    
                  });
                },
                child: Text("Verify", style: TextStyle(fontWeight: FontWeight.bold),),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(width: 2)
                )
            ) : Container(),
            isVerified != null ? (isVerified ? Text("Verification successful", style: TextStyle(color: Color(0xff21821e)),) : Text("Verification error", style: TextStyle(color: Color(0xff781a22)),)): Container(),


            // id != null ? Text("Getting kel for:", style: TextStyle(fontWeight: FontWeight.bold),) : Container(),
            // id != null ? Text("$id") : Container(),
            // SizedBox(height: 10,),
            // keyForAcdc!= null ?  Text("Public key:", style: TextStyle(fontWeight: FontWeight.bold),) : Container(),
            // keyForAcdc!= null ?  Text("$keyForAcdc") : Container(),
            // SizedBox(height: 10,),
            // signatureForAcdc!= null ?  Text("Signature:" , style: TextStyle(fontWeight: FontWeight.bold),) : Container(),
            // signatureForAcdc!= null ?  Text("$signatureForAcdc") : Container(),
            // SizedBox(height: 10,),
            // isVerified != null ? (isVerified ? Text("Verification successful", style: TextStyle(color: Color(0xff21821e)),) : Text("Verification error", style: TextStyle(color: Color(0xff781a22)),)): Container(),
            // Text("Aktualne klucze:"),
            // Text(key_pub_1),
            // Text(key_pub_2),
            // Divider(),
            // Text("ICP event:"),
            // Text(icp_event ?? ""),
            // Divider(),
            // RawMaterialButton(
            //   onPressed: () async{
            //     signature = await _sign(icp_event);
            //     controller = await api.finalizeInception(event: icp_event, signature: Signature(algorithm: SignatureType.Ed25519Sha512, key: signature));
            //     kel = await api.getKel(id: controller.identifier);
            //     print(kel);
            //     socket.add(utf8.encode(kel));
            //     setState(() {
            //
            //     });
            //   },
            //   child: Text("Podpisz"),
            // ),
            // Text(signature),
            // Divider(),
            // RawMaterialButton(
            //     onPressed: () async{
            //       //ROTATION
            //       rotated = await localRotate(controller);
            //       print("rotacja: $rotated");
            //       sig2 = await _sign(rotated);
            //       print("podpisana rotacja: $sig2");
            //       await api.finalizeEvent(event: rotated, signature: Signature(algorithm: SignatureType.Ed25519Sha512, key: sig2));
            //       var toPrint2 = await api.getKel(id: controller.identifier);
            //       socket.add(utf8.encode(toPrint2));
            //       setState(() {});
            //     },
            //   child: Text("Rotacja"),
            // ),
            // Text(sig2 ?? ""),
            // Divider(),
            // Text("Kel"),
            // Text(kel ?? ""),
            // Divider(),
            // RawMaterialButton(
            //   onPressed: () async{
            //     isVerified = await _verify(acdc.toString(), signatureForAcdc.toString(), keyForAcdc.toString());
            //     setState(() {
            //
            //     });
            //   },
            //   child: Text("Zweryfikuj"),
            // ),
            // Text(isVerified.toString()),
            // Divider(),
            // Text("Attachment"),
            // Text(attachment),
            // RawMaterialButton(
            //   onPressed: () async{
            //     var splitList = splitMessage(attachment);
            //     print(splitList);
            //     //print(splitList[1].split('-FAB'));
            //     acdc = splitList[0] +"}";
            //     var theRest = splitList[1].split('-FAB');
            //     attachment = '-FAB' + theRest[1];
            //     print(attachment);
            //     parsedAttachment = await api.parseAttachment(attachment: attachment);
            //     print(parsedAttachment[0].key);
            //     keyForAcdc = parsedAttachment?[0].key.key;
            //     signatureForAcdc = parsedAttachment?[0].signature.key;
            //     setState(() {
            //
            //     });
            //   },
            //   child: Text("Parse"),
            // ),
            // Text("key: ${keyForAcdc ?? ""}"),
            // Text("signature: ${signatureForAcdc ?? ""}"),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _callExampleFfiTwo() async {
    String dbPath = await getLocalPath();
    await api.initKel(inputAppDir: dbPath);
    //key_pub_1 = await _getPublicKey1();
    //key_pub_2 = await _getPublicKey2();
    List<PublicKey> vec1 = [];
    vec1.add(PublicKey(algorithm: KeyType.Ed25519, key: current_b64_key));
    List<PublicKey> vec2 = [];
    vec2.add(PublicKey(algorithm: KeyType.Ed25519, key: next_b64_key));
    List<String> vec3 = [];
    icp_event = await api.incept(publicKeys: vec1, nextPubKeys: vec2, witnesses: vec3, witnessThreshold: 0);
    //var signature = await _sign(icp_event);
    //await api.processStream(stream: stream);
    setState(() {});

  }

  Future<void> _initACDC() async{
    String dbPath = await getLocalPath();
    current_b64_key = await signer.getCurrentPubKey();
    next_b64_key = await signer.getNextPubKey();

    watcher_oobi = "[{\"eid\":\"BKPE5eeJRzkRTMOoRGVd2m18o8fLqM2j9kaxLhV3x8AQ\",\"scheme\":\"http\",\"url\":\"http://192.168.1.30:3236/\"}]";
    var initial_oobis = await api.initialOobis(oobisJson: watcher_oobi);
    await api.initKel(inputAppDir: dbPath, knownOobis: initial_oobis);

    //await api.processStream(stream: stream);
    List<PublicKey> vec1 = [];
    vec1.add(PublicKey(algorithm: KeyType.Ed25519, key: current_b64_key));
    List<PublicKey> vec2 = [];
    vec2.add(PublicKey(algorithm: KeyType.Ed25519, key: next_b64_key));
    List<String> vec3 = [];
    icp_event = await api.incept(publicKeys: vec1, nextPubKeys: vec2, witnesses: vec3, witnessThreshold: 0);
    hex_signature = await signer.sign(icp_event);
    print("Hex signature: $hex_signature");

    //Sign icp event
    signature = Signature(algorithm: SignatureType.Ed25519Sha512, key: hex_signature);

    controller = await api.finalizeInception(event: icp_event, signature: signature);
    kel = await api.getKel(cont: controller);
    print("Current controller kel: $kel");

    //add_watcher_message = await api.addWatcher(controller: controller, watcherId: "BKPE5eeJRzkRTMOoRGVd2m18o8fLqM2j9kaxLhV3x8AQ");
    print("\nController generate end role message to add witness: $add_watcher_message");

    hex_sig = await signer.sign(add_watcher_message);
    signature = Signature(algorithm: SignatureType.Ed25519Sha512, key: hex_sig);
    
    await api.finalizeEvent(identifier: controller, event: add_watcher_message, signature: signature);

    var witness_oobi = "{\"eid\":\"BSuhyBcPZEZLK-fcw5tzHn2N46wRCG_ZOoeKtWTOunRA\",\"scheme\":\"http\",\"url\":\"http://192.168.1.30:3232/\"}";
    var issuer_oobi = "{\"cid\":\"ESiw7FQe25HGh-bJ013qwFF9hAh462vNcTT4rG6UNQtg\",\"role\":\"witness\",\"eid\":\"BSuhyBcPZEZLK-fcw5tzHn2N46wRCG_ZOoeKtWTOunRA\"}";
    print("\nSending issuer oobi to watcher: $issuer_oobi");
    //await api.propagateOobi(controller: controller, oobiJson: witness_oobi);
    //await api.propagateOobi(controller: controller, oobiJson: issuer_oobi);

    print("Querying abour issuer kel...");
    var iss_id = "ESiw7FQe25HGh-bJ013qwFF9hAh462vNcTT4rG6UNQtg";
    await api.query(controller: controller, queryId: iss_id);

    var issuer_kel = await api.getKelByStr(contId: iss_id);
    print("Issuer kel: $issuer_kel");


  }

  List<String> splitMessage(String message){
    return message.split("}-");
  }

  Future<String> localRotate(Controller controller) async{
    //await _generateNewKeys();
    //key_pub_1 = await _getPublicKey1();
    //key_pub_2 = await _getPublicKey2();
    setState(() {});
    List<PublicKey> currentKeys = [];
    List<PublicKey> newNextKeys = [];
    currentKeys.add(PublicKey(algorithm: KeyType.Ed25519, key: current_b64_key));
    newNextKeys.add(PublicKey(algorithm: KeyType.Ed25519, key: next_b64_key));

    var result = await api.rotate(controller: controller, currentKeys: currentKeys, newNextKeys: newNextKeys, witnessToAdd: [], witnessToRemove: [], witnessThreshold: 0);
    return result;
  }

  Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }


}