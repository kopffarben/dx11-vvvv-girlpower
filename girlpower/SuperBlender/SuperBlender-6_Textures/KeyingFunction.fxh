interface iKeying
{
	float4 Keying(Texture2D Tex, SamplerState Samp, float2 uv, float2 R, float Threshold, float Smooth, float AlphaBlur, bool Invert, bool SourceAlpha, bool Premultiply);
};

#include "ColorSpace.fxh"

//#define float4 mmap (float2 x){
//	return tex0.SampleLevel(s0, x, (saturate(AlphaBlur)*log2(max(R.x, R.y))));
//}

float4 keyer (float4 c, float4 map, float key, float Threshold, float Smooth, bool Invert, bool Premultiply, bool SourceAlpha){
	c.a = smoothstep(Threshold-Smooth, Threshold+Smooth+0.0001,key);
	if(Invert)c.a=1-c.a;
	if(Premultiply)c.rgb*=sqrt(1.0/c.a);
	if(SourceAlpha)c.a*=map.a;
	return c;
}

class cLuma : iKeying{
	float4 Keying (Texture2D Tex, SamplerState Samp, float2 uv, float2 R, float Threshold, float Smooth, float AlphaBlur, bool Invert, bool SourceAlpha, bool Premultiply){
		float4 c = Tex.SampleLevel(Samp,uv,0);
		float4 map = Tex.SampleLevel(Samp, uv, (saturate(AlphaBlur)*log2(max(R.x, R.y))));
		return keyer(c,map,dot(map.xyz,float3(0.33,0.59,0.11)), Threshold, Smooth, Invert, Premultiply, SourceAlpha);
	}
};
cLuma Luma;

class cSaturation : iKeying{
	float4 Keying (Texture2D Tex, SamplerState Samp, float2 uv, float2 R, float Threshold, float Smooth, float AlphaBlur, bool Invert, bool SourceAlpha, bool Premultiply){
		float4 c = Tex.SampleLevel(Samp,uv,0);
		float4 map= Tex.SampleLevel(Samp,uv, (saturate(AlphaBlur)*log2(max(R.x, R.y))));
		return keyer(c,map,RGBtoHSV(map.xyz).y, Threshold, Smooth, Invert, Premultiply, SourceAlpha);	
	}
};
cSaturation Saturation;

class cRed : iKeying{
	float4 Keying (Texture2D Tex, SamplerState Samp, float2 uv, float2 R, float Threshold, float Smooth, float AlphaBlur, bool Invert, bool SourceAlpha, bool Premultiply){
		float4 c = Tex.SampleLevel(Samp,uv,0);
		float4 map = Tex.SampleLevel(Samp,uv, (saturate(AlphaBlur)*log2(max(R.x, R.y))));
		return keyer(c,map,c.r, Threshold, Smooth, Invert, Premultiply, SourceAlpha);
		}
};
cRed Red;

class cGreen : iKeying{
	float4 Keying (Texture2D Tex, SamplerState Samp, float2 uv, float2 R, float Threshold, float Smooth, float AlphaBlur, bool Invert, bool SourceAlpha, bool Premultiply){
		float4 c = Tex.SampleLevel(Samp,uv,0);
    	float4 map = Tex.SampleLevel(Samp,uv, (saturate(AlphaBlur)*log2(max(R.x, R.y))));
    	return keyer(c,map,c.g, Threshold, Smooth, Invert, Premultiply, SourceAlpha);
	}
};
cGreen Green;

class cBlue : iKeying{
	float4 Keying (Texture2D Tex, SamplerState Samp, float2 uv, float2 R, float Threshold, float Smooth, float AlphaBlur, bool Invert, bool SourceAlpha, bool Premultiply){
		float4 c = Tex.SampleLevel(Samp,uv,0);
		float4 map = Tex.SampleLevel(Samp,uv, (saturate(AlphaBlur)*log2(max(R.x, R.y))));
		return keyer(c,map,c.b, Threshold, Smooth, Invert, Premultiply, SourceAlpha);
	}
};
cBlue Blue;

class cAlpha : iKeying{
	float4 Keying (Texture2D Tex, SamplerState Samp, float2 uv, float2 R, float Threshold, float Smooth, float AlphaBlur, bool Invert, bool SourceAlpha, bool Premultiply){
		float4 c = Tex.SampleLevel(Samp,uv,0);
    	float4 map = Tex.SampleLevel(Samp,uv, (saturate(AlphaBlur)*log2(max(R.x, R.y))));
    	return keyer(c,map,c.a, Threshold, Smooth, Invert, Premultiply, SourceAlpha);
	}
};
cAlpha Alpha;