
/*The MIT License (MIT)

* Copyright (c) 2015 dsoft20
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/

//https://github.com/dsoft20/psx_retroshader


// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "psx/vertexlit" {
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			Pass {
			Lighting On
				CGPROGRAM

					#pragma vertex vert
					#pragma fragment frag
					#include "UnityCG.cginc"

					struct v2f
					{
						fixed4 pos : SV_POSITION;
						half4 color : COLOR0;
						half4 colorFog : COLOR1;
						float2 uv_MainTex : TEXCOORD0;
						half3 normal : TEXCOORD1;
					};

					float4 _MainTex_ST;
					uniform half4 unity_FogStart;
					uniform half4 unity_FogEnd;

					v2f vert(appdata_full v)
					{
						v2f o;

						//Vertex snapping
						float4 snapToPixel = UnityObjectToClipPos(v.vertex);
						float4 vertex = snapToPixel;
						vertex.xyz = snapToPixel.xyz / snapToPixel.w;
						vertex.x = floor(160 * vertex.x) / 160;
						vertex.y = floor(120 * vertex.y) / 120;
						vertex.xyz *= snapToPixel.w;
						o.pos = vertex;

						//Vertex lighting 
					//	o.color =  float4(ShadeVertexLights(v.vertex, v.normal), 1.0);
						o.color = float4(ShadeVertexLightsFull(v.vertex, v.normal, 4, true), 1.0);
						o.color *= v.color;

						float distance = length(mul(UNITY_MATRIX_MV,v.vertex));

						//Affine Texture Mapping
						float4 affinePos = vertex; //vertex;				
						o.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
						o.uv_MainTex *= distance + (vertex.w * (UNITY_LIGHTMODEL_AMBIENT.a * 8)) / distance / 2;
						o.normal = distance + (vertex.w * (UNITY_LIGHTMODEL_AMBIENT.a * 8)) / distance / 2;

						//Fog
						float4 fogColor = unity_FogColor;

						float fogDensity = (unity_FogEnd - distance) / (unity_FogEnd - unity_FogStart);
						o.normal.g = fogDensity;
						o.normal.b = 1;

						o.colorFog = fogColor;
						o.colorFog.a = clamp(fogDensity,0,1);

						//Cut out polygons
						if (distance > unity_FogStart.z + unity_FogColor.a * 255)
						{
							o.pos.w = 0;
						}

						return o;
					}

					sampler2D _MainTex;

					float4 frag(v2f IN) : COLOR
					{
						half4 c = tex2D(_MainTex, IN.uv_MainTex / IN.normal.r) * IN.color;
						half4 color = c * (IN.colorFog.a);
						color.rgb += IN.colorFog.rgb * (1 - IN.colorFog.a);
						return color;
					}
				ENDCG
			}
	}
}
