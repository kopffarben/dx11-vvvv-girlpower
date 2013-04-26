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

 
float4x4 tW: WORLD;
float4x4 tWV: WORLDVIEW;
float4x4 tV: VIEW;
float4x4 tP: PROJECTION;
float4x4 tVP : VIEWPROJECTION;
float Alpha <float uimin=0.0; float uimax=1.0;> = 1;
 
    
    float3 lDir <string uiname="Light Direction";> = {0, -5, 2}; 
    float4 lAmb  <bool color=true; String uiname="Ambient Color";>  = {0.15, 0.15, 0.15, 1};
    float4 lDiff <bool color=true;String uiname="Diffuse Color";>  = {0.85, 0.85, 0.85, 1};
    float4 lSpec <bool color=true; String uiname="Specular Color";> = {0.35, 0.35, 0.35, 1};
    float lPower <String uiname="Power"; float uimin=3.0;> = 25.0; 

	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform";>;
	float4x4 tColor <string uiname="Color Transform";>;
    
    

    float4 clipPlane = {0.0f, -1.0f, 0.0f, 0.0f };

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
	float4 Diffuse: COLOR0;
    float4 Specular: COLOR1;
	
	float clip : SV_ClipDistance0;

};



// Vertex Shader
////////////////////////////////////////////////////////////////////////////////
PixelInputType ClipPlane_VS(VertexInputType input)
{
    PixelInputType output;
    

      //inverse light direction in view space
    float3 LightDirV = normalize(-mul(float4(lDir,0.0f), tV).xyz);

    //normal in view space
    float3 NormV = normalize(mul(float4(input.normal.xyz,0), tWV).xyz).xyz;

    //view direction = inverse vertexposition in viewspace
    float4 PosV = mul(input.position, tWV);
    float3 ViewDirV = normalize(-PosV.xyz);

    //halfvector
    float3 H = normalize(ViewDirV + LightDirV);

    //compute blinn lighting
    float3 shades = lit(dot(NormV, LightDirV), dot(NormV, H), lPower).xyz;

    float4 diff = lDiff * shades.y;
    diff.a = 1;
    float4 spec = lSpec * shades.z;
    spec.a = 1;
	

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

	output.Diffuse = diff + lAmb;
    output.Specular = spec;
	
     // Set the clipping plane.
    output.clip = dot(mul(input.position,tW),clipPlane);
	
	
	


    return output;
}




// Pixel Shader
////////////////////////////////////////////////////////////////////////////////
float4 ClipPlane_PS(PixelInputType input) : SV_TARGET
{
	
	float4 textureColor;

	float3 directional ;
	
    float4 finalColor;
   
 

	
	// Sample the pixel color from the texture using the sampler at this texture coordinate location.
	textureColor = texture2d.Sample(g_samLinear,input.tex);
	
	textureColor.rgb *= input.Diffuse.xyz + input.Specular.xyz;
	// Calculate the final color.
    finalColor = textureColor ;

    
	
   finalColor.a *= Alpha;
    
   return finalColor;
}








technique10 ClipPlane
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, ClipPlane_VS() ) );
		SetPixelShader( CompileShader( ps_4_0, ClipPlane_PS() ) );
	}
}

