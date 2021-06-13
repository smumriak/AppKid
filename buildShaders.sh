#!/bin/bash

resourcesPath="./AppKid/Sources/AppKid/Resources"
shadersSourceCodePath="$resourcesPath/ShaderSources"
shadersBinariesCodePath="$resourcesPath/ShaderBinaries"

find $shadersSourceCodePath -name "*.volcano" | while read file; do
    shaderName=`basename $file .volcano`
    glslc $file -o "$shadersBinariesCodePath/$shaderName.spv" || exit 1
done || exit 1
