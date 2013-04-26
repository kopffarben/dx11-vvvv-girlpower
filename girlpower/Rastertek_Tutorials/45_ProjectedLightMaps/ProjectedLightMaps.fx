//@author: colorsound
//@help: 
//@tags:
//@credits: www.rastertek.com

Texture2D texture2d <string uiname="Texture";>;
Texture2D projectionTexture <string uiname="projectionTexture";>;


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

	float4 ambientColor <bool color=true;String uiname="ambientColor";> = { 1.0f,1.0f,1.0f,1.0f };
    float4 diffuseColor <bool color=true;String uiname="diffuseColor";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform";>;
	float4x4 tColor <string uiname="Color Transform";>;

    matrix viewMatrix2;
    matrix projectionMatrix2;
    float3 lightPosition;
    float brightness = 1.5f;

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
	float4 viewPosition : TEXCOORD1;
    float3 lightPos : TEXCOORD2 ;

};

// Vertex Shader
////////////////////////////////////////////////////////////////////////////////

PixelInputType ProjectedLightMaps_VS(VertexInputType input)
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

    // Store the position of the vertice as viewed by the projection view point in a separate variable.
    output.viewPosition = mul(input.position,tW);
    output.viewPosition = mul(output.viewPosition, viewMatrix2);
    output.viewPosition = mul(output.viewPosition, projectionMatrix2);

    // Calculate the position of the vertex in the world.
    worldPosition = mul(input.position,tW);

    // Determine the light position based on the position of the light and the position of the vertex in the world.
    output.lightPos = lightPosition.xyz - worldPosition.xyz;

    // Normalize the light position vector.
    output.lightPos = normalize(output.lightPos);

    return output;
}

// Pixel Shader
////////////////////////////////////////////////////////////////////////////////
float4 ProjectedLightMaps_PS(PixelInputType input) : SV_TARGET
{

    float4 color;
    float lightIntensity;
    float4 textureColor;
    float2 projectTexCoord;
    float4 projectionColor;


    // Calculate the amount of light on this pixel.
    lightIntensity = saturate(dot(input.normal, input.lightPos));

    if(lightIntensity > 0.0f)
    {
        // Determine the light color based on the diffuse color and the amount of light intensity.
        color = (diffuseColor * lightIntensity) * brightness;
    }

    // Sample the pixel color from the texture using the sampler at this texture coordinate location.
    textureColor = texture2d.Sample(g_samLinear, input.tex);



    // Calculate the projected texture coordinates.
    projectTexCoord.x =  input.viewPosition.x / input.viewPosition.w / 2.0f + 0.5f;
    projectTexCoord.y = -input.viewPosition.y / input.viewPosition.w / 2.0f + 0.5f;

    // Determine if the projected coordinates are in the 0 to 1 range.  If it is then this pixel is inside the projected view port.
    if((saturate(projectTexCoord.x) == projectTexCoord.x) && (saturate(projectTexCoord.y) == projectTexCoord.y))
    {
        // Sample the color value from the projection texture using the sampler at the projected texture coordinate location.
        projectionColor = projectionTexture.Sample(g_samLinear, projectTexCoord);


        // Set the output color of this pixel to the projection texture overriding the regular color value.
        color = saturate((color * projectionColor * textureColor) + (ambientColor * textureColor));
    }
    else
    {

        color = textureColor * ambientColor ;
    }

    return color;
}




technique10 ProjectedLightMaps
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, ProjectedLightMaps_VS() ) );
		SetPixelShader( CompileShader( ps_4_0, ProjectedLightMaps_PS() ) );
	}
}