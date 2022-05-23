const qrcode = require('qrcode-terminal');


if(!process.env.HOST_IP_ADDR) {
  throw new Error("HOST_IP_ADDR must be set!")
}

console.log(process.env.HOST_IP_ADDR);
qrcode.generate(`{"eid":"BKPE5eeJRzkRTMOoRGVd2m18o8fLqM2j9kaxLhV3x8AQ","scheme":"http","url":"http://${process.env.HOST_IP_ADDR}:3236/"}`, {small: true});
