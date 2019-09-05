Shader "HCS/S_DecalShaderDiffuseOnly"
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
				o.ray = mul(UNITY_MATRIX_MV, v).xyz * float3(-1, -1, 1);
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
				float2 uv = i.screenUV.xy/i.screenUV.w;
			}
			
			ENDCG
			
		}
	}
}
