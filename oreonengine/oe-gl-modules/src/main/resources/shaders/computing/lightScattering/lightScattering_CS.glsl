#version 430 core

layout (local_size_x = 8, local_size_y = 8) in;

layout (binding = 0, rgba16f) uniform readonly image2D blackSceneSampler;

layout (binding = 1, rgba16f) uniform writeonly image2D lightScatteringSampler;

uniform mat4 viewProjectionMatrix;
uniform float windowWidth;
uniform float windowHeight;
uniform vec3 sunWorldPosition;

const int NUM_SAMPLES = 200;
const float density = 1.2;
const float decay = 0.975;
const float exposure = 0.25;
const float weight = 1.0;

void main(void){

	ivec2 computeCoord = ivec2(gl_GlobalInvocationID.x, gl_GlobalInvocationID.y);
	vec2 coord = vec2(computeCoord.x, computeCoord.y);
	
	vec4 sunClipSpacePos = viewProjectionMatrix * vec4(sunWorldPosition,1.0);
	vec3 sunNdcSpacePos = sunClipSpacePos.xyz / sunClipSpacePos.w;
	vec2 sunWindowSpacePos = ((sunNdcSpacePos.xy + 1.0) / 2.0) * vec2(windowWidth,windowHeight);
	
	vec2 deltaCoord = computeCoord - sunWindowSpacePos;
	deltaCoord *= 1.0 /  float(NUM_SAMPLES) * density;

	float illuminationDecay = 1.0;

	vec3 finalColor = vec3(0,0,0);
	
	float alpha = imageLoad(blackSceneSampler, computeCoord).a;
	
	// alpha = 0 to prevent scattering on atmosphere
	if (alpha > 0.0){
		for(int i=0; i < NUM_SAMPLES ; i++)
		{
			coord -= deltaCoord;
			vec3 color = imageLoad(blackSceneSampler, ivec2(coord.x,coord.y)).rgb;

			// if (imageLoad(blackSceneSampler, ivec2(coord.x,coord.y)).a > 0.0){
				color *= illuminationDecay * weight;

				finalColor += color;

			// }
			illuminationDecay *= decay;
		}
		finalColor *= exposure;
	}
	
	imageStore(lightScatteringSampler, computeCoord, vec4(finalColor, 1.0));
}