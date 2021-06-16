#!/bin/bash

arch=`uname`

resourcesPath=./AppKid/Sources/AppKid/Resources
shadersSourceCodePath=$resourcesPath/ShaderSources
shadersBinariesCodePath=$resourcesPath/ShaderBinaries
importHeaderSearchPath=./AppKid/Sources/LayerRenderingData/include

glslImporterBuildPath=~/Library/Developer/Xcode/DerivedData/glslImporter-$arch
appKidShadersBuildPath=~/Library/Developer/Xcode/DerivedData/AppKidShaders-$arch

mkdir -p $appKidShadersBuildPath

find $shadersSourceCodePath -name "*.volcano" | while read file; do
    shaderName=`basename $file .volcano`
    outputAfterImport=$appKidShadersBuildPath/$shaderName.volcano.glsl
    swift run --build-path $glslImporterBuildPath glslImporter $file -I $importHeaderSearchPath -o $outputAfterImport || exit 1
    glslc $outputAfterImport -I $shadersSourceCodePath -o $shadersBinariesCodePath/$shaderName.spv|| exit 1
done || exit 1

exit 0
