//
//  Rectangle.h
//  ContentAnimation
//
//  Created by Serhii Mumriak on 11.06.2021.
//

float distanceToRoundedRect(vec2 measuredPoint, vec4 bounds, float cornerRadius, vec2 inset) 
{
   vec2 pointOnRectangle = clamp(measuredPoint, bounds.xy + cornerRadius.xx + inset, bounds.xy + bounds.zw - cornerRadius - inset);
   return distance(measuredPoint, pointOnRectangle);
}
