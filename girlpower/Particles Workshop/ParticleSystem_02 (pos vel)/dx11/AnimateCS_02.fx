
bool reset;
float3 force;
float damp;

StructuredBuffer<float3> resetPos;

struct particle
{
	float3 pos;
	float3 vel;
};

RWStructuredBuffer<particle> Output : BACKBUFFER;

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
		float3 v = Output[DTid.x].vel;
		
		v *= damp;
		v += force;
		
		Output[DTid.x].vel = v;
		Output[DTid.x].pos = p + v;
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
