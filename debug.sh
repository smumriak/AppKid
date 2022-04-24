#!/bin/bash
clear

APPKID_LOCAL_BUILD=1

./build.sh
lldb ~/Library/Developer/Xcode/DerivedData/SwiftyFan-Linux/debug/SwiftyFan
