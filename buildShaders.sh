#!/bin/bash

resourcesPath="./AppKid/Sources/AppKid/Resources"
shadersSourceCodePath="$resourcesPath/ShaderSources"
shadersBinariesCodePath="$resourcesPath/ShaderBinaries"
shaderHeaderSearchPath="./AppKid/Sources/LayerRenderingData/include"

find $shadersSourceCodePath -name "*.volcano" | while read file; do
    shaderName=`basename $file .volcano`
    swift run --build-path ~/Library/Developer/Xcode/DerivedData/glslImporter-Linux glslImporter $file -I "$shaderHeaderSearchPath" || exit 1
    glslc "$file.glsl" -o "$shadersBinariesCodePath/$shaderName.spv" || exit 1
done || exit 1

rm -rf $shadersSourceCodePath/*.volcano.glsl

exit 0
