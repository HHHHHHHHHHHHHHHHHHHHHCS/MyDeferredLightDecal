﻿Shader "HCS/S_DecalShaderNormalsOnly"
{
	Properties
	{
		_MainTex ("Diffuse", 2D) = "white" { }
		_BumpMap ("Normals", 2D) = "bump" { }
	}
	
	SubShader
	{
		Pass
		{
			//G-Buffers no fog
			Fog
			{
				Mode Off
			}
			ZWrite Off
			//G-Buffer-2 not need Blend
			//Blend SrcAlpha OneMinusSrcAlpha
			
			
			CGPROGRAM
			
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma exclude_renderers nomrt
			
			#include "UnityCG.cginc"
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				half2 uv: TEXCOORD0;
				half4 screenUV: TEXCOORD1;
				float3 ray: TEXCOORD2;
				half3 orientation: TEXCOORD3;
				half3 orientationX: TEXCOORD4;
				half3 orientationZ: TEXCOORD5;
			};
			
			v2f vert(float4 v: POSITION)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v);
				o.uv = v.xz + 0.5;//其实XY 也差不多
				o.screenUV = ComputeScreenPos(o.pos);
				o.ray = mul(UNITY_MATRIX_MV, v).xyz * float3(-1, -1, 1);//View矩阵存在XY翻转
				o.orientation = mul((float3x3)unity_ObjectToWorld, float3(0, 1, 0));
				o.orientationX = mul((float3x3)unity_ObjectToWorld, float3(1, 0, 0));
				o.orientationZ = mul((float3x3)unity_ObjectToWorld, float3(0, 0, 1));
				return o;
			}
			
			CBUFFER_START(UnityPerCamera2)
			// float4x4 _CameraToWorld;
			CBUFFER_END
			
			sampler2D _MainTex;
			sampler2D _BumpMap;
			sampler2D_float _CameraDepthTexture;
			sampler2D _NormalsCopy;
			
			/*
			void frag(
				v2f i,
				out half4 outDiffuse : COLOR0,			// RT0: diffuse color (rgb), --unused-- (a)
			out half4 outSpecRoughness : COLOR1,	// RT1: spec color (rgb), roughness (a)
			out half4 outNormal : COLOR2,			// RT2: normal (rgb), --unused-- (a)
			out half4 outEmission : COLOR3			// RT3: emission (rgb), --unused-- (a)
			)
			*/
			half4 frag(v2f i): SV_TARGET
			{
				i.ray = i.ray * (_ProjectionParams.z / i.ray.z);
				float2 uv = i.screenUV.xy / i.screenUV.w;
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
				depth = Linear01Depth(depth);
				float4 vpos = float4(i.ray * depth, 1);
				float3 wpos = mul(unity_CameraToWorld, vpos).xyz;
				float3 opos = mul(unity_WorldToObject, float4(wpos, 1)).xyz;
				
				clip(float3(0.5, 0.5, 0.5) - abs(opos).xyz);
				
				i.uv = opos.xz + 0.5;
				
				half3 normal = tex2D(_NormalsCopy, uv).rgb;
				half3 wnormal = normal.rgb * 2.0 - 1.0;
				clip(dot(wnormal, i.orientation) - 0.3);
				
				half4 col = tex2D(_MainTex, i.uv);
				clip(col.a - 0.2);
				
				half3 nor = UnpackNormal(tex2D(_BumpMap, i.uv));
				//nor = half3(0,0,1);
				//转换到世界坐标系
				half3x3 norMat = half3x3(i.orientationX, i.orientationZ, i.orientation);
				nor = mul(nor, norMat);
				
				return half4(nor * 0.5 + 0.5, 1);
			}
			
			ENDCG
			
		}
	}
}
