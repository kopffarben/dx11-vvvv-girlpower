//@author: colorsound
//@help: 
//@tags:
//@credits: www.rastertek.com



/////////////
// DEFINES //
/////////////
#define NUM_LIGHTS 4

float3 lightPosition[NUM_LIGHTS];

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
 
    

    float4 diffuseColor[NUM_LIGHTS] <bool color=true;String uiname="diffuseColor";> ;
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
    float3 lightPos1 : TEXCOORD1;
    float3 lightPos2 : TEXCOORD2;
    float3 lightPos3 : TEXCOORD3;
    float3 lightPos4 : TEXCOORD4;

};



// Vertex Shader
////////////////////////////////////////////////////////////////////////////////



PixelInputType MultiplePointLights_VS(VertexInputType input)
{
    PixelInputType output;
    

	float4 cameraPosition;
	float4 worldPosition;

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

     // Calculate the position of the vertex in the world.
    worldPosition = mul(input.position, tW);
   
	 // Determine the light positions based on the position of the lights and the position of the vertex in the world.
    output.lightPos1.xyz = lightPosition[0].xyz - worldPosition.xyz;
    output.lightPos2.xyz = lightPosition[1].xyz - worldPosition.xyz;
    output.lightPos3.xyz = lightPosition[2].xyz - worldPosition.xyz;
    output.lightPos4.xyz = lightPosition[3].xyz - worldPosition.xyz;

    // Normalize the light position vectors.
    output.lightPos1 = normalize(output.lightPos1);
    output.lightPos2 = normalize(output.lightPos2);
    output.lightPos3 = normalize(output.lightPos3);
    output.lightPos4 = normalize(output.lightPos4);


    return output;
}




// Pixel Shader
////////////////////////////////////////////////////////////////////////////////
float4 MultiplePointLights_PS(PixelInputType input) : SV_TARGET
{

    float4 textureColor;
 
   
	float lightIntensity1, lightIntensity2, lightIntensity3, lightIntensity4;
    float4 color, color1, color2, color3, color4;
	

    // Calculate the different amounts of light on this pixel based on the positions of the lights.
    lightIntensity1 = saturate(dot(input.normal, input.lightPos1));
    lightIntensity2 = saturate(dot(input.normal, input.lightPos2));
    lightIntensity3 = saturate(dot(input.normal, input.lightPos3));
    lightIntensity4 = saturate(dot(input.normal, input.lightPos4));
	
	// Determine the diffuse color amount of each of the four lights.
    color1 = diffuseColor[0] * lightIntensity1;
    color2 = diffuseColor[1] * lightIntensity2;
    color3 = diffuseColor[2] * lightIntensity3;
    color4 = diffuseColor[3] * lightIntensity4;
	
	
	
	// Sample the pixel color from the texture using the sampler at this texture coordinate location.
	textureColor = texture2d.Sample(g_samLinear,input.tex);
	
	// Multiply the texture pixel by the combination of all four light colors to get the final result.
    color = saturate(color1 + color2 + color3 + color4) * textureColor;
    
   color = color * cAmb;
   color.a *= Alpha;
    
   return color;
}



technique10 MultiplePointLights
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, MultiplePointLights_VS() ) );
		SetPixelShader( CompileShader( ps_4_0, MultiplePointLights_PS() ) );
	}
}