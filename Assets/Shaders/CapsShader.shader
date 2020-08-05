Shader "Custom/CapsShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_Intensity("Intensity", Float) = 1
	}
    SubShader
    {
		Tags { "Queue" = "Transparent+8" }
		Pass
		{			
			Stencil
			{
				Ref 1
				Comp LEqual
			}
			Cull off
			ZTest LEqual
			ZWrite on
			//Blend One OneMinusSrcAlpha
			AlphaToMask on
			//Tags { "Queue" = "Geometry+3" }
		/*	ColorMask RGB
			*/

			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			uniform float4 _Color;
			uniform float _Intensity;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = /*tex2D(_MainTex, i.uv) **/ _Color;
				col.rgb *= _Intensity;
				return col;// (0, 0, 1, 1);
			}
			ENDCG
		}
    }
}
