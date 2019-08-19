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
		
		half3 CalcTubeLightToLight(float3 pos, float3 tubeStart, float3 tubeEnd, float3 eyeVec, half3 normal, float tubeRad)
		{
			half3 N = normal;
			half3 viewDir = -eyeVec;
			half3 r = reflect(viewDir, normal);
			
			float3 L0 = tubeStart - pos;
			float3 L1 = tubeEnd - pos;
			
			float distL0 = length(L0);
			float distL1 = length(L1);
			
			float NoL0 = dot(L0, N) / (2.0 * distL0);
			float NoL1 = dot(L1, N) / (2.0 * distL1);
			float NoL = (2.0 * clamp(NoL0 + NoL1, 0.0, 1.0)) / (distL0 * distL1 + dot(L0, L1) + 2.0);
			
			float3 Ld = L1 - L0;
			float RoL0 = dot(r, L0);
			float RoLd = dot(r, Ld);
			float L0oLd = dot(L0, Ld);
			float distLd = length(Ld);
			float t = (RoL0 * RoLd - L0oLd) / (distLd * distLd - RoLd * RoLd);
			
			float3 closestPoint = L0 + Ld * clamp(t, 0.0, 1.0);
			float3 centerToRay = dot(closestPoint, r) * r - closestPoint;
			closestPoint = closestPoint + centerToRay * clamp(tubeRad / length(centerToRay), 0.0, 1.0);
			float3 l = normalize(closestPoint);
			return l;
		}
		
		
		ENDCG
		
	}
}
