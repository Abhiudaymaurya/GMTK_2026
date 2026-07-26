shader_type canvas_item;

// Party Pop! 🎉

const int COUNT = 100;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float explosion_radius = 900.0;
uniform float gravity = 350.0;

uniform vec2 resolution = vec2(1920.0,1080.0);

uniform float piece_size = 8.0;

uniform vec4 col0 : source_color = vec4(1.0,0.2,0.2,1.0);
uniform vec4 col1 : source_color = vec4(1.0,0.8,0.2,1.0);
uniform vec4 col2 : source_color = vec4(0.2,1.0,0.3,1.0);
uniform vec4 col3 : source_color = vec4(0.2,0.6,1.0,1.0);
uniform vec4 col4 : source_color = vec4(1.0,0.2,1.0,1.0);
uniform vec4 col5 : source_color = vec4(1.0,0.5,0.8,1.0);

float rand(float x){
    return fract(sin(x*91.17)*43758.5453);
}

vec4 palette(float t){
    int i = int(t*6.0);

    if(i==0) return col0;
    if(i==1) return col1;
    if(i==2) return col2;
    if(i==3) return col3;
    if(i==4) return col4;
    return col5;
}

vec2 rotate(vec2 p,float a){
    float s=sin(a);
    float c=cos(a);
    return vec2(
        c*p.x-s*p.y,
        s*p.x+c*p.y
    );
}

void fragment(){

    vec2 pixel = UV*resolution;

    vec2 center = resolution*0.5;

    vec4 out_col=vec4(0.0);

    for(int i=0;i<COUNT;i++){

        float fi=float(i);

        float angle=rand(fi)*TAU;

        float speed=(0.4+rand(fi*2.3))*explosion_radius;

        vec2 dir=vec2(cos(angle),sin(angle));

        vec2 pos=center;

        pos += dir*speed*progress;

        pos.y += gravity*progress*progress;

        float rot = progress*8.0 + fi;

        vec2 d = rotate(pixel-pos,-rot);

        float s = piece_size*(0.6+rand(fi*3.7));

        vec2 local=d/vec2(s*1.8,s);

        float inside=step(max(abs(local.x),abs(local.y)),1.0);

        if(inside>0.5){

            float fade=1.0-smoothstep(0.7,1.0,progress);

            vec4 c=palette(rand(fi*5.2));

            out_col=mix(out_col,vec4(c.rgb,fade),inside);
        }
    }

    COLOR=out_col;
}