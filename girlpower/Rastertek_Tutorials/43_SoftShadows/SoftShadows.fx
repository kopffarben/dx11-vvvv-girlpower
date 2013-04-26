//@author: colorsound
//@help: 
//@tags:
//@credits: www.rastertek.com

Texture2D texture2d <string uiname="Texture";>;

Texture2D depthMapTexture <string uiname="depthMapTexture";>;

Texture2D shadowTexture <string uiname="shadowTexture";>;



SamplerState g_samLinear 
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

SamplerState g_samLinearW 
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
    float4 diffuseColor <bool color=true;String uiname="diffuseColor";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform";>;
	float4x4 tColor <string uiname="Color Transform";>;

    matrix lightViewMatrix;
    matrix lightProjectionMatrix;
    float3 lightPosition;
    float bias = 0.001f;
    float4 ShadowColor <bool color=true;String uiname="ShadowColor";> = { 0.15f, 0.15f, 0.15f, 1.0f };

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

};



// Vertex Shader Shadows
////////////////////////////////////////////////////////////////////////////////



PixelInputType Shadows_VS(VertexInputType input)
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
    output.lightViewPosition = mul(input.position, tW);
    output.lightViewPosition = mul(output.lightViewPosition, lightViewMatrix);
    output.lightViewPosition = mul(output.lightViewPosition, lightProjectionMatrix);
	
	    // Calculate the position of the vertex in the world.
    worldPosition = mul(input.position,tW);

    // Determine the light position based on the position of the light and the position of the vertex in the world.
    output.lightPos = lightPosition.xyz - worldPosition.xyz;

    // Normalize the light position vector.
    output.lightPos = normalize(output.lightPos);

    return output;
}


struct PixelInputTypeSS
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
    float3 normal : NORMAL;
    float4 viewPosition : TEXCOORD1;
    float3 lightPos : TEXCOORD2;
};


// Pixel Shader Shadows
////////////////////////////////////////////////////////////////////////////////
float4 Shadows_PS(PixelInputType input) : SV_TARGET
{

    float4 color;
    float2 projectTexCoord;
    float depthValue;
    float lightDepthValue;
    float lightIntensity;


    // Set the default output color to be black (shadow).
    //color = float4(0.0f, 0.0f, 0.0f, 1.0f);
    color = ShadowColor ;
    // Calculate the projected texture coordinates.
    projectTexCoord.x =  input.lightViewPosition.x / input.lightViewPosition.w / 2.0f + 0.5f;
    projectTexCoord.y = -input.lightViewPosition.y / input.lightViewPosition.w / 2.0f + 0.5f;

    // Determine if the projected coordinates are in the 0 to 1 range.  If so then this pixel is in the view of the light.
    if((saturate(projectTexCoord.x) == projectTexCoord.x) && (saturate(projectTexCoord.y) == projectTexCoord.y))
    {
        // Sample the shadow map depth value from the depth texture using the sampler at the projected texture coordinate location.
        depthValue = depthMapTexture.Sample(g_samLinear, projectTexCoord).r;

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

            // If this pixel is illuminated then set it to pure white (non-shadow).
            if(lightIntensity > 0.0f)
            {

                color = float4(1.0f, 1.0f, 1.0f, 1.0f);
            }
        }
    }



    return color;
}

//////////

PixelInputTypeSS SoftShadows_VS(VertexInputType input)
{
    PixelInputTypeSS output;
    

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

     // Store the position of the vertice as viewed by the camera in a separate variable.
    output.viewPosition = output.position;
        // Calculate the position of the vertex in the world.
    worldPosition = mul(input.position, tW);

    // Determine the light position based on the position of the light and the position of the vertex in the world.
    output.lightPos = lightPosition.xyz - worldPosition.xyz;

    // Normalize the light position vector.
    output.lightPos = normalize(output.lightPos);

    return output;
}

// Pixel Shader
////////////////////////////////////////////////////////////////////////////////
float4 SoftShadows_PS(PixelInputTypeSS input) : SV_TARGET
{

	
	float4 color;
    float lightIntensity;
    float4 textureColor;
    float2 projectTexCoord;
    float4 shadowValue;
	//float shadowValue;

	    // Set the default output color to the ambient light value for all pixels.
    color = ambientColor;

    // Calculate the amount of light on this pixel.
    lightIntensity = saturate(dot(input.normal, input.lightPos));
    if(lightIntensity > 0.0f)
    {
        // Determine the light color based on the diffuse color and the amount of light intensity.
        color += (diffuseColor * lightIntensity);

        // Saturate the light color.
        color = saturate(color);
    }

    // Sample the pixel color from the texture using the sampler at this texture coordinate location.
    textureColor = texture2d.Sample(g_samLinearW, input.tex);

    // Combine the light and texture color.
    color = color * textureColor;


    // Calculate the projected texture coordinates to be used with the shadow texture.
    projectTexCoord.x =  input.viewPosition.x / input.viewPosition.w / 2.0f + 0.5f;
    projectTexCoord.y = -input.viewPosition.y / input.viewPosition.w / 2.0f + 0.5f;


    // Sample the shadow value from the shadow texture using the sampler at the projected texture coordinate location.
    shadowValue = shadowTexture.Sample(g_samLinear, projectTexCoord).rgba;
	//shadowValue = shadowTexture.Sample(g_samLinear, projectTexCoord).r;
   
    // Combine the shadows with the final color.
   color = color * shadowValue;

    return color;
}

technique10 Shadows
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, Shadows_VS() ) );
		SetPixelShader( CompileShader( ps_4_0, Shadows_PS() ) );
	}
}

technique10 SoftShadows
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, SoftShadows_VS() ) );
		SetPixelShader( CompileShader( ps_4_0, SoftShadows_PS() ) );
	}
}