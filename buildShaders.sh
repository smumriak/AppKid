#!/bin/bash

arch=`uname`

resourcesPath=./ContentAnimation/Sources/ContentAnimation/Resources
shadersSourceCodePath=$resourcesPath/ShaderSources
shadersBinariesCodePath=$resourcesPath/ShaderBinaries
importHeaderSearchPath=./ContentAnimation/Sources/LayerRenderingData/include

mkdir -p $shadersBinariesCodePath

glslImporterBuildPath=~/Library/Developer/Xcode/DerivedData/SwiftyFan-Linux
contentAnimationShadersBuildPath=~/Library/Developer/Xcode/DerivedData/ContentAnimationShaders

mkdir -p $contentAnimationShadersBuildPath

find $shadersSourceCodePath -name "*.volcano" | while read file; do
    shaderName=`basename $file .volcano`
    outputAfterImport=$contentAnimationShadersBuildPath/$shaderName.volcano.glsl
    swift run --build-path $glslImporterBuildPath glslImporter $file -I $importHeaderSearchPath -o $outputAfterImport || exit 1
    glslc $outputAfterImport -I $shadersSourceCodePath -o $shadersBinariesCodePath/$shaderName.spv|| exit 1
done || exit 1

exit 0
