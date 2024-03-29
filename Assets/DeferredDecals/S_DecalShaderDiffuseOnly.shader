﻿Shader "HCS/S_DecalShaderDiffuseOnly"
{
	Properties
	{
		_MainTex ("Diffuse", 2D) = "white" { }
	}
	
	SubShader
	{
		Pass
		{
			Fog
			{
				Mode Off
			}
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			
			
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
			};
			
			v2f vert(float4 v: POSITION)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v);
				o.uv = v.xz + 0.5;//其实XY 也差不多
				o.screenUV = ComputeScreenPos(o.pos);
				o.ray = mul(UNITY_MATRIX_MV, v).xyz * float3(-1, -1, 1);//View矩阵存在XY翻转
				o.orientation = mul((float3x3)unity_ObjectToWorld, float3(0, 1, 0));
				return o;
			}
			
			CBUFFER_START(UnityPerCamera2)
			
			CBUFFER_END
			
			sampler2D _MainTex;
			sampler2D_float _CameraDepthTexture;
			sampler2D _NormalsCopy;
			
			half4 frag(v2f i): SV_TARGET
			{
				i.ray = i.ray * (_ProjectionParams.z / i.ray.z);
				float2 uv = i.screenUV.xy / i.screenUV.w;
				
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
				depth = Linear01Depth(depth);
				float4 vpos = float4(i.ray * depth, 1);
				float3 wpos = mul(unity_CameraToWorld, vpos).xyz;
				float3 opos = mul(unity_WorldToObject, float4(wpos, 1)).xyz;
				
				//矩阵范围剔除
				clip(0.5 - abs(opos.xyz));
				
				i.uv = opos.xz + 0.5;
				
				half3 normal = tex2D(_NormalsCopy, uv).rgb;
				half3 wnormal = normal.rgb * 2.0 - 1.0;
				//边缘剔除
				clip(dot(wnormal, i.orientation) - 0.3);
				
				half4 col = tex2D(_MainTex, i.uv);
				
				return col;
			}
			
			ENDCG
			
		}
	}
}
