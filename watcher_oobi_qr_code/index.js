const qrcode = require('qrcode-terminal');


if(!process.env.WATCHER_HOST) {
  throw new Error("WATCHER_HOST must be set!")
}

console.log(`Watcher host: ${process.env.WATCHER_HOST}`);
qrcode.generate(`{"eid":"BKPE5eeJRzkRTMOoRGVd2m18o8fLqM2j9kaxLhV3x8AQ","scheme":"http","url":"http://${process.env.WATCHER_HOST}:3231/"}`, {small: true});
