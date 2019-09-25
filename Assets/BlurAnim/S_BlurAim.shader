Shader "HCS/S_BlurAim"
{
	Properties
	{
		_Alpha ("Alpha", Float) = 0.8
		_MainTex ("Base (RGB)", 2D) = "" { }
		_BlurRadius ("Blur Radius", float) = 0.2
	}
	SubShader
	{
		//0:Dither
		Pass
		{
			Tags { "RenderType" = "Opaque" }
			
			
			Stencil
			{
				Ref 1
				Comp Always
				Pass Replace
			}
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
				float4 scrPos: TEXCOORD0;
			};
			
			//#define USE_CORE
			
			float _Alpha;
			
			inline float Dither(float value, float2 uv)
			{
				if (value <= 0) return - 1;
				
				
				#ifdef USE_CORE
					
					float2 px = uv * _ScreenParams.xy;
					
					px = float2(fmod(px.x, 8), fmod(px.y, 8));
					
					const float dither[64] = {
						1, 49, 13, 61, 4, 52, 16, 64,
						33, 17, 45, 29, 36, 20, 48, 32,
						9, 57, 5, 53, 12, 60, 8, 56,
						41, 25, 37, 21, 44, 28, 40, 24,
						3, 51, 15, 63, 2, 50, 14, 62,
						35, 19, 47, 31, 34, 18, 46, 30,
						11, 59, 7, 55, 10, 58, 6, 54,
						43, 27, 39, 23, 42, 26, 38, 22
					};
					
					
					int r = px.y * 8 + px.x;
					
					return value - (dither[r] - 1) / 63;
					
				#else
					float2 px = (uv + 1) * _ScreenParams.xy;
					
					int r = floor(px.x) + ceil(px.y);
					
					return sin(r/3);
				#endif
			}
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.scrPos = o.vertex;
				return o;
			}
			
			half4 frag(v2f i): SV_Target
			{
				float alpha = _Alpha;
				float2 srcUV = (i.scrPos.xy / i.scrPos.w);
				clip(Dither(alpha * 1.2, srcUV));
				return 1;
			}
			ENDCG
			
		}
		
		//1:Replace
		Pass
		{
			Tags { "RenderType" = "Transparent" }
			
			Blend SrcAlpha OneMinusSrcAlpha
			
			Stencil
			{
				Ref 1
				Comp Always
				Pass Replace
			}
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
			};
			
			struct v2f
			{
				float4 vertex: SV_POSITION;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				return 0;
			}
			
			ENDCG
			
		}
		
		//2:Blur
		Pass
		{
			Cull Off
			ZTest Always
			ZWrite Off
			Fog
			{
				Mode Off
			}
			
			Stencil
			{
				Ref 1
				Comp Equal
			}
			
			CGPROGRAM
			
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			
			struct v2f
			{
				float4 pos: POSITION;
				float2 uv: TEXCOORD0;
				float4 uv01: TEXCOORD1;
				float4 uv23: TEXCOORD2;
				float4 uv45: TEXCOORD3;
			};
			
			#define BLUR_SCALE 0.03
			
			float _BlurRadius;
			sampler2D _MainTex;
			
			v2f vert(appdata_img v)
			{
				v2f o;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.uv.xy = v.texcoord.xy;
				
				float4 offset = float4(1, 1, -1, -1) * _BlurRadius * BLUR_SCALE;
				
				o.uv01 = v.texcoord.xyxy + offset.xyxy;
				o.uv23 = v.texcoord.xyxy + offset.xyxy * 2.0;
				o.uv45 = v.texcoord.xyxy + offset.xyxy * 3.0;
				
				return o;
			}
			
			half4 frag(v2f i): SV_TARGET
			{
				half4 color = 0;
				
				color += 0.40 * tex2D(_MainTex, i.uv);
				color += 0.15 * tex2D(_MainTex, i.uv01.xy);
				color += 0.15 * tex2D(_MainTex, i.uv01.zw);
				color += 0.10 * tex2D(_MainTex, i.uv23.xy);
				color += 0.10 * tex2D(_MainTex, i.uv23.zw);
				color += 0.05 * tex2D(_MainTex, i.uv45.xy);
				color += 0.05 * tex2D(_MainTex, i.uv45.zw);
				
				return color;
			}
			
			ENDCG
			
		}
	}
}
