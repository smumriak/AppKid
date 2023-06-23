//
//  CCore.h
//  CCore
//
//  Created by Serhii Mumriak on 21.04.2020.
//

#ifndef CCore_h
#define CCore_h 1

#define __CK_OPTIONS_ATTRIBUTES __attribute__((flag_enum,enum_extensibility(open)))
#define AK_OPTIONS(_type, _name) enum __CK_OPTIONS_ATTRIBUTES _name : _type _name; enum _name : _type

#if (__cplusplus)
#define AK_EXISTING_OPTIONS_IMPLICIT(...) ;
#define AK_EXISTING_OPTIONS_TYPED(...) ;
#else
#define AK_EXISTING_OPTIONS_IMPLICIT(_name) enum __CK_OPTIONS_ATTRIBUTES _name;
#define AK_EXISTING_OPTIONS_TYPED(_type, _name) enum __CK_OPTIONS_ATTRIBUTES _name : _type _name;
#endif
#define AK_GET_EXISTING_OPTIONS_MACRO(_1,_2,NAME,...) NAME
#define AK_EXISTING_OPTIONS(...) AK_GET_EXISTING_OPTIONS_MACRO(__VA_ARGS__, AK_EXISTING_OPTIONS_TYPED, AK_EXISTING_OPTIONS_IMPLICIT)(__VA_ARGS__)

#define __CK_ENUM_ATTRIBUTES __attribute__((enum_extensibility(open)))
#define AK_ENUM(_type, _name) enum __CK_ENUM_ATTRIBUTES _name : _type _name; enum _name : _type

#if (__cplusplus)
#define AK_EXISTING_ENUM_IMPLICIT(...) ;
#define AK_EXISTING_ENUM_TYPED(...) ;
#else
#define AK_EXISTING_ENUM_IMPLICIT(_name) enum __CK_ENUM_ATTRIBUTES _name;
#define AK_EXISTING_ENUM_TYPED(_type, _name) enum __CK_ENUM_ATTRIBUTES _name : _type _name;
#endif
#define AK_GET_EXISTING_ENUM_MACRO(_1,_2,NAME,...) NAME
#define AK_EXISTING_ENUM(...) AK_GET_EXISTING_ENUM_MACRO(__VA_ARGS__, AK_EXISTING_ENUM_TYPED, AK_EXISTING_ENUM_IMPLICIT)(__VA_ARGS__)

#define __CF_CLOSED_ENUM_ATTRIBUTES __attribute__((enum_extensibility(closed)))
#define AK_CLOSED_ENUM(_type, _name) enum __CF_CLOSED_ENUM_ATTRIBUTES _name : _type _name; enum _name : _type

#if (__cplusplus)
#define AK_EXISTING_CLOSED_ENUM_IMPLICIT(...) ;
#define AK_EXISTING_CLOSED_ENUM_TYPED(...) ;
#else
#define AK_EXISTING_CLOSED_ENUM_IMPLICIT(_name) enum __CF_CLOSED_ENUM_ATTRIBUTES _name;
#define AK_EXISTING_CLOSED_ENUM_TYPED(_type, _name) enum __CF_CLOSED_ENUM_ATTRIBUTES _name : _type _name;
#endif
#define AK_GET_EXISTING_CLOSED_ENUM_MACRO(_1,_2,NAME,...) NAME
#define AK_EXISTING_CLOSED_ENUM(...) AK_GET_EXISTING_CLOSED_ENUM_MACRO(__VA_ARGS__, AK_EXISTING_CLOSED_ENUM_TYPED, AK_EXISTING_CLOSED_ENUM_IMPLICIT)(__VA_ARGS__)

#if defined(__linux__) && !defined(_GNU_SOURCE)
#define _GNU_SOURCE
#endif

#endif
