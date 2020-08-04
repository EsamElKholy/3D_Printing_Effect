Shader "Custom/OutlineShader"
{
    Properties
    {
		[Toggle(USE_OUTLINE)] _UseOutline("Use Outline", Float) = 0
		_OutlineColor("Outline Color", Color) = (1, 1, 1, 1)
		_OutlineThickness("Outline Thickness", Range(0, 1)) = 0.01
		_OutlineIntensity("Outline Intensity", Float) = 1
		_Angle("Switch shader on angle", Range(0.0, 180)) = 89
	}
    SubShader
    {	
		/*
		Outline pass
		*/

		Pass
		{
			//Name "Outline_FirstPass"

			Tags{ "Queue" = "Transparent+12" }
			
			Stencil
			{
				Ref 0
				Comp Always

				Pass IncrSat
				Fail IncrSat
				ZFail IncrSat
			}

			Cull off
			ColorMask 0
			ZWrite off
			Lighting Off

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag 
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
				//v.vertex.xyz += normalize(v.normal.xyz) * _OutlineThickness;
				//v.vertex.xyz *= _OutlineThickness;			

				float3 scaleDir = normalize(v.vertex.xyz - float4(0, 0, 0, 1));

				if (degrees(acos(dot(scaleDir.xyz, v.normal.xyz))) > _Angle)
				{
					v.vertex.xyz += normalize(v.normal.xyz) * _OutlineThickness;
				}
				else
				{
					v.vertex.xyz += scaleDir * _OutlineThickness;
				}

				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o); 
				o.pos = UnityObjectToClipPos(v.vertex);

				return o;
			}

			half4 frag(v2f i) : COLOR
			{
				return half4(1, 1, 1, 1);
			}
			ENDCG
		}

		Pass
		{
			//Name "Outline_SecondPass"

			Tags{ "Queue" = "Transparent+9" }

			Stencil
			{
				Ref 0
				Comp Always

				Pass IncrSat
				Fail IncrSat
				ZFail IncrSat
			}

			Cull off
			ColorMask 0
			//ZTest Always
			ZWrite on
			Lighting Off

			CGPROGRAM

			#pragma shader_feature USE_OUTLINE
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
				return half4(1, 1, 1, 1);
			}
			ENDCG
		}

		Pass
		{
			//Name "Outline_FinalPass"
			Tags{ "Queue" = "Transparent+11" }

			Stencil
			{
				Ref 1
				Comp LEqual
				Fail keep
			}	

			Cull front
			//ZTest LEqual
			ZWrite on
			/*Blend SrcAlpha OneMinusSrcAlpha
			AlphaToMask off*/
			Lighting Off

			CGPROGRAM

			#pragma shader_feature USE_OUTLINE
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
				//v.vertex.xyz *= _OutlineThickness;
				
				//v.vertex.xyz += normalize(v.normal.xyz) * _OutlineThickness;
				
				float3 scaleDir = normalize(v.vertex.xyz - float4(0, 0, 0, 1));

				if (degrees(acos(dot(scaleDir.xyz, v.normal.xyz))) > _Angle)
				{
					v.vertex.xyz += normalize(v.normal.xyz) * _OutlineThickness;
				}
				else
				{
					v.vertex.xyz += scaleDir * _OutlineThickness;
				}

				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.pos = UnityObjectToClipPos(v.vertex);

				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
#if USE_OUTLINE
				half4 col = _OutlineColor;
				col.rgb *= _OutlineIntensity;
				//return half4(1, 1, 1, 1);
				return col;
#else
				return half4(1, 1, 1, 1);
#endif
			}
			ENDCG
		}

		Pass
		{
			//Name "Outline_FinalPass"
			Tags{ "Queue" = "Transparent+17" }			

			Cull back
			//ZTest LEqual
			ZWrite on
			Blend SrcAlpha OneMinusSrcAlpha
			AlphaToMask off
			Lighting Off

			CGPROGRAM

			#pragma shader_feature USE_OUTLINE
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

			float4 Outline(float4 pos, float3 normal, float width)
			{
				float4x4 scaleMat;

				scaleMat[0][0] = 1;
				scaleMat[0][1] = 0;
				scaleMat[0][2] = 0;
				scaleMat[0][3] = normal.x * width;

				scaleMat[1][0] = 0;
				scaleMat[1][1] = 1;
				scaleMat[1][2] = 0;
				scaleMat[1][3] = normal.y * width;

				scaleMat[2][0] = 0;
				scaleMat[2][1] = 0;
				scaleMat[2][2] = 1;
				scaleMat[2][3] = normal.z * width;

				scaleMat[3][0] = 0;
				scaleMat[3][1] = 0;
				scaleMat[3][2] = 0;
				scaleMat[3][3] = 1;
				pos.xyz *= width;

				return pos;
			}

			v2f vert(appdata_full v)
			{
				//v.vertex.xyz = v.vertex.xyz + v.normal * _OutlineThickness;
				//v.vertex.xyz *= _OutlineThickness;
				v2f o;
				UNITY_INITIALIZE_OUTPUT(v2f, o);
				o.pos = UnityObjectToClipPos(v.vertex);

				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
#if USE_OUTLINE
				half4 col = _OutlineColor;
				col.rgb *= _OutlineIntensity;
				return half4(0, 1, 1, 1);
				//return col;
#else
				return half4(1, 1, 1, 1);
#endif
			}
			ENDCG
		}
    }
}
