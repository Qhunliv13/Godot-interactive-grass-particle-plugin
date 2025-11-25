shader_type canvas_item;

uniform sampler2D spritesheet;
uniform sampler2D random_noise;

uniform int frames = 4;
uniform vec4 top_color : source_color = vec4(0.2, 0.8, 0.0, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.15, 0.6, 0.0, 1.0);

uniform vec2 player_pos = vec2(0.0);
uniform float player_radius = 20.0;
uniform float player_radius_blend = 10.0;

uniform float wind_time = 0.0;
uniform float wind_strength = 0.25;
uniform float wind_frequency = 0.03;
uniform vec2 wind_direction = vec2(1.0, 0.0);

uniform float grass_size = 1.0;

uniform float distribution_frequency = 0.1;
uniform float distribution_threshold = 0.5;

vec3 mod289(vec3 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
	return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r) {
	return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(vec3 v) {
	const vec2 C = vec2(1.0/6.0, 1.0/3.0);
	const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);
	
	vec3 i = floor(v + dot(v, C.yyy));
	vec3 x0 = v - i + dot(i, C.xxx);
	
	vec3 g = step(x0.yzx, x0.xyz);
	vec3 l = 1.0 - g;
	vec3 i1 = min(g.xyz, l.zxy);
	vec3 i2 = max(g.xyz, l.zxy);
	
	vec3 x1 = x0 - i1 + C.xxx;
	vec3 x2 = x0 - i2 + C.yyy;
	vec3 x3 = x0 - D.yyy;
	
	i = mod289(i);
	vec4 p = permute(permute(permute(
		i.z + vec4(0.0, i1.z, i2.z, 1.0))
		+ i.y + vec4(0.0, i1.y, i2.y, 1.0))
		+ i.x + vec4(0.0, i1.x, i2.x, 1.0));
	
	float n_ = 0.142857142857;
	vec3 ns = n_ * D.wyz - D.xzx;
	
	vec4 j = p - 49.0 * floor(p * ns.z * ns.z);
	
	vec4 x_ = floor(j * ns.z);
	vec4 y_ = floor(j - 7.0 * x_);
	
	vec4 x = x_ *ns.x + ns.yyyy;
	vec4 y = y_ *ns.x + ns.yyyy;
	vec4 h = 1.0 - abs(x) - abs(y);
	
	vec4 b0 = vec4(x.xy, y.xy);
	vec4 b1 = vec4(x.zw, y.zw);
	
	vec4 s0 = floor(b0)*2.0 + 1.0;
	vec4 s1 = floor(b1)*2.0 + 1.0;
	vec4 sh = -step(h, vec4(0.0));
	
	vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy;
	vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww;
	
	vec3 p0 = vec3(a0.xy, h.x);
	vec3 p1 = vec3(a0.zw, h.y);
	vec3 p2 = vec3(a1.xy, h.z);
	vec3 p3 = vec3(a1.zw, h.w);
	
	vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;
	
	vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
	m = m * m;
	return 42.0 * dot(m*m, vec4(dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3)));
}

vec2 rotateUV(vec2 uv, float rotation, vec2 mid){
	float cosAngle = cos(rotation);
	float sinAngle = sin(rotation);
	return vec2(
		cosAngle * (uv.x - mid.x) + sinAngle * (uv.y - mid.y) + mid.x,
		cosAngle * (uv.y - mid.y) - sinAngle * (uv.x - mid.x) + mid.y
	);
}

varying vec2 world_pos;
varying float player_mask;
varying float distribution_mask;
void vertex(){
	world_pos = INSTANCE_CUSTOM.xy;
	
	vec3 dist_coord = vec3(world_pos * distribution_frequency, 0.0);
	float dist_noise = snoise(dist_coord);
	dist_noise = dist_noise * 0.5 + 0.5;
	distribution_mask = step(dist_noise, distribution_threshold);
	
	float player_distance = distance(world_pos, player_pos);
	float pm = smoothstep(player_radius, player_radius + player_radius_blend, player_distance);
	player_mask = pm;
	vec2 pd = normalize(world_pos - player_pos);
	vec2 vup = vec2(0.0, 1.0);
	float signed_angle = atan(vup.x*pd.y - vup.y*pd.x, vup.x*pd.x + vup.y*pd.y);
	
	float player_rotation = signed_angle * (1.0 - pm);
	
	vec3 wind_coord = vec3(world_pos * wind_frequency + wind_direction * wind_time * 0.3, wind_time * 0.15);
	float wind_noise = snoise(wind_coord);
	float wind_rotation = wind_noise * wind_strength * (0.5 + 0.5 * pm);
	
	float rotation = player_rotation + wind_rotation;
	VERTEX = rotateUV(VERTEX, rotation, vec2(0.0));
	VERTEX *= grass_size;
}

void fragment(){
	vec2 rand_uv = world_pos;
	vec2 rand_tex_size = vec2(textureSize(random_noise, 0));
	rand_uv.x = mod(rand_uv.x, rand_tex_size.x);
	rand_uv.y = mod(rand_uv.y, rand_tex_size.y);
	float rand = texelFetch(random_noise, ivec2(rand_uv), 0).r;
	float ff = float(frames);
	rand = round(rand * ff);
	
	float frame_number = rand;
	float fr = 1.0 / float(max(frames, 1));
	float x_coord = mix(fr * frame_number, fr * frame_number + fr, UV.x);
	vec2 midpoint = vec2(fr * frame_number + fr * 0.5, 0.5);
	vec2 uv = vec2(x_coord, UV.y);
	
	vec4 tex_col = texture(spritesheet, uv);
	vec3 color = mix(top_color.rgb, bottom_color.rgb, UV.y);
	color *= tex_col.rgb;
	
	COLOR = vec4(color, tex_col.a * player_mask * distribution_mask);
}

