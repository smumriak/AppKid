//
//  Rectangle.h
//  AppKid
//
//  Created by Serhii Mumriak on 11.06.2021.
//

struct Rect 
{
    vec4 bounds;
};

Rect RectMake(vec4 bounds) 
{
    return Rect(bounds);
}

float RectContains(Rect rect, vec2 point) 
{
    vec2 center = vec2(rect.bounds.x + rect.bounds.z * 0.5, rect.bounds.y + rect.bounds.w * 0.5);
    point -= center;
    
    vec2 externalBounds = rect.bounds.zw * 0.5;
    
    return max(abs(point.x) - externalBounds.x, abs(point.y) - externalBounds.y) <= 0 ? 1 : 0;
}

float RectBorderContains(Rect rect, float borderWidth, vec2 point) 
{
    vec2 center = vec2(rect.bounds.x + rect.bounds.z * 0.5, rect.bounds.y + rect.bounds.w * 0.5);
    point -= center;
    
    vec2 externalBounds = rect.bounds.zw * 0.5;
    vec2 internalBounds = rect.bounds.zw * 0.5 - borderWidth;
    
    return max(abs(point.x) - externalBounds.x, abs(point.y) - externalBounds.y) <= 0
    && max(abs(point.x) - internalBounds.x, abs(point.y) - internalBounds.y) > 0 
    ? 1 : 0;
}

struct RoundedRect 
{
    vec4 bounds;
    float cornerRadius;
};

RoundedRect RoundedRectMake(vec4 bounds, float cornerRadius) 
{
    return RoundedRect(bounds, cornerRadius);
}

float RoundedRectContains(RoundedRect rect, vec2 point)
{
    vec2 center = vec2(rect.bounds.x + rect.bounds.z * 0.5, rect.bounds.y + rect.bounds.w * 0.5);
    point -= center;

    vec2 externalRoundedBounds = rect.bounds.zw * 0.5 - rect.cornerRadius;
    
    return pow(max(abs(point.x) - externalRoundedBounds.x, 0), 2) + pow(max(abs(point.y) - externalRoundedBounds.y, 0), 2) <= pow(rect.cornerRadius, 2) ? 1 : 0;
}

float RoundedRectBorderContains(RoundedRect rect, float borderWidth, vec2 point)
{
    vec2 center = vec2(rect.bounds.x + rect.bounds.z * 0.5, rect.bounds.y + rect.bounds.w * 0.5);
    point -= center;

    vec2 externalRoundedBounds = rect.bounds.zw * 0.5 - rect.cornerRadius;
    vec2 internalRoundedBounds = rect.bounds.zw * 0.5 - rect.cornerRadius - borderWidth;
    
    return pow(max(abs(point.x) - externalRoundedBounds.x, 0), 2) + pow(max(abs(point.y) - externalRoundedBounds.y, 0), 2) <= pow(rect.cornerRadius, 2)
        && pow(max(abs(point.x) - internalRoundedBounds.x, 0), 2) + pow(max(abs(point.y) - internalRoundedBounds.y, 0), 2) > pow(rect.cornerRadius, 2)
        ? 1 : 0;
}
