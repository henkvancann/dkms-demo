const qrcode = require('qrcode-terminal');
const inquirer = require("inquirer");

const menu = [
  'Perform introduction (OOBI via QR code)',
  'Issue ACDC',
];
const witness1Eid = "BSuhyBcPZEZLK-fcw5tzHn2N46wRCG_ZOoeKtWTOunRA";
const witness2Eid = "BVcuJOOJF1IE8svqEtrSuyQjGTd2HhfAkt9y2QkUtFJI";
const cid = "EFxHNNoySeNhPSv5TUWxY3QIzy_XT9pKI1YLHv355nuY";

(async function() {
  if(!process.env.HOST_IP_ADDR) {
    throw new Error("HOST_IP_ADDR env var must be set!")
  }

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
      {"eid":"${witness1Eid}","scheme":"http","url":"http://${process.env.HOST_IP_ADDR}:3232/"},
      {"eid":"${witness2Eid}","scheme":"http","url":"http://${process.env.HOST_IP_ADDR}:3233/"}]`, { small: true });
  } else if(answers.op === menu[1]) {

  } else {
    throw new Error('Unsupported operation');
  }
}());
