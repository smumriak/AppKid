#!/bin/bash
clear

export APPKID_LOCAL_BUILD=1

./build.sh
lldb .build/debug/AppKidDemo
