## Introduction

This is a demonstration of DKMS infrastructure that presents its usage in practice. The demo consists of 2 controllers, where `controller1` is an issuer and `controller2` is a holder of digitally signed cryptograhpic material that attestates claims about the subject. Controllers communicate indirectly through the OOBI's and infrastructure.

## Structure of this repo

- `controller1_terminal_app` – A NodeJS based app that demonstrates NodeJS bindings and serves as data issuer
- `controller2_mobile_app` – A Flutter based app that demonstrates usage of Dart bindings and serves as data holder;
- `infrastructure` – A simple network of 3 Witnesses and 1 Watcher;

## Usage

To run it:
1. Run the `infrastructure`;
1. Get and install `controller2` mobile app;
2. Using `controller2` mobile app scan the QR code printed along with the other output from `infrastructure`;
3. Go to `controller1_terminal_app`, run the app, from the main menu select `Perform introduction (OOBI via QR code)` and scan it from the `controller2` mobile app;
4. having running `controller1` app, now select from the menu "Issue ACDC" and follow the process. At the end ACDC QR code will be generated. Scan it from the `controller2` mobile app.

The complexity of the use case is well described here: https://hackmd.io/@bYQK_qO_RLa70okz8n7TQg/rkbCezoBc#Demo-step-by-step-from-the-DKMS-perspective
