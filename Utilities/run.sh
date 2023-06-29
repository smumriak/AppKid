#!/bin/bash
clear

export APPKID_LOCAL_BUILD=1

swift run AppKidDemo --build-path .build
