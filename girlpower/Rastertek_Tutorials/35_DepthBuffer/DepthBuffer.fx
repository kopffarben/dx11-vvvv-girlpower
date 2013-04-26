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
 
    


	float4 CloseDB <bool color=true;String uiname="CloseDB";> = { 1.0f,1.0f,1.0f,1.0f };
    float4 MediumDB <bool color=true;String uiname="MediumDB";> = { 1.0f,1.0f,1.0f,1.0f };
    float4 FarDB <bool color=true;String uiname="FarDB";> = { 1.0f,1.0f,1.0f,1.0f };
	float4x4 tTex <string uiname="Texture Transform";>;
	float4x4 tColor <string uiname="Color Transform";>;

struct VertexInputType //VS_IN
{
    float4 position : POSITION;



};

struct PixelInputType // vs2ps
{
    float4 position : SV_POSITION;
    float4 depthPosition : TEXTURE0;



};



// Vertex Shader
////////////////////////////////////////////////////////////////////////////////



PixelInputType DepthBuffer_VS(VertexInputType input)
{
    PixelInputType output;
    

	float4 cameraPosition;
	

 // Change the position vector to be 4 units for proper matrix calculations.
    input.position.w = 1.0f;


	// Calculate the position of the vertex against the world, view, and projection matrices.
    output.position = mul(input.position,tW);
    output.position = mul(output.position,tVP);
   
    
    // Store the position value in a second input value for depth value calculations.
    output.depthPosition = output.position;




    return output;
}




// Pixel Shader
////////////////////////////////////////////////////////////////////////////////
float4 DepthBuffer_PS(PixelInputType input) : SV_TARGET
{
    
	
	float depthValue;
	float4 color;


    // Get the depth value of the pixel by dividing the Z pixel depth by the homogeneous W coordinate.
	depthValue = input.depthPosition.z / input.depthPosition.w;
	
	// First 10% of the depth buffer color red.o
	if(depthValue < 0.9f)
	{
		color = CloseDB;
	}
	
	// The next 0.025% portion of the depth buffer color green.
	if(depthValue > 0.9f)
	{
		color = MediumDB;
	}

	// The remainder of the depth buffer color blue.
	if(depthValue > 0.925f)
	{
		color = FarDB;
	}

	return color;
}



technique10 DepthBuffer
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, DepthBuffer_VS() ) );
		SetPixelShader( CompileShader( ps_4_0, DepthBuffer_PS() ) );
	}
}