#!/bin/bash
export APPKID_LOCAL_BUILD=1

ln -sf .build/debug/AppKidDemo ./AppKidDemo.executable.link
swift build --product AppKidDemo --build-path .build
