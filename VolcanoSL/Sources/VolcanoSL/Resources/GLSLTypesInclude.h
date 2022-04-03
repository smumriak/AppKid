//
//  GLSLTypesInclude.h
//  VolcanoSL
//
//  Created by Serhii Mumriak on 14.06.2021.
//

#ifndef __GLSL_TYPES_INCLUDE_H__
#define __GLSL_TYPES_INCLUDE_H__

#ifdef __GLSL_IMPORTER__

#define bvec2s bvec2
#define bvec3s bvec3
#define bvec4s bvec4

#define ivec2s ivec2
#define ivec3s ivec3
#define ivec4s ivec4

#define uvec2s uvec2
#define uvec3s uvec3
#define uvec4s uvec4

#define vec2s vec2
#define vec3s vec3
#define vec4s vec4

#define dvec2s dvec2
#define dvec3s dvec3
#define dvec4s dvec4

#define mat2s mat2
#define mat3s mat3
#define mat4s mat4

#define uint unsigned int;

typedef bool bvec2 __attribute__((ext_vector_type(2)));
typedef bool bvec3 __attribute__((ext_vector_type(3)));
typedef bool bvec4 __attribute__((ext_vector_type(4)));

typedef int ivec2 __attribute__((ext_vector_type(2)));
typedef int ivec3 __attribute__((ext_vector_type(3)));
typedef int ivec4 __attribute__((ext_vector_type(4)));

typedef uint uvec2 __attribute__((ext_vector_type(2)));
typedef uint uvec3 __attribute__((ext_vector_type(3)));
typedef uint uvec4 __attribute__((ext_vector_type(4)));

typedef float vec2 __attribute__((ext_vector_type(2)));
typedef float vec3 __attribute__((ext_vector_type(3)));
typedef float vec4 __attribute__((ext_vector_type(4)));

typedef double dvec2 __attribute__((ext_vector_type(2)));
typedef double dvec3 __attribute__((ext_vector_type(3)));
typedef double dvec4 __attribute__((ext_vector_type(4)));

typedef vec4 versor;
typedef vec3 mat3[3];
typedef vec2 mat2[2];
typedef vec4 mat4[4];

// typedef float mat4 __attribute__((matrix_type(4, 4)));

#endif

#endif