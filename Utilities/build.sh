#!/bin/bash
export APPKID_LOCAL_BUILD=1

swift build --product AppKidDemo --build-path .build
