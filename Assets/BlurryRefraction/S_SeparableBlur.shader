Shader "HCS/S_SeparableBlur"
{
	Properties
	{
		_BumpAmt ("Distortion", Range(0, 64)) = 10
		_TintAmt ("Tint Amount", Range(0, 1)) = 0.1
		_MainTex ("Tint Color(RGB)", 2D) = "white" { }
		_BumpMap ("Normalmap", 2D) = "bump" { }
	}
	Category //Category 告诉下面的subshader 都用外面这一套渲染设置
	{
		//玻璃需要透明的
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
		
		Pass
		{
			Tags { "LightMode" = "Always" }
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
			
			struct a2v
			{
				float4 vertex: POSITION;
				float2 texcoord: TEXCOORD0;
			};
			
			struct v2f
			{
				float4 vertex: POSITION;
				float4 uvgrab: TEXCOORD0;
				float2 uvbump: TEXCOORD1;
				float2 uvmian: TEXCOORD2;
				UNITY_FOG_COORDS(3)
			};
			
			ENDCG
			
		}
	}
}
