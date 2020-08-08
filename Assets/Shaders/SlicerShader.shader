// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SlicerShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0

		_SlicingPlane("Slicing Plane", Vector) = (0, 0, 0, 0)
		_CapTex ("Cap", 2D) = "white" {}

		[KeywordEnum(Off, On)] _UseGlowingRing("Use Glowing Ring", Float) = 0
		_GlowingRingColor("Glowing Ring Color", Color) = (1, 1, 1, 1)
		_GlowingRingThickness("Glowing Ring Thickness", Float) = 0
		_GlowingRingIntensity("Glowing Ring Intensity", Float) = 1			
	}
    SubShader
    {		
		Tags { "Queue" = "Geometry-9" }
	
		Pass
		{	
			Name "Slicer_Stencil_FirstPass"	

			Stencil
			{
				Ref 64
				WriteMask 64

				CompBack Always
				PassBack replace

				CompFront Always
				PassFront zero
			}
			
			//AlphaToMask on
			Cull back
			ColorMask 0
			ZWrite On
			//ZTest off

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
				}				
			}

			half4 frag(v2f i) : SV_Target
			{
				Slice(_SlicingPlane, i.fragWorldPos, i.uv);
				return 1;
			}
			ENDCG
		}	

		Tags { "Queue" = "Geometry-10" }
		Pass
		{
			Name "Slicer_Stencil_SecondPass"			
			Stencil
			{
				Ref 64
				WriteMask 64

				CompBack Always
				PassBack replace

				CompFront Always
				PassFront zero				
			}

			Cull Front
			ColorMask 0
			ZWrite on
			AlphaToMask on
			//ZTest on
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
				}
			}

			half4 frag(v2f i) : SV_Target
			{
				Slice(_SlicingPlane, i.fragWorldPos, i.uv);
				return half4(1, 1, 1, 1);
			}
			ENDCG
		}

		/*
		Main pass
		*/

		Name "Slicer_MainPass"

		Tags{ "Queue" = "Transparent+22" }
		//Cull Off
		//AlphaToMask on

        CGPROGRAM

        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert alpha:blend
		#pragma shader_feature _USEGLOWINGRING_ON _USEGLOWINGRING_OFF

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

		float DrawEmissionRing(float4 plane, float3 fragPos, float4 glowingRingColor, float glowingRingThickness)
		{
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
#if _USEGLOWINGRING_ON
			float em = DrawEmissionRing(_SlicingPlane, IN.fragWorldPos, _GlowingRingColor, _GlowingRingThickness);
			
			if (em > 0)
			{
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = _GlowingRingColor.rgb * _GlowingRingIntensity;
				
				o.Alpha = c.a;
			}
			else 
			{
				o.Emission = (0, 0, 0, 0);
				fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
				o.Albedo = c.rgb;
				o.Metallic = _Metallic;
				o.Smoothness = _Glossiness;
				o.Alpha = c.a;
			}
#else
			o.Emission = (0, 0, 0, 0);
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
#endif
          
        }
        ENDCG		
    }
    FallBack "Diffuse"
}
