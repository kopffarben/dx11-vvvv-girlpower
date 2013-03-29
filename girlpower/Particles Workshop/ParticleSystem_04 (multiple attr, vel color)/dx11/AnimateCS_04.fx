
bool reset;
float3 gravity;

//Ground:
float bounce = 1;

//Reset Position (xyz) and random damping (w)
StructuredBuffer<float4> resetData;

//Attractors Position Buffer
StructuredBuffer<float3> attrPos;
//Attractors Data Buffer (X = radius, Y = Strength)
StructuredBuffer<float2> attrData;


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
	
		//Multiple attractors
		uint count,dummy;	
		attrPos.GetDimensions(count,dummy);
		for(uint i=0 ; i<count; i++)
		{
			float3 attrVec = attrPos[i] - p;
			float attrRadius = attrData[i].x;
			float attrStrength = attrData[i].y;

			float attrForce = length(attrVec) / attrRadius;
			attrForce = 1 - attrForce;
			attrForce = saturate(attrForce);
			attrForce = pow(attrForce, 2);
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
		//get the y space from 0 to 0.1 and use it attenuate gravity
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
