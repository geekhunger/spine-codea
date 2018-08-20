# About

This project is a Spine 2D runtime integration for Codea. Spine is a 2D (bone) animation tool. Codea is an iOS game engine.


# How-To?

All the information was posted on the Codea-Forum: https://codea.io/talk/discussion/8174/spine2d-support-for-codea

The simple, manual steps would be:

1. Open your Dropbox and create a new folder inside, call it `/spine-lua` and clone the official Spine repo in there https://github.com/EsotericSoftware/spine-runtimes.
2. Create another folder and call it `/spine-data` and drop some examples into it (e.g. *raptor.json, raptor.atlas, raptor.png* from https://github.com/EsotericSoftware/spine-runtimes/tree/3.6/examples/raptor/export).
3. Switch to your iOS device and open Codea. Connect Codea to your Dropbox account (if not done yet).
4. Create a new project and call it whatever you want. Then clone all three tabs/files from this repo into your project https://github.com/jack0088/spine-codea/tree/master/tabs. (Yes, you must ignore the Info.plist file, if you fallow this guide.)
