//@author: colorsound
//@help: 
//@tags:
//@credits: www.rastertek.com

Texture2D fireTexture <string uiname="fireTexture";>;

Texture2D noiseTexture <string uiname="noiseTexture";>;

Texture2D alphaTexture <string uiname="alphaTexture";>;


SamplerState g_samLinearWrap 
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};

 
SamplerState g_samLinearClamp
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


    float frameTime;
    float3 scrollSpeeds;
    float3 scales;

    float2 distortion1;
    float2 distortion2;
    float2 distortion3;
    float distortionScale;
    float distortionBias;

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
    float2 texCoords1 : TEXCOORD1;
    float2 texCoords2 : TEXCOORD2;
    float2 texCoords3 : TEXCOORD3;


};



// Vertex Shader
////////////////////////////////////////////////////////////////////////////////



PixelInputType Fire_VS(VertexInputType input)
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

    // Compute texture coordinates for first noise texture using the first scale and upward scrolling speed values.
    output.texCoords1 = (input.tex * scales.x);
    output.texCoords1.y = output.texCoords1.y + (frameTime * scrollSpeeds.x);

    // Compute texture coordinates for second noise texture using the second scale and upward scrolling speed values.
    output.texCoords2 = (input.tex * scales.y);
    output.texCoords2.y = output.texCoords2.y + (frameTime * scrollSpeeds.y);

    // Compute texture coordinates for third noise texture using the third scale and upward scrolling speed values.
    output.texCoords3 = (input.tex * scales.z);
    output.texCoords3.y = output.texCoords3.y + (frameTime * scrollSpeeds.z);


    return output;
}




// Pixel Shader
////////////////////////////////////////////////////////////////////////////////
float4 Fire_PS(PixelInputType input) : SV_TARGET
{

    float4 noise1;
    float4 noise2;
    float4 noise3;
    float4 finalNoise;
    float perturb;
    float2 noiseCoords;
    float4 fireColor;
    float4 alphaColor;

	    // Sample the same noise texture using the three different texture coordinates to get three different noise scales.
    noise1 = noiseTexture.Sample(g_samLinearWrap, input.texCoords1);
    noise2 = noiseTexture.Sample(g_samLinearWrap, input.texCoords2);
    noise3 = noiseTexture.Sample(g_samLinearWrap, input.texCoords3);

    // Move the noise from the (0, 1) range to the (-1, +1) range.
    noise1 = (noise1 - 0.5f) * 2.0f;
    noise2 = (noise2 - 0.5f) * 2.0f;
    noise3 = (noise3 - 0.5f) * 2.0f;
	// Sample the pixel color from the texture using the sampler at this texture coordinate location.
	 // Distort the three noise x and y coordinates by the three different distortion x and y values.
    noise1.xy = noise1.xy * distortion1.xy;
    noise2.xy = noise2.xy * distortion2.xy;
    noise3.xy = noise3.xy * distortion3.xy;

    // Combine all three distorted noise results into a single noise result.
    finalNoise = noise1 + noise2 + noise3;
	
	   // Perturb the input texture Y coordinates by the distortion scale and bias values.  
    // The perturbation gets stronger as you move up the texture which creates the flame flickering at the top effect.
    perturb = ((1.0f - input.tex.y) * distortionScale) + distortionBias;
	
	    // Now create the perturbed and distorted texture sampling coordinates that will be used to sample the fire color texture.
    noiseCoords.xy = (finalNoise.xy * perturb) + input.tex.xy;
	
	    // Sample the color from the fire texture using the perturbed and distorted texture sampling coordinates.
    // Use the clamping sample state instead of the wrap sample state to prevent flames wrapping around.
    fireColor = fireTexture.Sample(g_samLinearClamp, noiseCoords.xy);

    // Sample the alpha value from the alpha texture using the perturbed and distorted texture sampling coordinates.
    // This will be used for transparency of the fire.
    // Use the clamping sample state instead of the wrap sample state to prevent flames wrapping around.
    alphaColor = alphaTexture.Sample(g_samLinearClamp, noiseCoords.xy);
  

    
    // Set the alpha blending of the fire to the perturbed and distored alpha texture value.
   fireColor.a = alphaColor;
	
    return fireColor;
}



technique10 Fire
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, Fire_VS() ) );
		SetPixelShader( CompileShader( ps_4_0, Fire_PS() ) );
	}
}