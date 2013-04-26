//@author: colorsound
//@help: 
//@tags:
//@credits: www.rastertek.com

Texture2D texture2d <string uiname="Texture";>;



SamplerState g_samLinear 
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

 
    float4x4 tW : WORLD;
	float4x4 tVP : VIEWPROJECTION;
    float4x4 tV : VIEW;
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
 
    


	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform";>;
	float4x4 tColor <string uiname="Color Transform";>;
    float4 fogcolor <bool color=true;String uiname="FogColor";> = { 0.5f, 0.5f, 0.5f,1.0f };
    
    float3 CameraPosition;
	float fogStart;
    float fogEnd;
    float FogDensity;
    float ExponetialFactor = 2.71828 ;    

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
	float fogFactor : FOG;

};



// Vertex Shader
////////////////////////////////////////////////////////////////////////////////
PixelInputType FogLinear_VS(VertexInputType input)
{
    PixelInputType output;
    

	float4 cameraPosition;
	

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

	cameraPosition = mul(input.position, tW);
    cameraPosition = mul(cameraPosition, tV);

    // Calculate linear fog.    
   output.fogFactor = saturate((fogEnd - cameraPosition.z) / (fogEnd - fogStart));
	
	
	


    return output;
}


PixelInputType Fog_Exponential_VS(VertexInputType input)
{
    PixelInputType output;
    

	float4 cameraPosition;
	

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

	cameraPosition = mul(input.position, tW);
    cameraPosition = mul(cameraPosition, tV);


	//Exponential Fog 
	output.fogFactor=  pow((1.0 / abs(ExponetialFactor)),(cameraPosition.z * FogDensity));


    return output;
}



PixelInputType Fog_Exponential2_VS(VertexInputType input)
{
    PixelInputType output;
    

	float4 cameraPosition;
	

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

	cameraPosition = mul(input.position, tW);
    cameraPosition = mul(cameraPosition, tV);


	//Exponential Fog 2
	output.fogFactor=  pow((1.0 /abs(ExponetialFactor)),(((cameraPosition.z * FogDensity) * (cameraPosition.z * FogDensity))));
 

    return output;
}

// Pixel Shader
////////////////////////////////////////////////////////////////////////////////
float4 FogPS(PixelInputType input) : SV_TARGET
{

    float4 textureColor;
    float4 fogColor;
    float4 finalColor;

    fogColor =  fogcolor ;

	
	// Sample the pixel color from the texture using the sampler at this texture coordinate location.
	textureColor = texture2d.Sample(g_samLinear,input.tex);
	
	// Calculate the final color using the fog effect equation.
    finalColor = input.fogFactor * textureColor + (1.0 - input.fogFactor) * fogColor;

    
	
   finalColor.a *= Alpha;
    
   return finalColor;
}








technique10 Fog_Linear
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, FogLinear_VS() ) );
		SetPixelShader( CompileShader( ps_4_0, FogPS() ) );
	}
}

technique10 Fog_Exponential
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, Fog_Exponential_VS() ) );
		SetPixelShader( CompileShader( ps_4_0, FogPS() ) );
	}
}

technique10 Fog_Exponential2
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, Fog_Exponential2_VS() ) );
		SetPixelShader( CompileShader( ps_4_0, FogPS() ) );
	}
}