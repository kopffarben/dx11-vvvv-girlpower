int pCount;
int emitCount;

//Emitters Position Buffer
StructuredBuffer<float3> emitPos;
//Emitters Data Buffer (XYZ emission velocity)
StructuredBuffer<float3> emitVel;
//Emitters Color
StructuredBuffer<float4> emitCol;

StructuredBuffer<float3> emitRndDir;
float rndEmitVelAmount;

int indexOffset;

struct particle
{
	float3 pos;
	float3 vel;
	float3 col;
	float size;
};

RWStructuredBuffer<particle> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(1, 1, 1)]
void CSConstantForce( uint3 DTid : SV_DispatchThreadID )
{
	// Emitters Data:
	uint emitIndex = DTid.x % emitCount;
	float3 p = emitPos[emitIndex];
	float3 v = emitVel[emitIndex];
	float3 c = emitCol[emitIndex].xyz;

	// indices of emitted particles:
	uint index = indexOffset + DTid.x;
	index = index % pCount;
	
	//random emission direction component:
	float3 rndEmitVel = rndEmitVelAmount * emitRndDir[index];

	// write position and velocity of emitted particles:
	Output[index].vel = v + rndEmitVel;
	Output[index].pos = p;
	Output[index].col = c;
	
}

//==============================================================================
//TECHNIQUES ===================================================================
//==============================================================================

technique11 emission
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}
