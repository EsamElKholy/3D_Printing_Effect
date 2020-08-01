﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SlicerShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_CapTex ("Cap", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_SlicingPlane("Slicing Plane", Vector) = (0, 0, 0, 0)
		[Toggle(USE_RING)] _UseGlowingRing("Use Glowing Ring", Float) = 0
		_GlowingRingColor("Glowing Ring Color", Color) = (1, 1, 1, 1)
		_GlowingRingThickness("Glowing Ring Thickness", Float) = 0
		_GlowingRingIntensity("Glowing Ring Intensity", Float) = 1
		[Toggle(USE_HOLOGRAM)] _UseHologram("Use Hologram", Float) = 0
		_HologramColor("Hologram Color", Color) = (1, 1, 1, 0)
		_HologramIntensity("Hologram Intensity", Float) = 1
		_HologramTex("Hologram Texture", 2D) = "white" {}
	}
    SubShader
    {
		Stencil
		{
			Ref 0
			Comp Always
		}

		Pass
		{			
			Tags { "Queue" = "Geometry-3" }
			Stencil
			{
				
				Pass IncrSat
				Fail Keep
				ZFail Keep
			}
			Cull Front
			ColorMask 0
			ZWrite On			

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			uniform float4 _SlicingPlane;
			uniform sampler2D _CapTex;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			struct v2f 
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 fragWorldPos : TEXCOORD1;
			};
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.fragWorldPos = mul(UNITY_MATRIX_M, v.vertex);
				o.uv = v.uv;
				return o;
			}

			void Slice(float4 plane, float3 fragPos, float2 uv)
			{
				float distance = dot(fragPos.xyz, plane.xyz) + plane.w;

				if (distance > 0)
				{
					discard;
					//return fixed4(0, 0, 0, 0);
				}				
			}

			half4 frag(v2f i) : SV_Target
			{
				Slice(_SlicingPlane, i.fragWorldPos, i.uv);
				return half4(0, 0, 0, 0);
			}
			ENDCG
		}	

		Pass
		{
			Tags { "Queue" = "Geometry-4" }
			Stencil
			{
				Pass DecrSat
				Fail Keep
				ZFail Keep
			}
			Cull Back
			ColorMask 0
			ZWrite On

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			uniform float4 _SlicingPlane;
			uniform sampler2D _CapTex;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 fragWorldPos : TEXCOORD1;
			};
			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.fragWorldPos = mul(UNITY_MATRIX_M, v.vertex);
				o.uv = v.uv;
				return o;
			}

			void Slice(float4 plane, float3 fragPos, float2 uv)
			{
				float distance = dot(fragPos.xyz, plane.xyz) + plane.w;

				if (distance > 0)
				{
					discard;
					//return fixed4(0, 0, 0, 0);
				}
			}

			half4 frag(v2f i) : SV_Target
			{
				Slice(_SlicingPlane, i.fragWorldPos, i.uv);
				return half4(0, 0, 0, 0);
			}
			ENDCG
		}

		Tags{ "Queue" = "Transparent-2" }
		Cull Off
		
        CGPROGRAM

        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert alpha:blend
		#pragma shader_feature USE_RING

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

		uniform float4 _SlicingPlane;
		uniform float4 _GlowingRingColor;
		uniform float _GlowingRingThickness;
		uniform float _GlowingRingIntensity;

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;

			float3 fragWorldPos : TEXCOORD0;
        };

		void vert(inout appdata_full v, out Input o) {
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

		float DrawEmissionRing(float4 plane, float3 fragPos, float4 glowingRingColor, float glowingRingThickness)
		{
			//float distance1 = dot(fragPos.xyz, plane.xyz) + plane.w;
			float distance1 = dot(fragPos.xyz, plane.xyz) + plane.w + glowingRingThickness;

			if (distance1 > 0)
			{
				return 1;
			}

			return 0;
		}

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
			Slice(_SlicingPlane, IN.fragWorldPos);
#if USE_RING
			float em = DrawEmissionRing(_SlicingPlane, IN.fragWorldPos, _GlowingRingColor, _GlowingRingThickness);
			
			if (em > 0)
			{
				//o.Emission = _GlowingRingColor.rgb * 100;
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = _GlowingRingColor.rgb * _GlowingRingIntensity;
				// Metallic and smoothness come from slider variables
				/*o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;*/
				o.Alpha = c.a;
			}
			else 
			{
				o.Emission = (0, 0, 0, 0);
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
				// Metallic and smoothness come from slider variables
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Alpha = c.a;
			}
#else
			o.Emission = (0, 0, 0, 0);
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
#endif
          
        }
        ENDCG

		Cull Back
		CGPROGRAM

			// Physically based Standard lighting model, and enable shadows on all light types
#pragma surface surf Standard fullforwardshadows vertex:vert alpha:blend
#pragma shader_feature USE_HOLOGRAM

// Use shader model 3.0 target, to get nicer looking lighting
#pragma target 3.0
#include "UnityCG.cginc"

		uniform float4 _SlicingPlane;
		uniform float4 _HologramColor;
		uniform float _HologramIntensity;
		uniform sampler2D _HologramTex;

		sampler2D _MainTex;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_HologramTex;

			float3 fragWorldPos : TEXCOORD1;
		};

		void vert(inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.fragWorldPos = mul(UNITY_MATRIX_M, v.vertex);
		}

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		float Slice(float4 plane, float3 fragPos)
		{
			float distance = dot(fragPos.xyz, plane.xyz) + plane.w;

			if (distance > 0)
			{
				return 1;
			}

			return 0;
		}
		
		void surf(Input IN, inout SurfaceOutputStandard o)
		{
#if USE_HOLOGRAM
			float em = Slice(_SlicingPlane, IN.fragWorldPos);			

			if (em > 0)
			{
				fixed4 c = tex2D(_HologramTex, IN.uv_HologramTex) * _HologramColor;
				o.Albedo = c.rgb * _HologramIntensity;				
				o.Alpha = c.a;
			}
			
#else
			o.Emission = (0, 0, 0);
			o.Albedo = (0, 0, 0);			
			o.Alpha = 0;
#endif

		}
		ENDCG
    }
    FallBack "Diffuse"
}
