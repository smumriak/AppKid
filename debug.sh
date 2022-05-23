#!/bin/bash
clear

export APPKID_LOCAL_BUILD=1

./build.sh
lldb ~/Library/Developer/Xcode/DerivedData/AppKidDemo-Linux/debug/AppKidDemo
