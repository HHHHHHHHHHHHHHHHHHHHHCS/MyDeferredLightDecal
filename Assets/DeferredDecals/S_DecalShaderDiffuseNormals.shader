Shader "HCS/S_DecalShaderDiffuseNormals"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" { }
		_BumpMap ("Normals", 2D) = "bump" { }
	}
	SubShader
	{
		pass
		{
			Fog
			{
				Mode Off
			}
			ZWrite Off
			
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
				float4 screenUV: TEXCOORD1;
				float3 ray: TEXCOORD2;
				half3 orientation: TEXCOORD3;
				half3 orientationX: TEXCOORD4;
				half3 orientationZ: TEXCOORD5;
			};
			
			v2f vert(float4 v: POSITION)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v);
				o.uv = v.xz + 0.5;
				o.screenUV = ComputeScreenPos(o.pos);
				o.ray = UnityObjectToViewPos(v) * float3(-1, -1, 1);//View矩阵存在XY翻转
				o.orientation = mul((float3x3)unity_ObjectToWorld, float3(0, 1, 0));
				o.orientationX = mul((float3x3)unity_ObjectToWorld, float3(1, 0, 0));
				o.orientationZ = mul((float3x3)unity_ObjectToWorld, float3(0, 0, 1));
				return o;
			}
			
			CBUFFER_START(UnityPerCamera2)
			
			CBUFFER_END
			
			sampler2D _MainTex;
			sampler2D _BumpMap;
			sampler2D_float _CameraDepthTexture;
			sampler2D _NormalsCopy;
			
			void frag(v2f i, out half4 outDiffuse: COLOR0, out half4 outNormal: COLOR1)
			{
				i.ray = i.ray * (_ProjectionParams.z / i.ray.z);
				float2 uv = i.screenUV.xy / i.screenUV.w;
				
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv);
				depth = Linear01Depth(depth);
				float4 vpos = float4(i.ray * depth, 1);
				float3 wpos = mul(unity_CameraToWorld, vpos).xyz;
				float3 opos = mul(unity_WorldToObject, float4(wpos, 1)).xyz;
				
				clip(0.5 - abs(opos.xyz));
				
				i.uv = opos.xz + 0.5;
				
				half3 normal = tex2D(_NormalsCopy, uv).rgb;
				half3 wnormal = normal.rgb * 2.0 - 1.0;
				
				clip(dot(wnormal, i.orientation) - 0.3);
				
				half4 col = tex2D(_MainTex, i.uv);
				clip(col.a - 0.2);
				outDiffuse = col;
				
				half3 nor = UnpackNormal(tex2D(_BumpMap, i.uv));
				half3x3 norMat = half3x3(i.orientationX, i.orientationZ, i.orientation);
				nor = mul(nor, norMat);
				outNormal = half4(nor * 0.5 + 0.5, 1);
			}
			
			ENDCG
			
		}
	}
}
