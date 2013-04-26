//@author: colorsound
//@help: 
//@tags:
//@credits: www.rastertek.com

Texture2D texture2d <string uiname="Texture";>;

Texture2D normalTexture <string uiname="normalTexture";>;

Texture2D refractionTexture <string uiname="refractionTexture";>;



SamplerState g_samLinear 
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

 
    float4x4 tW : WORLD;
     float4x4 tP : PROJECTION;
	float4x4 tVP : VIEWPROJECTION;
    float4x4 tWVP : WORLDVIEWPROJECTION;
    float4x4 tV : VIEW;
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
 
    


	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform";>;
	float4x4 tColor <string uiname="Color Transform";>;


    float refractionScale;
    float3 padding;




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
    float4 refractionPosition : TEXCOORD1;


};



// Vertex Shader
////////////////////////////////////////////////////////////////////////////////



PixelInputType GlassandIce_VS(VertexInputType input)
{
    PixelInputType output;
    

	
	
	float4 cameraPosition;
	matrix viewProjectWorld;

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

        // Create the view projection world matrix for refraction.
    viewProjectWorld = mul(tV, tP);
    viewProjectWorld = mul(tW, viewProjectWorld);

	  // Calculate the input position against the viewProjectWorld matrix.
    output.refractionPosition = mul(input.position,viewProjectWorld);

    return output;
}




// Pixel Shader
////////////////////////////////////////////////////////////////////////////////
float4 GlassandIce_PS(PixelInputType input) : SV_TARGET
{


 
    float4 finalColor;

    
	float2 refractTexCoord;
    float4 normalMap;
    float3 normal;
    float4 refractionColor;
    float4 textureColor;
    float4 color;

	
	    // Calculate the projected refraction texture coordinates.
    refractTexCoord.x = input.refractionPosition.x / input.refractionPosition.w / 2.0f + 0.5f;
    refractTexCoord.y = -input.refractionPosition.y / input.refractionPosition.w / 2.0f + 0.5f;
	
	// Sample the normal from the normal map texture.
    normalMap = normalTexture.Sample(g_samLinear, input.tex);
	// Sample the pixel color from the texture using the sampler at this texture coordinate location.
	    // Expand the range of the normal from (0,1) to (-1,+1).
    normal = (normalMap.xyz * 2.0f) - 1.0f;
	
	    // Re-position the texture coordinate sampling position by the normal map value to simulate light distortion through glass.
    refractTexCoord = refractTexCoord + (normal.xy * refractionScale);
	
	    // Sample the texture pixel from the refraction texture using the perturbed texture coordinates.
    refractionColor = refractionTexture.Sample(g_samLinear, refractTexCoord);
	
	textureColor = texture2d.Sample(g_samLinear,input.tex);
	
	// Calculate the final color using the fog effect equation.
    finalColor =  textureColor ;

    
    // Evenly combine the glass color and refraction value for the final color.
    color = lerp(refractionColor, textureColor, 0.5f);

    return color;
}



technique10 GlassandIce
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, GlassandIce_VS() ) );
		SetPixelShader( CompileShader( ps_4_0, GlassandIce_PS() ) );
	}
}