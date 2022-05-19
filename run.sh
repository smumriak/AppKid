#!/bin/bash
clear

export APPKID_LOCAL_BUILD=1

swift run --build-path ~/Library/Developer/Xcode/DerivedData/SwiftyFan-`uname`
