//
//  LayerRenderDescriptor.h
//  AppKid
//
//  Created by Serhii Mumriak on 13.06.2021.
//

#ifndef __GLSL_IMPORTER__
#include <cglm/struct.h>
#endif

// align each field by 16
struct LayerRenderDescriptor {
  mat4s transform;         // +64 bytes
  mat4s contentsTransform; // +64 bytes
  vec2s position;          // +8 bytes
  vec2s anchorPoint;       // +8 bytes
  vec4s bounds;            // +16 bytes
  vec4s backgroundColor;   // +16 bytes
  vec4s borderColor;       // +16 bytes
  float borderWidth;       // +4 bytes
  float cornerRadius;      // +4 bytes
  int masksToBounds;       // +4 byte
  vec2s shadowOffset;      // +8 bytes
  vec4s shadowColor;       // +16 bytes
  float shadowRadius;      // +4 bytes
  float shadowOpacity;     // +4 bytes

  // Totoal before padding: 232 bytes

  vec2s padding0; // + 8 bytes
  vec4s padding1; // +16 bytes
                       // Total: 256 bytes
};
