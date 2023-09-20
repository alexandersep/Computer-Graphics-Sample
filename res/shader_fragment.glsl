#version 330 core
out vec4 FragColor;

in vec2 TexCoord;

uniform float mixVal;

// texture samplers
uniform sampler2D tex1;
uniform sampler2D tex2;

void main() {
	// linearly interpolate between both textures (80% container, 20% awesomeface)
	FragColor = mix(texture(tex1, TexCoord), texture(tex2, vec2(1.0 - TexCoord.x, TexCoord.y)), mixVal);
}

