//
//  CCore_umbrella.h
//  SwiftyFan
//
//  Created by Serhii Mumriak on 21.04.2020.
//

#ifndef CCore_umbrella_h
#define CCore_umbrella_h 1

#define __CK_OPTIONS_ATTRIBUTES __attribute__((flag_enum,enum_extensibility(open)))
#define AK_OPTIONS(_type, _name) enum __CK_OPTIONS_ATTRIBUTES _name : _type _name; enum _name : _type

#define __CK_ENUM_ATTRIBUTES __attribute__((enum_extensibility(open)))
#define AK_ENUM(_type, _name) enum __CK_ENUM_ATTRIBUTES _name : _type _name; enum _name : _type

#define __CF_CLOSED_ENUM_ATTRIBUTES __attribute__((enum_extensibility(closed)))
#define AK_CLOSED_ENUM(_type, _name) enum __CF_CLOSED_ENUM_ATTRIBUTES _name : _type _name; enum _name : _type

#endif
