#version 430 core

layout (local_size_x = 16, local_size_y = 16) in;

layout (binding = 0, rgba16f) uniform writeonly image2D defferedSceneSampler;

layout (binding = 1, rgba8) uniform readonly image2D albedoSceneSampler;

layout (binding = 2, rgba32f) uniform readonly image2D worldPositionSampler;

layout (binding = 3, rgba32f) uniform readonly image2D normalSampler;

layout (binding = 4, rgba8) uniform readonly image2D specularEmissionSampler;

layout (std140, row_major) uniform Camera{
	vec3 eyePosition;
	mat4 m_View;
	mat4 m_ViewProjection;
	vec4 frustumPlanes[6];
};

layout (std140) uniform DirectionalLight{
	vec3 direction;
	float intensity;
	vec3 ambient;
	vec3 color;
} directional_light;

layout (std140, row_major) uniform LightViewProjections{
	mat4 m_lightViewProjection[6];
	float splitRange[6];
};

float diffuse(vec3 direction, vec3 normal, float intensity)
{
	return max(0.0, dot(normal, -direction) * intensity);
}

float specular(vec3 direction, vec3 normal, vec3 eyePosition, vec3 vertexPosition, float specularFactor, float emissionFactor)
{
	vec3 reflectionVector = normalize(reflect(direction, normal));
	vec3 vertexToEye = normalize(eyePosition - vertexPosition);
	
	float specular = max(0.0, dot(vertexToEye, reflectionVector));
	
	return pow(specular, specularFactor) * emissionFactor;
}

void main(void){

	ivec2 computeCoord = ivec2(gl_GlobalInvocationID.x, gl_GlobalInvocationID.y);
	
	vec3 albedo = imageLoad(albedoSceneSampler, computeCoord).rgb; 
	vec3 position = imageLoad(worldPositionSampler, computeCoord).rgb;
	vec3 normal = imageLoad(normalSampler, computeCoord).rbg;
	vec2 specular_emission = imageLoad(specularEmissionSampler, computeCoord).rg;
	
	vec3 finalColor = albedo;
	
	// prevent lighting sky
	if (imageLoad(normalSampler, computeCoord).a != 0.0){
	
		float diff = diffuse(directional_light.direction, normal, directional_light.intensity);
		float spec = specular(directional_light.direction, normal, eyePosition, position, specular_emission.r, specular_emission.g);

		vec3 diffuseLight = directional_light.ambient + directional_light.color * diff;
		vec3 specularLight = directional_light.color * spec;

		finalColor = albedo * diffuseLight + specularLight;
	}
		
	imageStore(defferedSceneSampler, computeCoord, vec4(finalColor,1.0));
}