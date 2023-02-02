#!/bin/bash
clear

export APPKID_LOCAL_BUILD=1

swift run --product AppKidDemo --build-path .build
