#!/bin/bash
export APPKID_LOCAL_BUILD=1

ln -sf .build/AppKidDemo/debug/AppKidDemo ./AppKidDemo.executable.link
swift build --build-path .build/AppKidDemo
