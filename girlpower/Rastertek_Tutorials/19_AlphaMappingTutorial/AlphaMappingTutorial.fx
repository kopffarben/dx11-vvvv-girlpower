//@author: colorsound
//@help: 
//@tags:
//@credits: http://www.rastertek.com

Texture2D texture2d[20] <string uiname="Texture";>;

Texture2D AlphaTexture <string uiname="AlphaTexture";>;

SamplerState g_samLinear 
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

 
    float4x4 tW : WORLD;
	float4x4 tVP : VIEWPROJECTION;

	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
    float GammaBlend = 2.0f;
    
    int indexIn1 = 0; 
    uint indexIn2 = 1;//why uints do not show outside ? 

	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform";>;
	float4x4 tColor <string uiname="Color Transform";>;
    
 

	


struct VertexInputType //VS_IN
{
    float4 position : POSITION;
    float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
	
};

struct PixelInputType // vs2ps
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
};



// Vertex Shader
////////////////////////////////////////////////////////////////////////////////
PixelInputType AlphaMapping_VS(VertexInputType input)
{
    PixelInputType output;
    

	// Change the position vector to be 4 units for proper matrix calculations.
  // input.position.w = 1.0f;

	// Calculate the position of the vertex against the world, view, and projection matrices.
    output.position = mul(input.position,tW);
    output.position = mul(output.position, tVP);
   
    
	// Store the texture coordinates for the pixel shader.
	output.tex = input.tex;
    
	// Calculate the normal vector against the world matrix only.
    output.normal = mul(input.normal, (float3x3)tW);
	
    // Normalize the normal vector.
    output.normal = normalize(output.normal);

	
	
	
    return output;
}




// Pixel Shader
////////////////////////////////////////////////////////////////////////////////
float4 AlphaMapping_PS(PixelInputType input) : SV_TARGET
{
	
    float4 color1 ;
    float4 color2;
    float4 blendColor;
	float4 alphaValue;
  

	
	
	// Sample the pixel color from the texture using the sampler at this texture coordinate location.
	color1 = texture2d[0].Sample(g_samLinear,input.tex);
	color2 = texture2d[1].Sample(g_samLinear,input.tex);
    alphaValue = AlphaTexture.Sample(g_samLinear,input.tex);
	
	
	blendColor = (alphaValue * color1) + ((1.0 - alphaValue) * color2);
	// Saturate the final color value.
    blendColor = saturate(blendColor);
	
    blendColor = blendColor * cAmb;
	
    blendColor.a *= Alpha;
    
    return blendColor;
}








technique10 AlphaMapping
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, AlphaMapping_VS() ) );
		SetPixelShader( CompileShader( ps_4_0, AlphaMapping_PS() ) );
	}
}


