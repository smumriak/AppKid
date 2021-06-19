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

    vec2 externalRoundedBoundsSize = rect.bounds.zw * 0.5 - rect.cornerRadius;
    
    return pow(max(abs(point.x) - externalRoundedBoundsSize.x, 0), 2) + pow(max(abs(point.y) - externalRoundedBoundsSize.y, 0), 2) <= pow(rect.cornerRadius, 2) ? 1 : 0;
}

float RoundedRectBorderContains(RoundedRect rect, float borderWidth, vec2 point)
{
    vec2 center = vec2(rect.bounds.x + rect.bounds.z * 0.5, rect.bounds.y + rect.bounds.w * 0.5);
    point -= center;

    float externalRadius = rect.cornerRadius;
    float internalRadius = max(externalRadius - borderWidth, 0.0);

    vec2 externalSize = rect.bounds.zw * 0.5 - vec2(externalRadius);
    vec2 internalSize = (rect.bounds.zw - vec2(2.0 * borderWidth)) * 0.5 - vec2(internalRadius);

    bool fitsOutside = pow(max(abs(point.x) - externalSize.x, 0), 2) + pow(max(abs(point.y) - externalSize.y, 0), 2) <= pow(externalRadius, 2);
    bool fitsInside = pow(max(abs(point.x) - internalSize.x, 0), 2) + pow(max(abs(point.y) - internalSize.y, 0), 2) > pow(internalRadius, 2);

    return fitsOutside && fitsInside ? 1.0 : 0.0;
}
