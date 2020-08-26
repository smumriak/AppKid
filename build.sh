#!/bin/bash
ln -sf ~/Library/Developer/Xcode/DerivedData/SwiftyFan-`uname`/debug/SwiftyFan ./SwiftyFan.executable.link
swift build --build-path ~/Library/Developer/Xcode/DerivedData/SwiftyFan-`uname`
