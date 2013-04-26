//@author: colorsound
//@help: 
//@tags:
//@credits: www.rastertek.com

Texture2D texture2d <string uiname="Texture";>;


Texture2D depthMapTexture <string uiname="depthMapTexture";>;
Texture2D depthMapTexture2 <string uiname="depthMapTexture2";>;
SamplerState SamClamp 
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

SamplerState SamWrap 
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};
 
    float4x4 tW : WORLD;
	float4x4 tVP : VIEWPROJECTION;
    float4x4 tV : VIEW;
	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
 
    

	float4 ambientColor <bool color=true;String uiname="ambientColor";> = { 0.15f, 0.15f, 0.15f, 1.0f };
    float4 diffuseColor <bool color=true;String uiname="diffuseColor";> = { 1.0f, 1.0f, 1.0f, 1.0f };
    float4 diffuseColor2 <bool color=true;String uiname="diffuseColor2";> = { 1.0f, 1.0f, 1.0f, 1.0f };
	float4x4 tTex <string uiname="Texture Transform";>;
	float4x4 tColor <string uiname="Color Transform";>;


    matrix lightViewMatrix;
    matrix lightProjectionMatrix;
    matrix lightViewMatrix2;
    matrix lightProjectionMatrix2;

    float3 lightPosition;
 
    float3 lightPosition2;

     float bias = 0.001f;

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
    float4 lightViewPosition : TEXCOORD1;
    float3 lightPos : TEXCOORD2;
    float4 lightViewPosition2 : TEXCOORD3;
    float3 lightPos2 : TEXCOORD4;

};



// Vertex Shader
////////////////////////////////////////////////////////////////////////////////



PixelInputType MultiShadow_VS(VertexInputType input)
{
    PixelInputType output;
    

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

        // Calculate the position of the vertice as viewed by the light source.
    output.lightViewPosition = mul(input.position,tW);
    output.lightViewPosition = mul(output.lightViewPosition, lightViewMatrix);
    output.lightViewPosition = mul(output.lightViewPosition, lightProjectionMatrix);
    
	    // Calculate the position of the vertice as viewed by the second light source.
    output.lightViewPosition2 = mul(input.position, tW);
    output.lightViewPosition2 = mul(output.lightViewPosition2, lightViewMatrix2);
    output.lightViewPosition2 = mul(output.lightViewPosition2, lightProjectionMatrix2);

	 // Calculate the position of the vertex in the world.
    worldPosition = mul(input.position, tW);

    // Determine the light position based on the position of the light and the position of the vertex in the world.
    output.lightPos = lightPosition.xyz - worldPosition.xyz;

    // Normalize the light position vector.
    output.lightPos = normalize(output.lightPos);
	
	
       // Determine the second light position based on the position of the light and the position of the vertex in the world.
    output.lightPos2 = lightPosition2.xyz - worldPosition.xyz;

    // Normalize the second light position vector.
    output.lightPos2 = normalize(output.lightPos2);
	
    return output;
}




// Pixel Shader
////////////////////////////////////////////////////////////////////////////////
float4 MultiShadow_PS(PixelInputType input) : SV_TARGET
{

 
    float4 color;
    float2 projectTexCoord;
    float depthValue;
    float lightDepthValue;
    float lightIntensity;
    float4 textureColor;
	
	
	    // Set the bias value for fixing the floating point precision issues.
 

    // Set the default output color to the ambient light value for all pixels.
    color = ambientColor;
	
	 // Calculate the projected texture coordinates.
    projectTexCoord.x =  input.lightViewPosition.x / input.lightViewPosition.w / 2.0f + 0.5f;
    projectTexCoord.y = -input.lightViewPosition.y / input.lightViewPosition.w / 2.0f + 0.5f;

    // Determine if the projected coordinates are in the 0 to 1 range.  If so then this pixel is in the view of the light.
    if((saturate(projectTexCoord.x) == projectTexCoord.x) && (saturate(projectTexCoord.y) == projectTexCoord.y))
    {
        // Sample the shadow map depth value from the depth texture using the sampler at the projected texture coordinate location.
        depthValue = depthMapTexture.Sample(SamClamp, projectTexCoord).r;

        // Calculate the depth of the light.
        lightDepthValue = input.lightViewPosition.z / input.lightViewPosition.w;

        // Subtract the bias from the lightDepthValue.
        lightDepthValue = lightDepthValue - bias;

        // Compare the depth of the shadow map value and the depth of the light to determine whether to shadow or to light this pixel.
        // If the light is in front of the object then light the pixel, if not then shadow this pixel since an object (occluder) is casting a shadow on it.
        if(lightDepthValue < depthValue)
        {
            // Calculate the amount of light on this pixel.
            lightIntensity = saturate(dot(input.normal, input.lightPos));
            if(lightIntensity > 0.0f)
            {
                // Determine the final diffuse color based on the diffuse color and the amount of light intensity.
                color += (diffuseColor * lightIntensity);
            }
        }
    }
	
	// Second light.
    projectTexCoord.x =  input.lightViewPosition2.x / input.lightViewPosition2.w / 2.0f + 0.5f;
    projectTexCoord.y = -input.lightViewPosition2.y / input.lightViewPosition2.w / 2.0f + 0.5f;

    if((saturate(projectTexCoord.x) == projectTexCoord.x) && (saturate(projectTexCoord.y) == projectTexCoord.y))
    {
        depthValue = depthMapTexture2.Sample(SamClamp, projectTexCoord).r;

        lightDepthValue = input.lightViewPosition2.z / input.lightViewPosition2.w;
        lightDepthValue = lightDepthValue - bias;

        if(lightDepthValue < depthValue)
        {
            lightIntensity = saturate(dot(input.normal, input.lightPos2));
            if(lightIntensity > 0.0f)
            {
                color += (diffuseColor2 * lightIntensity);
            }
        }
    }


	    // Saturate the final light color.
    color = saturate(color);

    // Sample the pixel color from the texture using the sampler at this texture coordinate location.
    textureColor = texture2d.Sample(SamWrap, input.tex);

    // Combine the light and texture color.
    color = color * textureColor;

    return color;
}





technique10 MultiShadow
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, MultiShadow_VS() ) );
		SetPixelShader( CompileShader( ps_4_0, MultiShadow_PS() ) );
	}
}