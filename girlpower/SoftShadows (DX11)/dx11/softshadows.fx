// Soft Shadow map example using floating point depth texture performing percentage-closer filtering
// Source: NVIDIA
//@author: colorsound
//@help: SoftShadow
//@tags:Shadow
//@credits: flux,unc

//transforms
float4x4 tW: WORLD;
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tWITXf : WORLDINVERSETRANSPOSE;
float4x4 tVIXf : VIEWINVERSE;

float4x4 LampViewXf;
float4x4 LampProjXf;
float samples = 20 ;
#define PCF_SAMPS samples      //<<< SAMPLE COUNT
#define PCFH ((PCF_SAMPS-1)/2)
#define PCFT (PCF_SAMPS*PCF_SAMPS)

//textures
Texture2D shadowTex <string uiname="shadowTexture";>;


SamplerState g_samLinearP : IMMUTABLE
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = Clamp;
    AddressV = Clamp;
};

Texture2D Tex <string uiname="Texture";>;

SamplerState g_samLinearL : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};




//texture transformation marked with semantic TEXTUREMATRIX to achieve symmetric transformations
float4x4 tTex: TEXTUREMATRIX <string uiname="Texture Transform";>;

/////////////////////////PARAMETERS////////////////////////////////////////////

float3 SpotLightPos <string UIName = "Lamp Posistion";> = {-1.0f, 1.0f, 0.0f};
float PCFSize <float uimin = 0.100;string uiname = "PCF Filter Width";> = 0.01;
//float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
float SpotLightCone <string UIName = "Cone Angle";float uimin=0.0;> = 60.0;

float4 lAmb <bool color=true;String uiname="Ambient Color";> = { 0.15, 0.15, 0.15, 1 };
float4 lDiff  <bool color=true;String uiname="Diffuse Color";> = { 0.85, 0.85, 0.85, 1 };
float4 lSpec  <bool color=true;String uiname="lSpec";> = { 0.35, 0.35, 0.35, 1 };

float lPower <String uiname="Power"; float uimin=0.0;> = 25.0;

////////////////////////////////////////////////////////////////////////////////

struct vs2ps
{
   float4 Position    : SV_POSITION;
   float2 TexCd           : TEXCOORD0;
   float3 LightVec     : TEXCOORD1;
   float3 WNormal      : TEXCOORD2;
   float3 WView        : TEXCOORD3;
   float4 LP           : TEXCOORD4;
};

// --------------------------------------------------------------------------------------------------
// VERTEXSHADERS
// --------------------------------------------------------------------------------------------------
vs2ps VS(
   float3 Position     : POSITION,
   float4 TexCd           : TEXCOORD0,
   float4 Normal       : NORMAL)
{
    //inititalize all fields of output struct with 0
    vs2ps Out = (vs2ps)0;

    //transform position
    Out.WNormal = mul(Normal,tWITXf).xyz;
    float4 Po = float4(Position.xyz,(float)1.0);     // "P" in object coordinates
    float4 Pw = mul(Po,tW);                        // "P" in world coordinates
    float4x4 ShadowViewProjXf = mul(LampViewXf,LampProjXf);    // light viewprojection
    float4 Pl = mul(Pw,ShadowViewProjXf);  // "P" in light coords

    Out.LP = Pl;
    Out.WView = normalize(tVIXf[3].xyz - Pw.xyz);     // world coords
    Out.Position = mul(Po,tWVP);    // screen clipspace coords
    Out.TexCd = TexCd.xy;
    Out.LightVec = SpotLightPos - Pw.xyz;

    return Out;
}

// --------------------------------------------------------------------------------------------------
// PIXELSHADERS:
// --------------------------------------------------------------------------------------------------

// Utility function for pixel shaders to use this shadow map
float shadow_calc(float4 LP,	// current shaded point in light-projected coordinates
uniform	sampler g_samLinearP)
{
        float totalShad=0;
	int i, j;
	float offSize = PCFSize / (float)PCF_SAMPS;
	for (i = -PCFH; i<= PCFH; i += 1) {
		for (j = -PCFH; j<= PCFH; j += 1) {
			float2 offset = float2(offSize*i,offSize*j);
			float2 nuv = float2(.5,-.5)*(LP.xy+offset)/LP.w + float2(.5,.5);
			float shadMapDepth = shadowTex.Sample(g_samLinearP,nuv).x;
			float shad = 1-(shadMapDepth<LP.z);
			totalShad += shad;
		}
	}
	return totalShad/(float)PCFT;
}

float4 useShadowPS(vs2ps In): SV_Target
{
    float CosSpotAng = cos(radians(SpotLightCone));
    float3 Nn = normalize(In.WNormal);
    float3 Vn = normalize(In.WView);
    float3 Ln = normalize(In.LightVec);
    float3 Hn = normalize(Vn + Ln);
    float hdn = dot(Hn,Nn);
    float ldn = dot(Ln,Nn);
    float4 litVec = lit(ldn,hdn,lPower);
    ldn = litVec.y;

    float dl = normalize(In.LP.xyz).z;
    dl = max((float)0,((dl-CosSpotAng)/(((float)1.0)-CosSpotAng)));
    float3 diffContrib = (float3)lDiff*ldn;
    float3 specContrib = ldn * litVec.z * (float3)lSpec;
    float3 result = diffContrib + specContrib;

    float shadowed = shadow_calc(In.LP,g_samLinearP);

    float4 col = Tex.Sample(g_samLinearL, In.TexCd);

   
    col *= float4((dl*shadowed*result)+(float3)lAmb,1);
    //return float4(shadowed.xxx,1);
    return col;
}

// --------------------------------------------------------------------------------------------------
// TECHNIQUES:
// --------------------------------------------------------------------------------------------------

technique10 Shadow
{
    pass P0
    {
    	
    	SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0,useShadowPS() ) );
    
    }
}
