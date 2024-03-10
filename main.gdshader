//---CRT Shader---
shader_type canvas_item;

uniform float scanline_count : hint_range(0, 1800) = 1000;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

vec2 uv_curve(vec2 uv)
{
	/*uv = (uv - 0.5) * 2.0;
	
	//You can modify the numbers and try different values
	uv.x *= 1.0 + pow(abs(uv.x), 2.0);
	uv.y *= 1.0 + pow(abs(uv.y), 2.0);
	
	//The scale part (you can delete it when you want)
	uv /= 1.1;
	
	uv = (uv/2.0) + 0.5;*/
	return uv;
}


void fragment()
{	
	
	//You can modify the *3.0, *-3.0 for a bigger or smaller 
	float r = texture(screen_texture, uv_curve(SCREEN_UV) + vec2(SCREEN_PIXEL_SIZE.x*0.0), 0.0).r;
	float g = texture(screen_texture, uv_curve(SCREEN_UV) + vec2(SCREEN_PIXEL_SIZE.x*3.0), 0.0).g;
	float b = texture(screen_texture, uv_curve(SCREEN_UV) + vec2(SCREEN_PIXEL_SIZE.x*-3.0), 0.0).b;
	
	
	//If you dont want scanlines you can just delete this part
	float s = sin(uv_curve(SCREEN_UV).y * scanline_count * PI * 2.0);
	s = (s * 0.5 + 0.5) * 0.9 + 0.1;
	vec4 scan_line = vec4(vec3(pow(s, 0.25)), 1.0);
	
	
	COLOR = vec4(r, g*2.0, b, 1.0) * scan_line;
}
