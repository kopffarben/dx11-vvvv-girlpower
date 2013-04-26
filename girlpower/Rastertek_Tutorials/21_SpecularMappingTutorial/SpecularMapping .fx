//@author: colorsound
//@help: 
//@tags:
//@credits: http://www.rastertek.com

Texture2D texture2d <string uiname="Texture";>;

Texture2D BumpTexture <string uiname="BumpTexture";>;

Texture2D SpecularTexture <string uiname="SpecularTexture";>;

SamplerState g_samLinear 
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

 
    float4x4 tW : WORLD;
	float4x4 tVP : VIEWPROJECTION;

	float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
 
    


	float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform";>;
	float4x4 tColor <string uiname="Color Transform";>;
    
    float4 diffuseColorIn<bool color=true;String uiname="diffuseColor";> = { 1.0f,1.0f,1.0f,1.0f };
    float3 lightDirection;
    
    float3 cameraPosition;
	float4 specularColor<bool color=true;String uiname="specularColor";> = { 1.0f,1.0f,1.0f,1.0f };
    float specularPower ;


struct VertexInputType //VS_IN
{
    float4 position : POSITION;
    float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
	//float3 tangent : TANGENT;
   //float3 binormal : BINORMAL;

};

struct PixelInputType // vs2ps
{
    float4 position : SV_POSITION;
    float2 tex : TEXCOORD0;
	float3 normal : NORMAL;
	//float3 tangent : TANGENT;
    //float3 binormal : BINORMAL;
	float3 viewDirection : TEXCOORD1;
};



// Vertex Shader
////////////////////////////////////////////////////////////////////////////////
PixelInputType SpecularMapping_VS(VertexInputType input)
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

	
	
	
	   // Calculate the position of the vertex in the world.
    worldPosition = mul(input.position, tW);

    // Determine the viewing direction based on the position of the camera and the position of the vertex in the world.
   output.viewDirection = cameraPosition.xyz - worldPosition.xyz;
	
    // Normalize the viewing direction vector.
    output.viewDirection = normalize(output.viewDirection);
	
	// Calculate the tangent vector against the world matrix only and then normalize the final value.
  // output.tangent = mul(input.tangent, (float3x3)tW);
   // output.tangent = normalize(output.tangent);
	
	// Calculate the binormal vector against the world matrix only and then normalize the final value.
   //output.binormal = mul(input.binormal, (float3x3)tW);
   //output.binormal = normalize(output.binormal);
	
    return output;
}




// Pixel Shader
////////////////////////////////////////////////////////////////////////////////
float4 SpecularMapping_PS(PixelInputType input) : SV_TARGET
{
	
       
	float4 alphaValue;  
	
    
  
    float3 lightDir;
    float lightIntensity;
  
    float4 diffuseColor ;
	lightDir = lightDirection;

	float4 textureColor;
    float4 bumpMap;
    float3 bumpNormal;
   
    float4 color;
    float4 specularIntensity;
    float3 reflection;
    float4 specular;
	diffuseColor = diffuseColorIn;
	
	
	float3 tangent ={1.0f,0.0f,0.0f};
    float3 binormal ={0.0f,1.0f,0.0f};

	
	// Sample the pixel color from the texture using the sampler at this texture coordinate location.
	textureColor = texture2d.Sample(g_samLinear,input.tex);
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
	
   color = color * textureColor;
	
	  if(lightIntensity > 0.0f)
    {
	
	 // Sample the pixel from the specular map texture.
        specularIntensity = SpecularTexture.Sample(g_samLinear, input.tex);
	
	// Calculate the reflection vector based on the light intensity, normal vector, and light direction.
        reflection = normalize(2 * lightIntensity * bumpNormal - lightDir); 

        // Determine the amount of specular light based on the reflection vector, viewing direction, and specular power.
        specular = pow(saturate(dot(reflection, input.viewDirection)), specularPower) * specularColor;
    	
    	
    	     // Use the specular map to determine the intensity of specular light at this pixel.
        specular = specular * specularIntensity;
		
        // Add the specular component last to the output color.
        color = saturate(color + specular);
    	
    }
	
   color = color * cAmb ;
	
   color.a *= Alpha;
    
    return color;
}








technique10 SpecularMapping
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, SpecularMapping_VS() ) );
		SetPixelShader( CompileShader( ps_4_0, SpecularMapping_PS() ) );
	}
}


