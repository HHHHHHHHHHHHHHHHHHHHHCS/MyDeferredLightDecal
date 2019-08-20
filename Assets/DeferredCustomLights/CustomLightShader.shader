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
		
		
		void DeferredCalculateLightParams(unity_v2f_deferred i, out float3 outWorldPos, out float2 outUV, out half3 outLightDir, out float outAtten, out float outFadeDist)
		{
			//这里是同比例放大
			i.ray = i.ray * (_ProjectionParams.z / i.ray.z);
			float2 uv = i.ux.xy / i.uv.w;
			
			//读取深度并且重建世界坐标
			float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
			depth = Linear01Depth(depth);
			float4 vpos = float4(i.ray * depth, 1);
			float3 wpos = mul(unity_CameraToWorld, vpos).xyz;
			
			//模型矩阵的位移
			float3 lightPos = float3(unity_ObjectToWorld[0][3], unity_ObjectToWorld[1][3], unity_ObjectToWorld[2][3]);
			
			//点光
			float3 tolight = wpos - lightPos;
			half3 lightDir = -normalize(tolight);
			
			//获得距离比例 得到衰减
			float att = dot(tolight, tolight) * _CustomLightInvSqRadius;
			float atten = tex2D(_LightTextureB0, att.rr).UNITY_ATTEN_CHANNEL;//UNITY_ATTEN_CHANNEL是r或者是a，这具体取决于目标平台
			
			outWorldPos = wpos;
			outUV = uv;
			outLightDir = lightDir;
			outAtten = atten;
			outFadeDist = 0;
		}
		
		ENDCG
		
	}
}
