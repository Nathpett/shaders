//Transform matrix constructors
mat2 scale(vec2 _scale){
    return mat2(_scale.x,0.0,
                0.0,_scale.y);
}

mat2 rotate2d(float _angle){
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

//Random functions 
float random(in float x){
    return fract(sin(x)*43758.5453);
}

float random(in vec2 st){
    return fract(sin(dot(st.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

float rect_a(vec2 _st, vec2 pos, vec2 wh, float edge_blur){

    // pos --- top left position of rectangle
    // wh --- width and height of rectangle
    // edge_blur --- degree of blurring around rect's edge
     
    //return t*l*b*r;
    vec4 tlbr = vec4(pos.y, 			//t
                     pos.x, 			//l
                     1.0 - wh.y-pos.y,  //b
                     1.0 - wh.x-pos.x); //r
    vec4 _sta = vec4(1.0 - _st.y, _st.x, _st.y, 1.0-_st.x);
    
    tlbr = smoothstep(tlbr, tlbr + vec4(edge_blur), _sta);
    
    return tlbr.x * tlbr.y * tlbr.w * tlbr.z;
}

float rect(vec2 st, vec2 ulim, vec2 llim){
    // simple rect
    // ulim --- x y coordinates at which the rectangle starts
    // llim --- xy coordinates at which the rectangle stops 
    
    vec2 bl = step(vec2(ulim.x, ulim.y),st);
    vec2 tr = step(vec2(1.0 - llim.x, 1.0 - llim.y),1.0-st);

    return bl.x * bl.y * tr.x * tr.y;
}

float circle(in vec2 _st, in float _radius, in vec2 _center){
    vec2 dist = _center - _st;
    return 1. - smoothstep(_radius-(_radius*0.01),
                		_radius+(_radius*0.01),
                      	dot(dist, dist) * 4.0);
}

float circle_prod(in vec2 _st, in float _radius, in vec2 _c1, in vec2 _c2){
    
    vec2 dist_1 = _c1 - _st;
    vec2 dist_2 = _c2 - _st;
    float pct = dot(dist_1, dist_1) * 
        dot(dist_2, dist_2) * 16.0;
    return 1. - smoothstep(_radius-(_radius*0.01),
                		_radius+(_radius*0.01),
                      	pct);
}

float flower_plot(in float f, in float pct, in float weight){
  return  smoothstep( pct-(pct * weight), pct, f) -
          smoothstep( pct, pct+(pct * weight), f);
}

float flower(in vec2 _st, in float n, in float size, in float a_offset){
    vec2 pos = vec2(0.5)-_st;

    float r = length(pos)*2.0;
    float a = atan(pos.y,pos.x) + a_offset;

    float f = size + sin(a*n);
    
    //return flower_plot(f, r, 0.02);
    return 1.0 - smoothstep(f, f+0.02, r);
}

float d_field_shape(in vec2 st, in int n_sides){
    //use for making distance fields of regular polygons of n sides
    
    #define PI 3.14159265359
    #define TWO_PI 6.28318530718

    // Angle and radius from the current pixel
    float a = atan(st.x,st.y) + PI;
    float r = TWO_PI/float(n_sides);
    
    return cos(floor(0.5+a/r)*r-a)*length(st);
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

void piet_mondrian(){
    //Draws aproximation of Piet Mondrian's Tableau (1921).
    //Proportion and colors are off, but I didn't take exact measurements and that wasn't the point of this task.
    
    vec2 st = gl_FragCoord.xy/u_resolution.xy * vec2(1.3, 1.0);
	
	//line weight
    float l = 0.03;
    
    //normalized coordnates of "row" dividers
    float r0 = 0.1;
    float r1 = 0.6;
    float r2 = 0.8;
	float r3 = 1.0;
    
    // normalized coordinates of "column" dividers
    float c1 = 0.05;
    float c2 = 0.2;
    float c3 = 0.65;
    float c4 = 0.95;
    
    vec3 r = vec3(0.555,0.164,0.132);
    vec3 b = vec3(0.107,0.189,0.555);
    vec3 y = vec3(0.890,0.834,0.329);
    vec3 w = vec3(0.880,0.849,0.756);
    vec3 c = vec3(0.0);
    
    c += w * rect(st, vec2(0.0, 0.0), vec2(c2, r1));
    
    c += r * rect(st, vec2(0.0, r1 + l), vec2(c1, r2));
    c += r * rect(st, vec2(0.0, r2 + l), vec2(c1, r3));
    
    c += r * rect(st, vec2(c1 + l, r1 + l), vec2(c2, r2));
    c += r * rect(st, vec2(c1 + l, r2 + l), vec2(c2, r3));
    
    c += w * rect(st, vec2(c2 + l, 0.0), vec2(c3, r0));
    c += w * rect(st, vec2(c2 + l, r0 + l), vec2(c3, r1));
    c += w * rect(st, vec2(c2 + l, r1 + l), vec2(c3, r2));
    c += w * rect(st, vec2(c2 + l, r2 + l), vec2(c3, r3));
    
    c += b * rect(st, vec2(c3 + l, 0.0), vec2(c4, r0));
    c += w * rect(st, vec2(c3 + l, r0 + l), vec2(c4, r1));
    c += w * rect(st, vec2(c3 + l, r1 + l), vec2(c4, r2));
    c += w * rect(st, vec2(c3 + l, r2 + l), vec2(c4, r3));
    
    c += b * rect(st, vec2(c4 + l, 0.0), vec2(1.0, r0));
    c += w * rect(st, vec2(c4 + l, r0 + l), vec2(1.0, r1));
    c += y * rect(st, vec2(c4 + l, r1 + l), vec2(1.0, r2));
    c += y * rect(st, vec2(c4 + l, r2 + l), vec2(1.0, r3));
    
    gl_FragColor = vec4(c,1.0);
}

float triforce(in vec2 _st, float _size){
    return  min(step(d_field_shape(_st, 3), _size), 1.0 -step(d_field_shape(_st * rotate2d(TWO_PI * 0.5), 3), _size/2.));
}
