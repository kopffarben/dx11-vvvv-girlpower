//@author: colorsound
//@help: 
//@tags:
//@credits: www.rastertek.com

Texture2D texture2d <string uiname="Texture";>;



SamplerState g_samLinear 
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Border;
    AddressV = Border;
	BorderColor = float4(1.0f,1.0f,1.0f,0.0f);
};

 
float4x4 tW: WORLD;
float4x4 tWV: WORLDVIEW;
float4x4 tV: VIEW;
float4x4 tP: PROJECTION;
float4x4 tVP : VIEWPROJECTION;
float Alpha <float uimin=0.0; float uimax=1.0;> = 1;
 
    
   

	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
    float4 cBord <bool color=true;String uiname="BorderColor";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform";>;
	float4x4 tColor <string uiname="Color Transform";>;
    
    float textureTranslation;

   

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
PixelInputType Texturetranslation_VS(VertexInputType input)
{
    PixelInputType output;
    

   
	

 // Change the position vector to be 4 units for proper matrix calculations.
    input.position.w = 1.0f;


	// Calculate the position of the vertex against the world, view, and projection matrices.
    output.position = mul(input.position,tW);
    output.position = mul(output.position,tVP);
   
    
	// Store the texture coordinates for the pixel shader.
	output.tex = mul(input.tex,(float2x2)tTex);
  
	// Calculate the normal vector against the world matrix only.
    output.normal = mul(input.normal,(float3x3)tW);
	
    // Normalize the normal vector.
    output.normal = normalize(output.normal);

	
	
	
	


    return output;
}




// Pixel Shader
////////////////////////////////////////////////////////////////////////////////
float4 Texturetranslation_PS(PixelInputType input) : SV_TARGET
{
	
	float4 textureColor;

    float4 finalColor;
   
	    // Translate the position where we sample the pixel from.
    input.tex.x += textureTranslation;
	
	// Sample the pixel color from the texture using the sampler at this texture coordinate location.
	textureColor = texture2d.Sample(g_samLinear,input.tex);
	

    finalColor = textureColor *cAmb;



	
   finalColor.a *= Alpha;
    
   return finalColor;
}








technique10 Texturetranslation
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, Texturetranslation_VS() ) );
		SetPixelShader( CompileShader( ps_4_0, Texturetranslation_PS() ) );
	}
}

