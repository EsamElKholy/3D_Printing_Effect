Shader "Custom/CapsShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
	}
    SubShader
    {
		Tags { "RenderType" = "Geometry" "Queue" = "Geometry-1" }
		Stencil
		{
			Ref 1
			Comp Equal
		}
		Pass
		{
			ZTest LEqual
			ZWrite On
			Blend SrcAlpha OneMinusSrcAlpha
			AlphaToMask off
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
				col.rgb *= 3;
				return col;// (0, 0, 1, 1);
			}
			ENDCG
		}
    }
}
