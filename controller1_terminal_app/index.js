const qrcode = require('qrcode-terminal');
const inquirer = require("inquirer");
const nacl = require("tweetnacl");

const { Controller, ConfigBuilder, KeyType, PublicKey, SignatureBuilder } = require("keri.js")

console.log(require("keri.js"));
const menu = [
  'Perform introduction (OOBI via QR code)',
  'Issue ACDC',
];
if(!process.env.HOST_IP_ADDR) {
  throw new Error("HOST_IP_ADDR env var must be set!")
}

const witness1Eid = "BSuhyBcPZEZLK-fcw5tzHn2N46wRCG_ZOoeKtWTOunRA";
const witness1OOBI = `{"eid":"${witness1Eid}","scheme":"http","url":"http://${process.env.HOST_IP_ADDR}:3232/"}`;
const witness2Eid = "BVcuJOOJF1IE8svqEtrSuyQjGTd2HhfAkt9y2QkUtFJI";
const cid = "EFxHNNoySeNhPSv5TUWxY3QIzy_XT9pKI1YLHv355nuY";

(async function() {
  let answers = await inquirer.prompt([
    {
      type: 'list',
      name: 'op',
      message: 'What do you want to do?',
      choices: menu,
    },
  ]);

  if(answers.op === menu[0]) {
    qrcode.generate(`[
    {"cid":"${cid}","role":"witness","eid":"${witness1Eid}"},
      ${witness1OOBI},
      {"eid":"${witness2Eid}","scheme":"http","url":"http://${process.env.HOST_IP_ADDR}:3233/"}]`, { small: true });
  } else if(answers.op === menu[1]) {
    let config = new ConfigBuilder().withDbPath("./database")
      .build();
    console.log(config);
    let controller = new Controller(config);
    let currentKeyPair = nacl.sign.keyPair();
    let nextKeyPair = nacl.sign.keyPair();

    console.log(

      [ (new PublicKey(KeyType.Ed25519, Buffer.from(currentKeyPair.publicKey))).getKey() ],
    );
    let inceptionEvent = controller.incept(
      [ (new PublicKey(KeyType.Ed25519, Buffer.from(currentKeyPair.publicKey))).getKey() ],
      [ (new PublicKey(KeyType.Ed25519, Buffer.from(nextKeyPair.publicKey))).getKey() ],
      [witness1OOBI],
      1
    );
    let key_type = KeyType.Ed25519;
  } else {
    throw new Error('Unsupported operation');
  }
}());
