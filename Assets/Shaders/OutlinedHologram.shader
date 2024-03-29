﻿Shader "Custom/OutlinedHologram"
{
    Properties
    {
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0

		_SlicingPlane("Slicing Plane", Vector) = (0, 1, 0, 10000)

		[KeywordEnum(Off, On)] _UseHologram("Use Hologram", Float) = 1
		_HologramColor("Hologram Color", Color) = (1, 1, 1, 1)
		_HologramIntensity("Hologram Intensity", Float) = 1
		_HologramTex("Hologram Texture", 2D) = "white" {}

		[KeywordEnum(Off, On)] _UseOutline("Use Outline", Float) = 0
		_OutlineColor("Outline Color", Color) = (1, 1, 1, 1)
		_OutlineThickness("Outline Thickness", Range(0, 1)) = 0.01
		_OutlineIntensity("Outline Intensity", Float) = 1
		_Angle("Switch shader on angle", Range(0.0, 180)) = 89
    }
    SubShader
    {
		Tags{ "Queue" = "Transparent+10" }
		Pass
		{
			Name "Outline_FirstPass"

			Stencil
			{
				Ref 0
				Comp Always

				Pass IncrSat
				Fail keep
				ZFail IncrSat
			}

			//ZTest off
			Cull back
			ColorMask 0
			ZWrite off
			Lighting Off
			/*
			*/
			/*	Blend SrcAlpha OneMinusSrcAlpha
				AlphaToMask On*/

			/*Blend one one
			AlphaToMask on*/
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag 
			#pragma shader_feature _USEOUTLINE_ON _USEOUTLINE_OFF
			#include "UnityCG.cginc"

			uniform float4 _OutlineColor;
			uniform float _OutlineThickness;
			uniform float _OutlineIntensity;
			uniform float _Angle;

			struct v2f
			{
				float4 pos : SV_POSITION;
			};

			v2f vert(appdata_full v)
			{
#if _USEOUTLINE_ON
				float3 scaleDir = normalize(v.vertex.xyz - float4(0, 0, 0, 1));

				if (degrees(acos(dot(scaleDir.xyz, v.normal.xyz))) > _Angle)
				{
					v.vertex.xyz += normalize(v.normal.xyz) * _OutlineThickness;
				}
				else
				{
					v.vertex.xyz += scaleDir * _OutlineThickness;
				}
#endif
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.pos = UnityObjectToClipPos(v.vertex);

				return o;
			}

			half4 frag(v2f i) : COLOR
			{
#if _USEOUTLINE_ON
				half4 col = _OutlineColor;
				col.rgb *= _OutlineIntensity;
				return col;
#else
				return half4(0, 0, 0, 0);
#endif
			}
			ENDCG
		}

		Tags{ "Queue" = "Transparent+11" }
		Pass
		{
			Name "Outline_SecondPass"

			Stencil
			{
				Ref 0
				Comp always
				Pass  DecrSat
				Fail  keep
				ZFail DecrSat
			}

			Cull front
			ColorMask 0
			//ZTest on
			ZWrite off
			Lighting Off
			/*
			*/
			//Blend SrcAlpha OneMinusSrcAlpha
			//AlphaToMask On
			/*Blend One OneMinusSrcAlpha
			AlphaToMask on
			*/
			CGPROGRAM

			#pragma shader_feature _USEOUTLINE_ON _USEOUTLINE_OFF
			#pragma vertex vert
			#pragma fragment frag 
			#include "UnityCG.cginc"

			uniform float4 _OutlineColor;
			uniform float _OutlineThickness;
			uniform float _OutlineIntensity;

			struct v2f
			{
				float4 pos : SV_POSITION;
			};

			v2f vert(appdata_full v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.pos = UnityObjectToClipPos(v.vertex);

				return o;
			}

			half4 frag(v2f i) : COLOR
			{
				return half4(0, 0, 0, 0);
			}
			ENDCG
		}

		Tags{ "Queue" = "Transparent+11" }
		Pass
		{
			Name "Outline_SecondPass_"

			Stencil
			{
				Ref 0
				Comp Always
				Pass  keep
				Fail  keep
				ZFail keep
			}

			Cull back
			ColorMask 0
			//ZTest greater
			ZWrite on
			Lighting Off
			/*
			*/
			/*Blend SrcAlpha OneMinusSrcAlpha
			*/
			//AlphaToMask On
			/*Blend One OneMinusSrcAlpha
			AlphaToMask on
			*/
			CGPROGRAM

			#pragma shader_feature _USEOUTLINE_ON _USEOUTLINE_OFF
			#pragma vertex vert
			#pragma fragment frag 
			#include "UnityCG.cginc"

			uniform float4 _OutlineColor;
			uniform float _OutlineThickness;
			uniform float _OutlineIntensity;

			struct v2f
			{
				float4 pos : SV_POSITION;
			};

			v2f vert(appdata_full v)
			{
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.pos = UnityObjectToClipPos(v.vertex);

				return o;
			}

			half4 frag(v2f i) : COLOR
			{
				return 0;
			}
			ENDCG
		}

		Tags{ "Queue" = "Transparent+13" }
		Pass
		{
			Name "Outline_FinalPass"

			Stencil
			{
				Ref 1
				Comp LEqual
				//Fail  Invert
				Pass  keep
				Fail keep
				ZFail keep
			}

			Blend SrcAlpha OneMinusSrcAlpha
			AlphaToMask On

			/*
			Blend One OneMinusSrcAlpha
			AlphaToMask On
			*/
			/*
			*/
			//ZTest LEqual
			Cull Front
			ZWrite on
			Lighting Off

			CGPROGRAM

			#pragma shader_feature _USEOUTLINE_ON _USEOUTLINE_OFF
			#pragma vertex vert
			#pragma fragment frag 
			#include "UnityCG.cginc"

			uniform float4 _OutlineColor;
			uniform float _OutlineThickness;
			uniform float _OutlineIntensity;
			uniform float3 _CenterPivot;
			uniform float _Angle;

			struct v2f
			{
				float4 pos : SV_POSITION;
			};

			v2f vert(appdata_full v)
			{
	#if _USEOUTLINE_ON
				float3 scaleDir = normalize(v.vertex.xyz - float4(0, 0, 0, 1));

				if (degrees(acos(dot(scaleDir.xyz, v.normal.xyz))) > _Angle)
				{
					v.vertex.xyz += normalize(v.normal.xyz) * _OutlineThickness;
				}
				else
				{
					v.vertex.xyz += scaleDir * _OutlineThickness;
				}
	#endif

				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.pos = UnityObjectToClipPos(v.vertex);

				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
	#if _USEOUTLINE_ON
				half4 col = _OutlineColor;
				col.rgb *= _OutlineIntensity;

				return col;
	#else
				return half4(0, 0, 0, 0);
	#endif
			}
			ENDCG
		}	

		Tags{ "Queue" = "Transparent+9" }
		Pass
		{
			Name "Hologram_Pass"

			Cull back
			//ztest always

			Blend SrcAlpha OneMinusSrcAlpha
			AlphaToMask On
			zwrite on
			Lighting off

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
					fixed4 c = tex2D(_HologramTex, i.uv) * _HologramColor;
					c.rgb = c.rgb * _HologramIntensity;
					//c.a = _HologramColor.a;
					return c;
				}
				else
				{
					return 0;
				}

#else
				return half4(0, 0, 0, 0);
#endif
			}
			ENDCG
		}

		Tags{ "Queue" = "Transparent+15" }
		Cull back

		Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask On

		CGPROGRAM

		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert alpha:blend
		#pragma shader_feature _USEHOLOGRAM_ON _USEHOLOGRAM_OFF

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		uniform float4 _SlicingPlane;

		sampler2D _MainTex;

		struct Input
		{
			float2 uv_MainTex;

			float3 fragWorldPos : TEXCOORD0;
		};

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.fragWorldPos = mul(UNITY_MATRIX_M, v.vertex);
		}

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void Slice(float4 plane, float3 fragPos)
		{
			float distance = dot(fragPos.xyz, plane.xyz) + plane.w;

			if (distance > 0)
			{
				discard;
			}
		}

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
#if _USEHOLOGRAM_ON
			Slice(_SlicingPlane, IN.fragWorldPos);

			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;


#else
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
#endif	
		}
		ENDCG
    }
}
