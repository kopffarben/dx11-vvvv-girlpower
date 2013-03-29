
bool reset;
float3 gravity;

//Ground:
float bounce = 1;

//Attractor:
float3 attrPos;
bool attrEnable;
float attrStrength = 0.01;
float attrRadius = 1;

//Reset Position (xyz) and random damping (w)
StructuredBuffer<float4> resetData;


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
		Output[DTid.x].pos = resetData[DTid.x].xyz;
		Output[DTid.x].vel = 0;
	}

	else
	{
		float3 p = Output[DTid.x].pos;
		float3 v = Output[DTid.x].vel;

		//Velocity Damping:
		v *= resetData[DTid.x].w;
		
		//Attractor:
		if(attrEnable)
		{
			float3 attrVec = attrPos - p;
			float attrForce = length(attrVec) / attrRadius;
			attrForce = 1 - attrForce;
			attrForce = saturate(attrForce);
			attrForce = pow(attrForce, 2.7172);
			v += attrVec * attrForce * attrStrength;
		}

		//Ground:
		if(p.y < 0) 
		{
			v = reflect(v, float3(0,1,0));
			v.y *= bounce;
			p.y = abs(p.y);
		}

		//Bounce Smoother:
		//get the y space from 0 to 0.1 and use it to attenuate gravity
		float bounceSmooth = saturate(p.y*10);
		v += gravity * bounceSmooth;

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
