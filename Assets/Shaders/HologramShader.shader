﻿Shader "Custom/HologramShader"
{
	Properties
	{
		_SlicingPlane("Slicing Plane", Vector) = (0, 0, 0, 0)
	
		[Toggle(USE_HOLOGRAM)] _UseHologram("Use Hologram", Float) = 1
		_HologramColor("Hologram Color", Color) = (1, 1, 1, 1)
		_HologramIntensity("Hologram Intensity", Float) = 1
		_HologramTex("Hologram Texture", 2D) = "white" {}
	}
	SubShader
	{	
		/*
		Hologram pass
		*/

		Pass
		{
			Name "Hologram_Pass"

			Tags{ "Queue" = "Transparent+2" }
			
			Cull back
			ZWrite off
			Lighting off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma fragment frag 
			#pragma vertex vert 
			#pragma shader_feature USE_HOLOGRAM

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

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _HologramTex);
				o.fragWorldPos = mul(UNITY_MATRIX_M, v.vertex);

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
#if USE_HOLOGRAM
				float em = Slice(_SlicingPlane, i.fragWorldPos);

				if (em > 0)
				{
					fixed4 c = tex2D(_HologramTex, i.uv) * _HologramColor;
					c.rgb = c.rgb * _HologramIntensity;
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
