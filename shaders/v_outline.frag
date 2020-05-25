extern float _mod;
extern float _lt;
extern float _off;

float when_gt(float x, float y) {
  return max(sign(x - y), 0.0);
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec4 pixel = Texel(texture, screen_coords );
	return vec4(pixel.r * color.r, pixel.g * color.g, pixel.b * color.b, pixel.a * color.a * when_gt(mod(screen_coords.y+_off,_mod),_lt));
}