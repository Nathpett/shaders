precision mediump float;
// full sharingan shader
#define PI 3.14159265358979323846
#define TWO_PI 6.28318530718

uniform vec2 u_resolution;
uniform float u_time;

mat2 rotate2d(float _angle){
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

float circle(in vec2 _st, in float _radius, in vec2 _center){
    vec2 dist = _center - _st;
    return 1. - smoothstep(_radius-(_radius*0.01),
                		_radius+(_radius*0.01),
                      	dot(dist, dist) * 4.0);
}

float flower_circ(in vec2 _st, in int n, in float circ_r, in float ring_r){
    #define TWO_PI 6.28318530718
    vec2 pos = vec2(0.5)-_st;

    float r = length(pos)*2.0;
    float a = atan(pos.y,pos.x) + TWO_PI/float(2*n);
	
    //round angle to closest nth angle.
    float nth = TWO_PI/float(n);
    a = floor(a / nth) * nth;
    
    // draw something at end of angle
    vec2 origin = vec2(ring_r*cos(a), ring_r*sin(a));
    float pnt = circle(pos, circ_r, origin);
    

    //return flower_plot(f, r, 0.02);
    return 1.0 - smoothstep(pnt, pnt+0.02, ring_r);
}


float sharingan(in vec2 _st, in int n){
	#define TWO_PI 6.28318530718
    float ring_r = 0.25;
    float pnt = flower_circ(_st, n, .075, ring_r);
    _st -= vec2(0.5);
    _st = _st*rotate2d(0.4);
    _st += vec2(0.5);
    pnt -= flower_circ(_st, n, .075, ring_r);
    pnt -= circle(_st, ring_r, vec2(0.5));
    _st -= vec2(0.5);
    _st = _st*rotate2d(-0.6);
    _st += vec2(0.5);
    pnt = max(pnt, flower_circ(_st, n, .03, ring_r));
    
    return pnt;
}

void main(){
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    vec3 color = vec3(0.0);

    
    st -= vec2(0.5);
    st = st * rotate2d(fract(u_time * -0.3) * TWO_PI);
    st += vec2(0.5);
    
    color = vec3(1.0 - circle(st, 1.0, vec2(0.5)));
    color = max(color, vec3(circle(st, 0.8, vec2(0.5)) * vec3(0.815,0.110,0.064)));
    color -= vec3(0.3*circle(st, 0.3, vec2(0.5)));
    color = max(color, vec3(circle(st, 0.25, vec2(0.5)) * vec3(0.815,0.110,0.064)));
    color -= vec3(circle(st, 0.015, vec2(0.5,.5)));
    
    float pct = sharingan(st, 3);
    color -= vec3(pct);

    gl_FragColor = vec4(color,1.0);
}
