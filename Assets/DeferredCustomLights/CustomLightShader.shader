Shader "HCS/PointArea"
{
	
	SubShader
	{
		Tags { "Queue" = "Transparent-1" }
		
		CGINCLUDE
		
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "UnityDeferredLibrary.cginc"
		
		// Light parameters
		// x tube length
		// y size
		// z 1/radius
		// w type
		float4 _CustomLightParams;
		#define _CustomLightLength _CustomLightParams.x
		#define _CustomLightSize _CustomLightParams.y
		#define _CustomLightInvSqRadius _CustomLightParams.z
		#define _CustomLightType _CustomLightParams.w
		
		sampler2D _CameraGBufferTexture0;
		sampler2D _CameraGBufferTexture1;
		sampler2D _CameraGBufferTexture2;
		
		half3 CalcSphereLightToLight(float3 pos, float3 lightPos, float3 eyeVec, half3 normal, float sphereRad)
		{
			half3 viewDir = -eyeVec;
			half3 r = reflect(viewDir, normal);
			
			float3 L = lightPos - pos;
			float3 centerToRay = dot(L, r) * r - L;
			float3 closestPoint = L + centerToRay * saturate(sphereRad / length(centerToRay));
			return normalize(closestPoint);
		}
		
		
		ENDCG
		
	}
}
