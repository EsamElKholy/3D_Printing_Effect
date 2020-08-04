#ifndef SLICING_PASS
#define SLICING_PASS

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
		}
	}

	half4 frag(v2f i) : SV_Target
	{
		Slice(_SlicingPlane, i.fragWorldPos, i.uv);
		return half4(0, 0, 0, 0);
	}
	ENDCG
}

#endif