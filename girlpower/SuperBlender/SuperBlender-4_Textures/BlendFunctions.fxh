/* Blend functions
* To use, declare and create an interface iBlender blend <string linkclass="blend,multiply,overlay,add,sub";>;
*/

interface iBlender
{
   float4 Blend(float4 c1, float4 c2,float alpha); 
};

#define bld(op,c0,c1) float4(lerp((c0*c0.a+c1*c1.a*(1-c0.a))/saturate(c0.a+c1.a*(1-c0.a)),(op),c0.a*c1.a).rgb,saturate(c0.a+c1.a*(1-c0.a)))

class cNormal : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1, 1, 1, alpha);
		return bld(lerp(c0, c1, alpha), c1, c0);
	}
};
cNormal Normal; //Class declaration

class cAdd : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1,alpha);
		return bld(c0+c1,c0,c1);
	}
};
cAdd Add; //Class declaration

class cSubstract : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1,alpha);
		return bld(c0-c1,c0,c1);
	}
};
cSubstract Substract; //Class declaration

class cScreen : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1, alpha);
		return bld(c0+c1*saturate(1-c0),c0,c1);
	}
};
cScreen Screen; //Class declaration

class cMultiply : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1, alpha);
		return bld(c0*c1,c0,c1);
	}
};
cMultiply Multiply; //Class declaration

class cDarken : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1, alpha);
		return bld(min(c0,c1),c0,c1);
	}
};
cDarken Darken; //Class declaration

class cLighten : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1, alpha);
		return bld(max(c0,c1),c0,c1);
	}
};
cLighten Lighten; //Class declaration

class cDifference : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1, alpha);
		return bld(abs(c0-c1),c0,c1);
	}
};
cDifference Difference; //Class declaration

class cExclusion : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1, alpha);
		return bld(c0+c1-2*c0*c1,c0,c1);
	}
};
cExclusion Exclusion; //Class declaration

class cOverlay : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1, alpha);
		return bld(lerp(1-2*(1-c0)*(1-c1),(2*c0*c1),(c0<.5)),c0,c1);
	}
};
cOverlay Overlay; //Class declaration

class cHardlight : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1, alpha);
		return bld(lerp(1-2*(1-c0)*(1-c1),(2*c0*c1),(c1<.5)),c0,c1);
	}
};
cHardlight Hardlight; //Class declaration

class cSoftlight : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1, alpha);
		return bld(2*c0*c1+c0*c0-2*c0*c0*c1,c0,c1);
	}
};
cSoftlight Softlight; //Class declaration

class cDodge : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1, alpha);
		return bld(lerp(c0/(1-c1),1,(c1==1)),c0,c1);
	}
};
cDodge Dodge; //Class declaration

class cBurn : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1, alpha);
		return bld(lerp(1-(1-c0)/c1,0,(c1==0)),c0,c1);
	}
};
cBurn Burn; //Class declaration

class cReflect : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1, alpha);
		return bld(lerp(c0*c0/(1-c1),1,(c1==1)),c0,c1);
	}
};
cReflect Reflect; //Class declaration

class cGlow : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1, alpha);
		return bld(lerp(c1*c1/(1-c0),1,(c0==1)),c0,c1);
	}
};
cGlow Glow; //Class declaration

class cFreeze : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1, alpha);
		return bld(lerp(1-pow(1-c0,2)/c1,0,(c1==0)),c0,c1);
	}
};
cFreeze Freeze; //Class declaration

class cHeat : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1, alpha);
		return bld(lerp(1-pow(1-c1,2)/c0,0,(c0==0)),c0,c1);
	}
};
cHeat Heat; //Class declaration

class cDivide : iBlender{
	float4 Blend(float4 c0, float4 c1, float alpha){
		c1*=float4(1,1,1, alpha);
		return bld(c0/c1,c0,c1);
	}
};
cDivide Divide; //Class declaration
