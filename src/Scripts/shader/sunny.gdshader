shader_type canvas_item;

uniform vec4 ray_color : source_color = vec4(1.0, 0.96, 0.82, 1.0);

uniform int ray_count : hint_range(1, 8) = 5;
uniform float ray_width : hint_range(0.01, 0.20) = 0.05;
uniform float softness : hint_range(0.001, 0.10) = 0.03;

uniform float angle = -0.55;
uniform float speed = 0.01;

uniform float intensity : hint_range(0.0, 0.3) = 0.10;

float hash(float n){
    return fract(sin(n * 127.1) * 43758.5453);
}

void fragment()
{
    vec2 uv = UV;

    // Rotate UVs so beams are diagonal
    float c = cos(angle);
    float s = sin(angle);
    vec2 p = uv - vec2(0.5);

uv.x = p.x * c - p.y * s;
uv.y = p.x * s + p.y * c;

    float rays = 0.0;

    for(int i = 0; i < 8; i++)
    {
        if(i >= ray_count)
            break;

        float fi = float(i);

        float x = mix(-0.35,0.35,(fi+0.5)/float(ray_count));

        // slow drifting
        x += sin(TIME * speed + fi * 3.7) * 0.02;

        float d = abs(uv.x - x);

        float beam = smoothstep(ray_width + softness, ray_width, d);

        // fade toward bottom
        beam *= smoothstep(0.7,-0.3,uv.y);

        rays += beam;
    }

    rays = clamp(rays,0.0,1.0);

    COLOR = vec4(ray_color.rgb, rays * intensity);
}