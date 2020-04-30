#!/bin/bash
swift build -v --build-path ~/Library/Developer/Xcode/DerivedData/SwiftyFan-`uname`
ln -sf ~/Library/Developer/Xcode/DerivedData/SwiftyFan-`uname`/debug/SwiftyFan ./SwiftyFan.executable.link
