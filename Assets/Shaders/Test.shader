Shader "Custom/Test"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_CenterPivot("Center Pivot", Vector) = (0, 0, 0, 0)
		_Angle("Switch shader on angle", Range(0.0, 180)) = 89 
		_OutlineThickness("Outline Thickness", Range(0, 1)) = 0.01
	}
    SubShader
    {
		Tags{ "Queue" = "Geometry" }
		Cull back
		ZWrite on
		ZTest LEqual

		CGPROGRAM

		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert alpha:blend
		#pragma shader_feature USE_RING

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0
		
		sampler2D _MainTex;
		uniform float4 _CenterPivot;
		uniform float _Angle;
		uniform float _OutlineThickness;

		struct Input
		{
			float2 uv_MainTex;
			float4 pos : SV_POSITION;
		};

		void vert(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			/*float3 dir = v.vertex.xyz - _CenterPivot.xyz;
			dir = normalize(dir);
			v.vertex.xyz = v.vertex.xyz + dir;*/
			float3 scaleDir = normalize(v.vertex.xyz - float4(0, 0, 0, 1));
				
			if (degrees(acos(dot(scaleDir.xyz, v.normal.xyz))) > _Angle) 
			{
				v.vertex.xyz += normalize(v.normal.xyz) * _OutlineThickness;
			}
			else 
			{
				v.vertex.xyz += scaleDir * _OutlineThickness;
			}
			//v.vertex.xyz = v.vertex.xyz + normalize(v.normal.xyz)*.5;
			o.pos = UnityObjectToClipPos(v.vertex); 
		}

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;			

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			// Albedo comes from a texture tinted by color
				
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
    }
    FallBack "Diffuse"
}
