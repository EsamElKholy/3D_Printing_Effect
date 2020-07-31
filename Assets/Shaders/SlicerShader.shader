// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SlicerShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_CapTex ("Cap", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_SlicingPlane("Slicing Plane", Vector) = (0, 0, 0, 0)
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
			/*Blend SrcAlpha OneMinusSrcAlpha
			AlphaToMask On*/
			//ZTest Off
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
				return half4(1, 1, 1, 1);
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
			//Blend SrcAlpha OneMinusSrcAlpha 
			//AlphaToMask On
			//ZTest Off
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
				return half4(1, 1, 1, 1);
			}
			ENDCG
		}

		Tags{ "Queue" = "Geometry-2" }
		Cull Off
		/*
		*/
		/*ZTest LEqual
		ZWrite On*/
		/*Blend SrcAlpha OneMinusSrcAlpha
		AlphaToMask On*/

        CGPROGRAM

        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert alpha:blend

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

		uniform float4 _SlicingPlane;
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

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
			Slice(_SlicingPlane, IN.fragWorldPos);
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
