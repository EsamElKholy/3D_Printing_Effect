// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/SlicerShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_SlicingPlane("Slicing Plane", Vector) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

		Pass
		{
			Cull Front
			
			Blend SrcAlpha OneMinusSrcAlpha
			AlphaToMask On
			ZWrite On

			Stencil 
			{
				Ref 1
				Comp Always
				Pass Keep
				Fail Keep
				ZFail IncrSat
			}

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			uniform float4 _SlicingPlane;

			struct appdata {
				float4 vertex : POSITION;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				float3 fragWorldPos : TEXCOORD0;
			};
			v2f vert(appdata v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.fragWorldPos = mul(UNITY_MATRIX_M, v.vertex);
				return o;
			}

			void Slice(float4 plane, float3 fragPos)
			{
				float distance = dot(fragPos.xyz, plane.xyz) + plane.w;

				if (distance > 0)
				{
					discard;
				}
			}

			half4 frag(v2f i) : SV_Target 
			{
				Slice(_SlicingPlane, i.fragWorldPos);

				return half4(1,0,0,.5);
			}
			ENDCG
		}

		Pass
		{
			Cull Front

			Blend SrcAlpha OneMinusSrcAlpha
			AlphaToMask On
			ZWrite On

			Stencil
			{
				Ref 1
				Comp Always
				Pass Keep
				Fail Keep
				ZFail DecrSat
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			uniform float4 _SlicingPlane;

			struct appdata {
				float4 vertex : POSITION;
			};
			struct v2f {
				float4 pos : SV_POSITION;
				float3 fragWorldPos : TEXCOORD0;
			};
			v2f vert(appdata v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.fragWorldPos = mul(UNITY_MATRIX_M, v.vertex);
				return o;
			}

			void Slice(float4 plane, float3 fragPos)
			{
				float distance = dot(fragPos.xyz, plane.xyz) + plane.w;

				if (distance > 0)
				{
					discard;
				}
			}

			half4 frag(v2f i) : SV_Target 
			{
				Slice(_SlicingPlane, i.fragWorldPos);

				return half4(1,0,0,.5);
			}
			ENDCG
		}

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

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

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

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
