Shader "Custom/HologramShader"
{
	Properties
	{
		_SlicingPlane("Slicing Plane", Vector) = (0, 0, 0, 0)
	
		[KeywordEnum(Off, On)] _UseHologram("Use Hologram", Float) = 1
		_HologramColor("Hologram Color", Color) = (1, 1, 1, 1)
		_HologramIntensity("Hologram Intensity", Float) = 1
		_HologramTex("Hologram Texture", 2D) = "white" {}
	}
	SubShader
	{	
		/*
		Hologram pass
		*/

		Tags{ "Queue" = "Transparent+100" }
		Pass
		{
			Name "Hologram_Pass"
			
			Cull back
			Lighting off
			Blend SrcAlpha OneMinusSrcAlpha
			AlphaToMask On

			CGPROGRAM

			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma fragment frag 
			#pragma vertex vert 
			#pragma shader_feature _USEHOLOGRAM_ON _USEHOLOGRAM_OFF

			#include "UnityCG.cginc"

			uniform float4 _SlicingPlane;
			uniform float4 _HologramColor;
			uniform float _HologramIntensity;
			uniform sampler2D _HologramTex;
			float4 _HologramTex_ST;	
			
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 fragWorldPos : TEXCOORD1;
			};			

			v2f vert(appdata_full v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);

				o.uv = TRANSFORM_TEX(v.texcoord, _HologramTex);
				o.fragWorldPos = mul(UNITY_MATRIX_M, v.vertex);
				o.pos = UnityObjectToClipPos(v.vertex);

				return o;
			}

			float Slice(float4 plane, float3 fragPos)
			{
				float distance = dot(fragPos.xyz, plane.xyz) + plane.w;

				if (distance > 0)
				{
					return 1;
				}

				return 0;
			}

			half4 frag(v2f i) : SV_Target
			{
#if _USEHOLOGRAM_ON
				float em = Slice(_SlicingPlane, i.fragWorldPos);

				if (em > 0)
				{
					fixed4 c = fixed4(tex2D(_HologramTex, i.uv).rgb * _HologramColor.rgb, 1);
					c.rgb = c.rgb * _HologramIntensity;
					c.a = _HologramColor.a;
					return c;
				}
				else
				{
					return half4(0, 0, 0, 0);
				}			

#else
				return half4(0, 0, 0, 0);
#endif
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}
