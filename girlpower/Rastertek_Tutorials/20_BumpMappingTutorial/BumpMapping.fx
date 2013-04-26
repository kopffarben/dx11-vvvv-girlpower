//@author: colorsound
//@help: 
//@tags:
//@credits: http://www.rastertek.com

Texture2D texture2d[20] <string uiname="Texture";>;

Texture2D BumpTexture <string uiname="BumpTexture";>;

SamplerState g_samLinear 
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

 
    float4x4 tW : WORLD;
	float4x4 tVP : VIEWPROJECTION;

	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
 
   // float3 tangent1 ={1.0f,0.0f,0.0f};
    //float3 binorm ={0.0f,1.0f,0.0f};


	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform";>;
	float4x4 tColor <string uiname="Color Transform";>;
    
    float4 diffuseColorIn<bool color=true;String uiname="diffuseColor";> = { 1.0f,1.0f,1.0f,1.0f };
    float3 lightDirection;

	


struct VertexInputType //VS_IN
{
    float4 position : POSITION;
    float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
	//float3 tangent1 : TANGENT;
   // float3 binormal : BINORMAL;
};

struct PixelInputType // vs2ps
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
	//float3 tangent1 : TANGENT;
   // float3 binormal : BINORMAL;
};



// Vertex Shader
////////////////////////////////////////////////////////////////////////////////
PixelInputType LightVertexShader(VertexInputType input)
{
    PixelInputType output;
    //float4x4 w = transpose(tW);
	//float4x4 vp = transpose(tVP);
 // Change the position vector to be 4 units for proper matrix calculations.
   // input.position.w = 1.0f;


	// Calculate the position of the vertex against the world, view, and projection matrices.
    output.position = mul(input.position,tW);
    output.position = mul(output.position,tVP);
   
    
	// Store the texture coordinates for the pixel shader.
	output.tex = input.tex;
    
	// Calculate the normal vector against the world matrix only.
    output.normal = mul(input.normal,(float3x3)tW);
	
    // Normalize the normal vector.
    output.normal = normalize(output.normal);

	// Calculate the tangent vector against the world matrix only and then normalize the final value.
   //output.tangent1 = mul(input.tangent1, (float3x3)tW);
   //output.tangent1 = normalize(output.tangent1);
	
	// Calculate the binormal vector against the world matrix only and then normalize the final value.
 // output.binormal = mul(input.binormal, (float3x3)tW);
  // output.binormal = normalize(output.binormal);
	
    return output;
}




// Pixel Shader
////////////////////////////////////////////////////////////////////////////////
float4 MultiTexturePS(PixelInputType input) : SV_TARGET
{
	
    float4 color1 ;    
	float4 alphaValue;  
	float4 textureColor;
    float4 bumpMap;
    float3 bumpNormal;
    float3 lightDir;
    float lightIntensity;
    float4 color;
    float4 diffuseColor ;
	lightDir = lightDirection;
	
	float3 tangent ={1.0f,0.0f,0.0f};
    float3 binormal ={0.0f,1.0f,0.0f};

	diffuseColor = diffuseColorIn;
	
	// Sample the pixel color from the texture using the sampler at this texture coordinate location.
	color1 = texture2d[0].Sample(g_samLinear,input.tex);
	bumpMap = BumpTexture.Sample(g_samLinear,input.tex);
    
	// Expand the range of the normal value from (0, +1) to (-1, +1).
    bumpMap = (bumpMap * 2.0f) - 1.0f;
	
	
	 // Calculate the normal from the data in the bump map.
   bumpNormal = input.normal + bumpMap.x * tangent + bumpMap.y * binormal;
	
	
	// Normalize the resulting bump normal.
   bumpNormal = normalize(bumpNormal);
	
	 // Invert the light direction for calculations.
    lightDir = -lightDirection;
	
	// Calculate the amount of light on this pixel based on the bump map normal value.
    lightIntensity = saturate(dot(bumpNormal,lightDir));
	
	// Determine the final diffuse color based on the diffuse color and the amount of light intensity.
   color = saturate(diffuseColor * lightIntensity);
	
	// Combine the final bump light color with the texture color.
    color = color * color1;
    color = color * cAmb;
	
   color.a *= Alpha;
    
    return color;
}








technique10 TextureAmbient
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, LightVertexShader() ) );
		SetPixelShader( CompileShader( ps_4_0, MultiTexturePS() ) );
	}
}


