//Transform matrix constructors
mat2 scale(vec2 _scale){
    return mat2(_scale.x,0.0,
                0.0,_scale.y);
}

mat2 rotate2d(float _angle){
    return mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle));
}

//Better rotate2d...
//vec2 rotate2D(vec2 _st, float _angle){
//    _st -= 0.5;
//    _st =  mat2(cos(_angle),-sin(_angle),
//                sin(_angle),cos(_angle)) * _st;
//    _st += 0.5;
//    return _st;
//}

//Random functions 
float random(in float x){
    return fract(sin(x)*43758.5453);
}

float random(in vec2 st){
    return fract(sin(dot(st.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

// noises directly from https://thebookofshaders.com/11/ and https://www.shadertoy.com/view/4dS3Wd
float noise (in float x){

    float i = floor(x + u_time);  // integer
    float f = fract(x + u_time);  // fraction
    return random(i); 

return mix(random(i), random(i + 1.0), smoothstep(0.,1.,f));
}

float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f*f*(3.0-2.0*f);
    //  u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
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

float o(in vec2 _st){
    float pct = circle(_st, 0.8, vec2(0.5));
    pct -= circle(_st, 0.6, vec2(0.5));
    return pct;
}

float x(in vec2 _st){
    float thick = 0.05;
    float pct = step(abs(_st.x - _st.y), thick);
	pct += step(abs(1.0 - _st.x - _st.y), thick);    
	pct = min(pct, step(abs(_st.x - .5), 0.4));
    return pct;
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

void tictactoe() {
    vec2 st = gl_FragCoord.xy/u_resolution;
    vec2 st_tru = st;
    vec3 color = vec3(0.0);
	
    vec2 scl = vec2(3.);
    st *= scl;       // Scale up the space by 3
    st = fract(st); // Wrap around 1.0
    
    vec2 b = step(vec2(0.04), st);
	vec2 bb = step(vec2(0.04), 1. - st);
    float pct = b.x * b.y * bb.x * bb.y;
    
    color = vec3(pct);
    
    float x_cel = floor(st_tru.x * scl.x); 
    float y_cel = floor(st_tru.y * scl.y); 
    if (mod(x_cel + y_cel, 2.) == 1.) {
        color -= vec3(x(st));
    } else {
        color -= vec3(o(st));
    }
    gl_FragColor = vec4(color,1.0);
}

vec2 shuffle_bricks(vec2 _st, float _zoom){
    _st *= _zoom;
	
    _st.x += step(1., mod(1. + _st.y,2.0)) * clamp(abs(4.*fract(u_time)-2.) - 1.0, -.5, .5);
    _st.x += step(1., mod(_st.y,2.0)) * -clamp(abs(4.*fract(u_time)-2.) - 1.0, -.5, .5);
    
    _st.y += 2.* step(1., mod(1. + _st.x,2.0)) * clamp(abs(4.*fract(u_time -.25)-2.) - 1.0, -.5, .5);
    _st.y += step(1., mod(_st.x,2.0)) * -2. * clamp(abs(4.*fract(u_time +.25)-2.) - 1.0, -.5, .5);
    
    return fract(_st);
}
