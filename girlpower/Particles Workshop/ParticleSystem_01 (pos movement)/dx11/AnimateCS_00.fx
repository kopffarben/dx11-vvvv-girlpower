
bool reset;

StructuredBuffer<float3> resetPos;

struct particle
{
	float3 pos;
	float3 vel;
};
RWStructuredBuffer<particle> Output : BACKBUFFER;

float3 velocity;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(64, 1, 1)]
void CSConstantForce( uint3 DTid : SV_DispatchThreadID )
{
	if (reset)
	{
		Output[DTid.x].pos = resetPos[DTid.x];
		Output[DTid.x].vel = 0;		
	}
	
	else
	{
		float3 p = Output[DTid.x].pos;		
		
		Output[DTid.x].vel = 0;
		Output[DTid.x].pos = p  + velocity;
		
		
	}
}

//==============================================================================
//TECHNIQUES ===================================================================
//==============================================================================

technique11 simulation
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}
