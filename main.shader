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
