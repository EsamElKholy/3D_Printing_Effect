Shader "Custom/OutlineShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_SceneTex("Scene Texture",2D) = "black"{} 
	}
    SubShader
    {	
		Pass
        {
			Blend SrcAlpha OneMinusSrcAlpha
            
			CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

			uniform sampler2D _SceneTex;
            sampler2D _MainTex;
            float4 _MainTex_ST;
			float2 _MainTex_TexelSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = o.vertex.xy / 2 + 0.5;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				int iterationsCount = 9;
				
				float TX_x = _MainTex_TexelSize.x;
				float TX_y = _MainTex_TexelSize.y;

				float colorIntensityInRadius = 0;
				half4 scene = tex2D(_SceneTex, i.uv.xy);

				if (tex2D(_MainTex, i.uv.xy).r > 0)
				{
					return tex2D(_SceneTex, float2(i.uv.x, i.uv.y));
				}

				for (int k = 0; k < iterationsCount; k++)
				{
					for (int j = 0; j < iterationsCount; j++)
					{
						colorIntensityInRadius += tex2D(_MainTex, i.uv.xy + float2((k - iterationsCount / 2) * TX_x, (j - iterationsCount / 2) * TX_y)).r;
					}
				}
				//scene = (1 - colorIntensityInRadius) * scene;
				fixed4 col = fixed4(0, 1, 1, 1);
				col.rgb *= colorIntensityInRadius;
				fixed4 col2 = tex2D(_SceneTex, float2(i.uv.x, i.uv.y));
				col2.rgb *= (1 - colorIntensityInRadius);

                return col + col2;
            }
            ENDCG
        }
    }
}
